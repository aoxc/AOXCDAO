// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/// @title ISecurityAssumptions
/// @notice Explicit security assumptions relied upon by the protocol
interface ISecurityAssumptions {
    /// @notice Guardians are assumed to act honestly within defined emergency procedures
    function assumesGuardianHonesty() external pure returns (bool);

    /// @notice Governance actions are assumed to respect enforced timelock constraints
    function assumesTimelockRespected() external pure returns (bool);

    /// @notice External bridge infrastructure is assumed to validate messages correctly
    function assumesBridgeIntegrity() external pure returns (bool);
}
