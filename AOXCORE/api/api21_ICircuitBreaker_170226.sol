// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title ICircuitBreaker
 * @notice Interface for the global emergency shutdown and volatility protection.
 */
interface ICircuitBreaker {
    function isProtocolPaused() external view returns (bool);
    function checkVolatility(address asset) external view returns (bool);
    function triggerGlobalLock() external;
}
