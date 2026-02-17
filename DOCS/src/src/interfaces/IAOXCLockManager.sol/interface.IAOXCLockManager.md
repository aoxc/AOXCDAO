# IAOXCLockManager
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/interfaces/IAOXCLockManager.sol)


## Functions
### lock


```solidity
function lock(uint256 amount, uint256 duration) external;
```

### unlock


```solidity
function unlock(uint256 batchId) external;
```

### getUserBatchCount


```solidity
function getUserBatchCount(address user) external view returns (uint256);
```

### getBatchInfo


```solidity
function getBatchInfo(address user, uint256 batchId)
    external
    view
    returns (uint256 amount, uint256 unlockTime, bool claimed);
```

### getUserLocks


```solidity
function getUserLocks(address user) external view returns (LockBatch[] memory);
```

## Structs
### LockBatch

```solidity
struct LockBatch {
    uint256 amount;
    uint256 startTime;
    uint256 unlockTime;
    uint256 weight;
    bool claimed;
}
```

