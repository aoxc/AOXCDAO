# AOXCGuardianRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/security/GuardianRegistry.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
AOXCGuardianRegistry

**Author:**
AOXC Core Engineering

Dynamic management of Guardians (Sentinels) within the AOXC ecosystem.

Re-engineered for Akdeniz V2 Forensic Logging with wrapped modifiers for lint compliance.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### _activeGuardians

```solidity
address[] private _activeGuardians
```


### _isGuardian

```solidity
mapping(address => bool) private _isGuardian
```


### _guardianIndex

```solidity
mapping(address => uint256) private _guardianIndex
```


### _status

```solidity
uint256 private _status
```


### _NOT_ENTERED

```solidity
uint256 private constant _NOT_ENTERED = 1
```


### _ENTERED

```solidity
uint256 private constant _ENTERED = 2
```


### _gap
Reserved storage gap for upgradeability.


```solidity
uint256[46] private _gap
```


## Functions
### nonReentrant

Optimized Reentrancy Guard with internal wrapping to reduce code size.


```solidity
modifier nonReentrant() ;
```

### _nonReentrantBefore


```solidity
function _nonReentrantBefore() internal;
```

### _nonReentrantAfter


```solidity
function _nonReentrantAfter() internal;
```

### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the Guardian Registry.


```solidity
function initialize(address admin, address _monitoringHub) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|Initial administrator address.|
|`_monitoringHub`|`address`|Address of the centralized monitoring system.|


### addGuardian

Appoints a new guardian to the registry.


```solidity
function addGuardian(address guardian)
    external
    onlyRole(ADMIN_ROLE)
    whenNotPaused
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`guardian`|`address`|Address to be granted sentinel powers.|


### removeGuardian

Dismisses a guardian from the registry using a gas-efficient Swap & Pop.


```solidity
function removeGuardian(address guardian) external onlyRole(ADMIN_ROLE) nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`guardian`|`address`|Address to be removed from the registry.|


### isGuardian


```solidity
function isGuardian(address account) external view returns (bool);
```

### getGuardianCount


```solidity
function getGuardianCount() external view returns (uint256);
```

### listActiveGuardians


```solidity
function listActiveGuardians() external view returns (address[] memory);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE);
```

## Events
### GuardianAdded

```solidity
event GuardianAdded(address indexed guardian, uint256 timestamp);
```

### GuardianRemoved

```solidity
event GuardianRemoved(address indexed guardian, uint256 timestamp);
```

