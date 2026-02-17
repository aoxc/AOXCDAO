# AOXCComplianceRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/compliance/ComplianceRegistry.sol)

**Inherits:**
[IComplianceRegistry](/src/interfaces/IComplianceRegistry.sol/interface.IComplianceRegistry.md), Initializable, AccessControlUpgradeable, UUPSUpgradeable, PausableUpgradeable

**Title:**
AOXCComplianceRegistry

**Author:**
AOXC Core Engineering

Centralized compliance and blacklist management for the AOXC ecosystem.

Fully implements IComplianceRegistry with 26-channel forensic monitoring.
Provides granular control over restricted accounts with reason-based blacklisting.


## State Variables
### ADMIN_ROLE
Role for high-level administrative tasks.


```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### COMPLIANCE_OFFICER_ROLE
Role for legal and compliance officers authorized to manage the blacklist.


```solidity
bytes32 public constant COMPLIANCE_OFFICER_ROLE = keccak256("AOXC_COMPLIANCE_OFFICER_ROLE")
```


### UPGRADER_ROLE
Role authorized to trigger contract implementation upgrades.


```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### monitoringHub
Reference to the centralized forensic logging and monitoring hub.


```solidity
IMonitoringHub public monitoringHub
```


### reputationManager
Reference to the reputation scoring manager for officer incentives.


```solidity
IReputationManager public reputationManager
```


### _blacklistedAccounts
Enumerable array of all currently blacklisted addresses.


```solidity
address[] private _blacklistedAccounts
```


### _blacklisted
Mapping to check if an address is currently restricted.


```solidity
mapping(address => bool) private _blacklisted
```


### _blacklistReasons
Mapping to store the justification for each blacklist action.


```solidity
mapping(address => string) private _blacklistReasons
```


### _blacklistIndex
Internal mapping for O(1) removal from the _blacklistedAccounts array.


```solidity
mapping(address => uint256) private _blacklistIndex
```


### _gap
Storage gap for future upgradeability expansion.


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

Initializes the Compliance Registry contract with core dependencies.


```solidity
function initialize(address admin, address _monitoringHub, address _reputationManager)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|The default administrator address.|
|`_monitoringHub`|`address`|The address of the MonitoringHub contract.|
|`_reputationManager`|`address`|The address of the ReputationManager contract.|


### addToBlacklist

Restricts an account from interacting with protected protocol functions.


```solidity
function addToBlacklist(address account, string calldata reason)
    external
    override
    onlyRole(COMPLIANCE_OFFICER_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to blacklist.|
|`reason`|`string`|String description of why the account is being blacklisted.|


### removeFromBlacklist

Lifts restrictions from a previously blacklisted account.


```solidity
function removeFromBlacklist(address account)
    external
    override
    onlyRole(COMPLIANCE_OFFICER_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to restore.|


### getBlacklistCount

Returns the total number of currently blacklisted accounts.


```solidity
function getBlacklistCount() external view override returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 Count of restricted addresses.|


### isBlacklisted

Checks if a specific account is currently blacklisted.


```solidity
function isBlacklisted(address account) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to query.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the account is restricted.|


### getBlacklistReason

Retrieves the documented reason for an account's blacklist status.


```solidity
function getBlacklistReason(address account) external view override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The restricted address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|string The justification string.|


### batchAddToBlacklist

Processes multiple blacklist entries in a single transaction for gas efficiency.

Arrays must have identical lengths.


```solidity
function batchAddToBlacklist(address[] calldata accounts, string[] calldata reasons)
    external
    onlyRole(COMPLIANCE_OFFICER_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`accounts`|`address[]`|Array of addresses to restrict.|
|`reasons`|`string[]`|Array of justifications corresponding to each address.|


### _addToBlacklist

Internal logic for blacklisting. Updates status, mapping, and enumerable array.


```solidity
function _addToBlacklist(address account, string memory reason) internal;
```

### _removeFromBlacklist

Internal logic for unblacklisting using the swap-and-pop pattern to maintain array integrity.


```solidity
function _removeFromBlacklist(address account) internal;
```

### _rewardOfficer

Processes officer reputation rewards if the reputation manager is linked.


```solidity
function _rewardOfficer(address officer, bytes32 actionKey) internal;
```

### _logToHub

High-fidelity 26-channel forensic logging.
Replaced `tx.origin` with `msg.sender` for security compliance.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### getBlacklistedAccounts

Returns the full list of blacklisted accounts.


```solidity
function getBlacklistedAccounts() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|address[] Memory array containing all restricted addresses.|


### _authorizeUpgrade

Internal authorization for UUPS contract upgrades.


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### Blacklisted
Emitted when an account is added to the blacklist.


```solidity
event Blacklisted(address indexed account, string reason, address indexed officer);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address being restricted.|
|`reason`|`string`|The legal or technical justification for the restriction.|
|`officer`|`address`|The address of the officer who performed the action.|

### Unblacklisted
Emitted when an account is removed from the blacklist.


```solidity
event Unblacklisted(address indexed account, address indexed officer);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address whose restrictions were lifted.|
|`officer`|`address`|The address of the officer who performed the action.|

