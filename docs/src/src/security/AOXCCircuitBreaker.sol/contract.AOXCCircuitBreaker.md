# AOXCCircuitBreaker
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/security/AOXCCircuitBreaker.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
AOXCCircuitBreaker

**Author:**
AOXC Core Engineering

Enterprise-grade circuit breaker to prevent bank runs and flash-loan exploits.

Re-engineered for Akdeniz V2. Integrated with Global Coordinator for atomic system-wide protection.


## State Variables
### coordinator

```solidity
AOXCAccessCoordinator public coordinator
```


### volumeThreshold

```solidity
uint256 public volumeThreshold
```


### lastResetTime

```solidity
uint256 public lastResetTime
```


### currentWindowVolume

```solidity
uint256 public currentWindowVolume
```


### windowDuration

```solidity
uint256 public windowDuration
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
Reserved storage gap. (Coordinator: 1 slot, state: 4 slots -> 5 slots used)


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

Initializes the Circuit Breaker logic and monitoring link.


```solidity
function initialize(
    address admin,
    address _monitoringHub,
    address _coordinator,
    uint256 _initialThreshold
) external initializer;
```

### checkVolume

Validates transaction volume against the hourly threshold.

If threshold is breached, it triggers a global system pause via Coordinator.


```solidity
function checkVolume(uint256 amount) external nonReentrant;
```

### updateThreshold

Updates the maximum volume threshold.


```solidity
function updateThreshold(uint256 newThreshold) external onlyRole(AOXCConstants.ADMIN_ROLE);
```

### manualReset

Manually resets the volume window.


```solidity
function manualReset() external onlyRole(AOXCConstants.ADMIN_ROLE);
```

## Events
### ThresholdUpdated

```solidity
event ThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
```

### CircuitBreakerReset

```solidity
event CircuitBreakerReset(uint256 timestamp);
```

### EmergencyBreakerTriggered

```solidity
event EmergencyBreakerTriggered(uint256 totalVolume, string reason);
```

