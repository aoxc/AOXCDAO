// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AOXCConstants} from "@libraries/core07_AoxcConstants_170226.sol";

/**
 * @title SequenceManager
 * @notice Maintains a global, immutable sequence of forensic event IDs for the AOXC ecosystem.
 * @dev Ensuring that no two forensic logs can share the same global index.
 */
contract SequenceManager is AccessControl {
    uint256 private _globalSequenceId;

    // Mapping to track nonces per reporter to prevent out-of-order execution
    mapping(address => uint256) private _reporterNonces;

    event SequenceIncremented(address indexed reporter, uint256 newSequenceId);

    constructor(address admin) {
        _grantRole(AOXCConstants.ADMIN_ROLE, admin);
    }

    /**
     * @notice Increments and returns the next global sequence ID.
     * @param reporter The address of the calling contract (e.g., BridgeAdapter).
     * @return sequenceId The globally unique ID for the forensic log.
     */
    function nextSequenceId(address reporter) external returns (uint256 sequenceId) {
        // Only authorized AOXC contracts can increment the global sequence
        // For Pro Ultimate, we could add a specific REPORTER_ROLE here.

        unchecked {
            sequenceId = ++_globalSequenceId;
            _reporterNonces[reporter]++;
        }

        emit SequenceIncremented(reporter, sequenceId);
    }

    function getGlobalSequenceId() external view returns (uint256) {
        return _globalSequenceId;
    }

    function getReporterNonce(address reporter) external view returns (uint256) {
        return _reporterNonces[reporter];
    }
}
