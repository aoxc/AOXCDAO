# AOXCTransferPolicyEngine
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/policy/TransferPolicyEngine.sol)

**Inherits:**
[ITransferPolicy](/src/interfaces/ITransferPolicy.sol/interface.ITransferPolicy.md), Initializable, AccessControlUpgradeable, UUPSUpgradeable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
AOXCTransferPolicyEngine

**Author:**
AOXC Core Engineering

Central engine for auditing and enforcing all transfer policies.

Optimized with inline assembly for hashing and wrapped modifiers for lint compliance.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### complianceRegistry

```solidity
IComplianceRegistry public complianceRegistry
```


### threatSurface

```solidity
IThreatSurface public threatSurface
```


### maxTxAmount

```solidity
uint256 public maxTxAmount
```


### _policyActive

```solidity
bool private _policyActive
```


### strictThreatMode

```solidity
bool public strictThreatMode
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
Reserved storage gap for upgradeability protection (50 slots).


```solidity
uint256[45] private _gap
```


## Functions
### nonReentrant


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

Initializes the Policy Engine with core links.


```solidity
function initialize(
    address admin,
    address _complianceRegistry,
    address _monitoringHub,
    address _threatSurface,
    uint256 _maxTxAmount
) external initializer;
```

### validateTransfer

Validates a transfer against compliance, amount limits, and threat signatures.


```solidity
function validateTransfer(address from, address to, uint256 amount)
    external
    override
    nonReentrant;
```

### _checkThreats


```solidity
function _checkThreats(bytes32 patternId, address from, address to, uint256 amount) internal;
```

### _generatePatternId

Assembly optimized hashing to eliminate lint [asm-keccak256] notes.


```solidity
function _generatePatternId(address from, address to, uint256 amount)
    internal
    pure
    returns (bytes32 patternId);
```

### setStrictThreatMode


```solidity
function setStrictThreatMode(bool _strict) external onlyRole(ADMIN_ROLE);
```

### setPolicyActive


```solidity
function setPolicyActive(bool active) external override onlyRole(ADMIN_ROLE);
```

### updatePolicyParameter

Updates policy parameters with assembly-optimized string comparison.

Eliminates lint [asm-keccak256] by using inline assembly for the string hash.


```solidity
function updatePolicyParameter(string calldata parameter, uint256 newValue)
    external
    override
    nonReentrant
    onlyRole(ADMIN_ROLE);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE);
```

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

## Errors
### AOXC__MaxTxExceeded

```solidity
error AOXC__MaxTxExceeded();
```

### AOXC__NonCompliant

```solidity
error AOXC__NonCompliant();
```

### AOXC__CriticalThreat

```solidity
error AOXC__CriticalThreat();
```

### AOXC__ThreatServiceOffline

```solidity
error AOXC__ThreatServiceOffline();
```

