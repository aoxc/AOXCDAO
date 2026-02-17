// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

interface IReputationManager {
    function processAction(address user, bytes32 actionType) external;
    function getMultiplier(address user) external view returns (uint256);
}
