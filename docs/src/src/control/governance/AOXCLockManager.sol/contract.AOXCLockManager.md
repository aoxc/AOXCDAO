# AOXCLockManager
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/control/governance/AOXCLockManager.sol)

**Inherits:**
ReentrancyGuard, AccessControl, Pausable

**Title:**
AOXCLockManager

**Author:**
AOXC Core Engineering

Multi-batch asset locking engine for reputation mining and ecosystem power.

Integrated with 26-channel MonitoringHub and academic multiplier scaling.


## State Variables
### GOVERNANCE_ROLE

```solidity
bytes32 public constant GOVERNANCE_ROLE = keccak256("AOXC_GOVERNANCE_ROLE")
```


### SECURITY_ROLE

```solidity
bytes32 public constant SECURITY_ROLE = keccak256("AOXC_SECURITY_ROLE")
```


### AOXC

```solidity
IERC20 public immutable AOXC
```


### REPUTATION_MANAGER

```solidity
IReputationManager public immutable REPUTATION_MANAGER
```


### MONITORING_HUB

```solidity
IMonitoringHub public immutable MONITORING_HUB
```


### userLocks

```solidity
mapping(address => LockBatch[]) public userLocks
```


### totalValueLocked

```solidity
uint256 public totalValueLocked
```


### MIN_LOCK_DURATION

```solidity
uint256 public constant MIN_LOCK_DURATION = 7 days
```


### MAX_LOCK_DURATION

```solidity
uint256 public constant MAX_LOCK_DURATION = 1095 days
```


### PRECISION

```solidity
uint256 public constant PRECISION = 10000
```


## Functions
### constructor

Initializes the Lock Manager with ecosystem links.


```solidity
constructor(address _aoxc, address _rep, address _hub, address _admin) ;
```

### lock

Locks AOXC in specific batches to earn reputation and ecosystem power.


```solidity
function lock(uint256 _amount, uint256 _duration) external nonReentrant whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount to lock.|
|`_duration`|`uint256`|Duration in seconds.|


### unlock

Releases a matured lock batch.


```solidity
function unlock(uint256 _batchId) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_batchId`|`uint256`|The index of the lock batch.|


### _calculateWeight

Linear Multiplier Logic: 10% bonus per month.


```solidity
function _calculateWeight(uint256 _amount, uint256 _duration) internal pure returns (uint256);
```

### _reportToHub

Reporting to 26-channel DAO forensic hub.


```solidity
function _reportToHub(
    IMonitoringHub.Severity sev,
    string memory cat,
    string memory det,
    uint8 risk
) internal;
```

### getUserLockCount


```solidity
function getUserLockCount(address _user) external view returns (uint256);
```

### getUserLocks


```solidity
function getUserLocks(address _user) external view returns (LockBatch[] memory);
```

### pause


```solidity
function pause() external onlyRole(SECURITY_ROLE);
```

### unpause


```solidity
function unpause() external onlyRole(SECURITY_ROLE);
```

## Events
### AssetLocked

```solidity
event AssetLocked(
    address indexed user,
    uint256 indexed batchId,
    uint256 amount,
    uint256 duration,
    uint256 weight
);
```

### AssetUnlocked

```solidity
event AssetUnlocked(address indexed user, uint256 indexed batchId, uint256 amount);
```

### ReputationSyncFailed

```solidity
event ReputationSyncFailed(address indexed user, string reason);
```

## Structs
### LockBatch

```solidity
struct LockBatch {
    uint256 amount; // Locked AOXC amount
    uint256 startTime; // When the lock started
    uint256 unlockTime; // Maturity date
    uint256 weight; // Calculated multiplier weight (10000 = 1.0x)
    bool claimed; // Is the batch withdrawn?
}
```

