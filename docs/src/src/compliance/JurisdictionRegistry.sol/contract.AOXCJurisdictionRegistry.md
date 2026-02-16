# AOXCJurisdictionRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/compliance/JurisdictionRegistry.sol)

**Inherits:**
[IJurisdictionRegistry](/src/interfaces/IJurisdictionRegistry.sol/interface.IJurisdictionRegistry.md), Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable

**Title:**
AOXCJurisdictionRegistry

**Author:**
AOXC Core Engineering

Regional compliance and jurisdiction management for the AOXC ecosystem.

Fully implements IJurisdictionRegistry with 26-channel forensic monitoring.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### OPERATOR_ROLE

```solidity
bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### reputationManager

```solidity
IReputationManager public reputationManager
```


### _jurisdictionIds

```solidity
uint256[] private _jurisdictionIds
```


### _jurisdictionNames

```solidity
mapping(uint256 => string) private _jurisdictionNames
```


### _jurisdictionAllowed

```solidity
mapping(uint256 => bool) private _jurisdictionAllowed
```


### _userJurisdiction

```solidity
mapping(address => uint256) private _userJurisdiction
```


### _jurisdictionIndex

```solidity
mapping(uint256 => uint256) private _jurisdictionIndex
```


### _gap

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

Initializes the Jurisdiction Registry.


```solidity
function initialize(address admin, address _monitoringHub, address _reputationManager)
    external
    initializer;
```

### registerJurisdiction


```solidity
function registerJurisdiction(uint256 id, string calldata name)
    external
    override
    onlyRole(OPERATOR_ROLE)
    whenNotPaused;
```

### removeJurisdiction


```solidity
function removeJurisdiction(uint256 jurisdictionId) external override onlyRole(ADMIN_ROLE);
```

### assignJurisdiction


```solidity
function assignJurisdiction(address user, uint256 id)
    external
    override
    onlyRole(OPERATOR_ROLE)
    whenNotPaused;
```

### revokeJurisdiction


```solidity
function revokeJurisdiction(address user) external override onlyRole(OPERATOR_ROLE);
```

### isAllowed


```solidity
function isAllowed(address account) external view override returns (bool);
```

### getUserJurisdiction


```solidity
function getUserJurisdiction(address user) external view override returns (uint256);
```

### jurisdictionExists


```solidity
function jurisdictionExists(uint256 jurisdictionId) external view override returns (bool);
```

### getJurisdictionCount


```solidity
function getJurisdictionCount() external view override returns (uint256);
```

### getJurisdictionName


```solidity
function getJurisdictionName(uint256 jurisdictionId)
    external
    view
    override
    returns (string memory);
```

### batchAssignJurisdiction


```solidity
function batchAssignJurisdiction(address[] calldata users, uint256 id)
    external
    onlyRole(OPERATOR_ROLE)
    whenNotPaused;
```

### _assignJurisdiction


```solidity
function _assignJurisdiction(address user, uint256 id) internal;
```

### _rewardOperator


```solidity
function _rewardOperator(address operator, bytes32 actionKey) internal;
```

### _logToHub

High-fidelity 26-channel forensic logging.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### JurisdictionAdded

```solidity
event JurisdictionAdded(
    uint256 indexed id, string name, bool allowed, address indexed operator
);
```

### JurisdictionRemoved

```solidity
event JurisdictionRemoved(uint256 indexed id, address indexed operator);
```

### UserJurisdictionSet

```solidity
event UserJurisdictionSet(
    address indexed user, uint256 indexed jurisdictionId, address indexed operator
);
```

### UserJurisdictionRevoked

```solidity
event UserJurisdictionRevoked(address indexed user, address indexed operator);
```

