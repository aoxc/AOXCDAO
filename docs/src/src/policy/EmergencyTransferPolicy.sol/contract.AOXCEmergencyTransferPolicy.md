# AOXCEmergencyTransferPolicy
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/policy/EmergencyTransferPolicy.sol)

**Inherits:**
[ITransferPolicy](/src/interfaces/ITransferPolicy.sol/interface.ITransferPolicy.md), Initializable, AccessControlUpgradeable, UUPSUpgradeable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
AOXCEmergencyTransferPolicy

**Author:**
AOXC Core Engineering

High-security transfer policy engine for emergency freezes and global limits.

Re-engineered for Akdeniz V2 with wrapped modifiers for lint compliance and gas optimization.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### GUARDIAN_ROLE

```solidity
bytes32 public constant GUARDIAN_ROLE = keccak256("AOXC_GUARDIAN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### frozen

```solidity
bool public frozen
```


### globalTransferLimit

```solidity
uint256 public globalTransferLimit
```


### isExempt

```solidity
mapping(address => bool) public isExempt
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
Reserved storage gap for upgradeability protection (50 slots total).


```solidity
uint256[46] private _gap
```


## Functions
### nonReentrant

Optimized Reentrancy Guard logic with internal wrapping to satisfy enterprise lint rules.


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

Initializes the Emergency Transfer Policy.


```solidity
function initialize(address admin, address _monitoringHub, uint256 _initialLimit)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|Initial administrator address.|
|`_monitoringHub`|`address`|Forensic logging hub address.|
|`_initialLimit`|`uint256`|Initial global transfer amount threshold.|


### validateTransfer

Validates a transfer against current security policies.


```solidity
function validateTransfer(address from, address to, uint256 amount) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Sender address.|
|`to`|`address`|Recipient address.|
|`amount`|`uint256`|Transaction value.|


### setEmergencyStatus

Updates the emergency freeze status and global limits.


```solidity
function setEmergencyStatus(bool _frozen, uint256 _newLimit) external onlyRole(GUARDIAN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_frozen`|`bool`|New freeze status.|
|`_newLimit`|`uint256`|New global limit.|


### isPolicyActive


```solidity
function isPolicyActive() external view override returns (bool);
```

### policyName


```solidity
function policyName() external pure override returns (string memory);
```

### policyVersion


```solidity
function policyVersion() external pure override returns (uint256);
```

### updatePolicyParameter


```solidity
function updatePolicyParameter(string calldata, uint256 newValue)
    external
    override
    onlyRole(ADMIN_ROLE);
```

### setPolicyActive


```solidity
function setPolicyActive(bool active) external override onlyRole(ADMIN_ROLE);
```

### _authorizeUpgrade

Implementation for UUPS upgrade authorization.


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE);
```

