# RiskSignals
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/monitoring/RiskSignals.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, UUPSUpgradeable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
RiskSignals

**Author:**
AOXC Core Engineering

Enterprise-grade system for processing 26-channel risk telemetry.

Re-engineered for Akdeniz V2. Eliminates all compiler warnings and lint notes.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### RISK_REPORTER_ROLE

```solidity
bytes32 public constant RISK_REPORTER_ROLE = keccak256("AOXC_RISK_REPORTER_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### totalSignalsProcessed

```solidity
uint256 public totalSignalsProcessed
```


### activeSignals

```solidity
mapping(bytes32 => bool) public activeSignals
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
Reserved storage gap (50 slots total).
Reporter base: 2 slots, local state: 2 slots -> Gap: 46.


```solidity
uint256[46] private _gap
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

Initializes the Risk Signals module with core dependencies.


```solidity
function initialize(address admin, address _monitoringHub) external initializer;
```

### emitSignal

Emits a high-fidelity risk signal using 26 channels.

Optimized with Yul to prevent [asm-keccak256] and handle complex calldata segments.


```solidity
function emitSignal(
    string calldata category,
    IMonitoringHub.Severity severity,
    uint8 riskScore,
    bytes calldata metadata
) external nonReentrant onlyRole(RISK_REPORTER_ROLE);
```

### updateRiskPolicy

Updates the risk policy and triggers a forensic audit trail.


```solidity
function updateRiskPolicy(string calldata description, bytes32 policyHash)
    external
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

## Events
### RiskSignalEmitted

```solidity
event RiskSignalEmitted(
    bytes32 indexed signalHash,
    string category,
    IMonitoringHub.Severity severity,
    uint256 riskScore
);
```

### RiskPolicyUpdated

```solidity
event RiskPolicyUpdated(string description, bytes32 indexed policyHash, address indexed actor);
```

