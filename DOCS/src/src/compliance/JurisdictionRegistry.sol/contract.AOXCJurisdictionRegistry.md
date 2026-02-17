# AOXCJurisdictionRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/compliance/JurisdictionRegistry.sol)

**Inherits:**
[IJurisdictionRegistry](/src/interfaces/IJurisdictionRegistry.sol/interface.IJurisdictionRegistry.md), Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable

**Title:**
AOXCJurisdictionRegistry

**Author:**
AOXC Core Engineering

Regional compliance and jurisdiction management for the AOXC ecosystem.

Fully implements IJurisdictionRegistry with 26-channel forensic monitoring.
This registry tracks which users belong to which legal jurisdictions and their status.


## State Variables
### ADMIN_ROLE
Role for administrative tasks such as removing jurisdictions.


```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### OPERATOR_ROLE
Role for day-to-day operations like registering or assigning users.


```solidity
bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE")
```


### UPGRADER_ROLE
Role authorized to trigger contract upgrades.


```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### monitoringHub
Reference to the central monitoring and forensic logging hub.


```solidity
IMonitoringHub public monitoringHub
```


### reputationManager
Reference to the reputation scoring manager.


```solidity
IReputationManager public reputationManager
```


### _jurisdictionIds
Array of all registered jurisdiction IDs.


```solidity
uint256[] private _jurisdictionIds
```


### _jurisdictionNames
Maps jurisdiction ID to its descriptive name (e.g., "European Union").


```solidity
mapping(uint256 => string) private _jurisdictionNames
```


### _jurisdictionAllowed
Maps jurisdiction ID to its global permission status.


```solidity
mapping(uint256 => bool) private _jurisdictionAllowed
```


### _userJurisdiction
Maps user address to their currently assigned jurisdiction ID.


```solidity
mapping(address => uint256) private _userJurisdiction
```


### _jurisdictionIndex
Internal index mapping for efficient array removal.


```solidity
mapping(uint256 => uint256) private _jurisdictionIndex
```


### _gap
Storage gap for future upgradeability.


```solidity
uint256[43] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the Jurisdiction Registry with core dependencies.


```solidity
function initialize(address admin, address _monitoringHub, address _reputationManager)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|The default administrator and role holder.|
|`_monitoringHub`|`address`|The address of the MonitoringHub contract.|
|`_reputationManager`|`address`|The address of the ReputationManager contract.|


### registerJurisdiction

Registers a new legal jurisdiction.


```solidity
function registerJurisdiction(uint256 id, string calldata name)
    external
    override
    onlyRole(OPERATOR_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Numeric ID for the jurisdiction (must be non-zero).|
|`name`|`string`|Descriptive name (e.g., "Turkey", "USA").|


### removeJurisdiction

Removes a jurisdiction from the registry.

Uses swap-and-pop pattern for gas efficiency in array management.


```solidity
function removeJurisdiction(uint256 jurisdictionId) external override onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|The ID of the jurisdiction to remove.|


### assignJurisdiction

Assigns a user to a registered jurisdiction.


```solidity
function assignJurisdiction(address user, uint256 id)
    external
    override
    onlyRole(OPERATOR_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user.|
|`id`|`uint256`|The jurisdiction ID to assign.|


### revokeJurisdiction

Removes any jurisdiction assignment from a user.


```solidity
function revokeJurisdiction(address user) external override onlyRole(OPERATOR_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user to revoke.|


### isAllowed

Checks if a user belongs to an allowed jurisdiction.


```solidity
function isAllowed(address account) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if assigned to an allowed jurisdiction, false otherwise.|


### getUserJurisdiction

Retrieves the jurisdiction ID for a specific user.


```solidity
function getUserJurisdiction(address user) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The jurisdiction ID (0 if not assigned).|


### jurisdictionExists

Checks if a jurisdiction ID is registered.


```solidity
function jurisdictionExists(uint256 jurisdictionId) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|The ID to verify.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if exists.|


### getJurisdictionCount

Returns total number of registered jurisdictions.


```solidity
function getJurisdictionCount() external view override returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 Count of jurisdictions.|


### getJurisdictionName

Gets the name of a jurisdiction.


```solidity
function getJurisdictionName(uint256 jurisdictionId)
    external
    view
    override
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|The ID of the jurisdiction.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|string The name of the jurisdiction.|


### batchAssignJurisdiction

Assigns multiple users to a single jurisdiction in one transaction.


```solidity
function batchAssignJurisdiction(address[] calldata users, uint256 id)
    external
    onlyRole(OPERATOR_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`users`|`address[]`|Array of user addresses.|
|`id`|`uint256`|The jurisdiction ID.|


### _assignJurisdiction

Internal assignment logic to reduce code duplication.


```solidity
function _assignJurisdiction(address user, uint256 id) internal;
```

### _rewardOperator

Triggers reputation reward for an operator's action.


```solidity
function _rewardOperator(address operator, bytes32 actionKey) internal;
```

### _logToHub

High-fidelity 26-channel forensic logging.
Note: `tx.origin` replaced with `msg.sender` to satisfy security linters
unless deep forensic origin is explicitly required.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### _authorizeUpgrade

Internal authorization for UUPS upgrades.


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### JurisdictionAdded
Emitted when a new jurisdiction is added to the registry.


```solidity
event JurisdictionAdded(
    uint256 indexed id, string name, bool indexed allowed, address indexed operator
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Unique identifier for the jurisdiction.|
|`name`|`string`|Human-readable name of the jurisdiction.|
|`allowed`|`bool`|Whether this jurisdiction is permitted by default.|
|`operator`|`address`|The address that performed the registration.|

### JurisdictionRemoved
Emitted when a jurisdiction is removed from the registry.


```solidity
event JurisdictionRemoved(uint256 indexed id, address indexed operator);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|The identifier of the removed jurisdiction.|
|`operator`|`address`|The address that performed the removal.|

### UserJurisdictionSet
Emitted when a user is assigned to a specific jurisdiction.


```solidity
event UserJurisdictionSet(
    address indexed user, uint256 indexed jurisdictionId, address indexed operator
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user.|
|`jurisdictionId`|`uint256`|The assigned jurisdiction identifier.|
|`operator`|`address`|The address that performed the assignment.|

### UserJurisdictionRevoked
Emitted when a user's jurisdiction assignment is removed.


```solidity
event UserJurisdictionRevoked(address indexed user, address indexed operator);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user.|
|`operator`|`address`|The address that performed the revocation.|

