// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

interface IAOXCLockManager {
    struct LockBatch {
        uint256 amount;
        uint256 startTime;
        uint256 unlockTime;
        uint256 weight;
        bool claimed;
    }

    function lock(uint256 amount, uint256 duration) external;
    function unlock(uint256 batchId) external;
    function getUserBatchCount(address user) external view returns (uint256);
    function getBatchInfo(
        address user,
        uint256 batchId
    ) external view returns (uint256 amount, uint256 unlockTime, bool claimed);
    function getUserLocks(address user) external view returns (LockBatch[] memory);
}
