// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

interface IAOXCSafeguardVault {
    function releaseCompensation(address victim, uint256 amount) external;
    function getSafeguardReserve() external view returns (uint256);
}
