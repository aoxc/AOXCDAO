# IAOXCLockManager
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/IAOXCLockManager.sol)


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

