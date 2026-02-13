// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/// @title ISystemInvariant
/// @notice Defines system-wide invariants that must hold at all times
interface ISystemInvariant {
    /// @notice Total supply must always be fully backed by recorded assets
    function invariantTotalSupplyBacked() external view returns (bool);

    /// @notice All transfers must be subject to compliance and policy checks
    function invariantTransferPolicyEnforced() external view returns (bool);

    /// @notice Upgrades must preserve storage layout integrity
    function invariantStorageIntegrity() external view returns (bool);
}

