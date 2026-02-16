# AOXCSentinelExecutor
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/security/AOXCSentinelExecutor.sol)

**Inherits:**
Initializable, AccessControlUpgradeable

**Title:**
AOXCSentinelExecutor

**Author:**
AOXC Core Engineering

Automated sentinel that monitors forensic data and triggers circuit breakers.

Updated to match interface (0-arg pause) and fixed lint warnings.


## State Variables
### SENTINEL_ROLE

```solidity
bytes32 public constant SENTINEL_ROLE = keccak256("SENTINEL_ROLE")
```


### pauseGuard

```solidity
IEmergencyPauseGuard public pauseGuard
```


### autoPauseThreshold

```solidity
uint8 public autoPauseThreshold
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
Reserved storage gap for future upgradeability protection.


```solidity
uint256[48] private _gap
```


## Functions
### nonReentrant

Optimized Reentrancy Guard logic to satisfy enterprise linting rules.


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

Initializes the Sentinel Executor with administrative and pause controls.


```solidity
function initialize(address admin, address _pauseGuard) external initializer;
```

### validateAndExecute

Validates forensic logs and triggers protocol pause if risk exceeds threshold.

Synchronized with IEmergencyPauseGuard to use 0-argument pause().


```solidity
function validateAndExecute(IMonitoringHub.ForensicLog calldata log)
    external
    onlyRole(SENTINEL_ROLE)
    nonReentrant;
```

### updateThreshold

Updates the automatic pause trigger threshold.


```solidity
function updateThreshold(uint8 newThreshold) external onlyRole(DEFAULT_ADMIN_ROLE);
```

## Events
### SentinelActionExecuted

```solidity
event SentinelActionExecuted(uint8 riskScore, IMonitoringHub.Severity severity);
```

### ThresholdUpdated

```solidity
event ThresholdUpdated(uint8 oldThreshold, uint8 newThreshold);
```

