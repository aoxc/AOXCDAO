// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IRoleAuthority
 * @author AOXC Core Engineering
 * @notice Interface for the central access control and authority management.
 */
interface IRoleAuthority {
    // --- Events ---
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    // --- Core Functions ---

    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;

    // --- Special Authority Checks ---
    function isGuardian(address account) external view returns (bool);
    function isGovernor(address account) external view returns (bool);
    function isSentinel(address account) external view returns (bool);
}
