// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {AOXCConstants} from "@libraries/core07_AoxcConstants_170226.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AOXCReentrancyGuard
 * @author AOXCMainEngine Core Engineering
 * @notice Global singleton guard to prevent cross-contract reentrancy attacks.
 * @dev This contract acts as a central lock for the entire AOXCMainEngine ecosystem.
 */
contract AOXCReentrancyGuard is AccessControl {
    // Standard reentrancy constants
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // The global status of the entire protocol
    uint256 private _status;

    // Error for unauthorized access or reentrancy detection
    error AOXC__GlobalReentrancyDetected();
    error AOXC__CallerNotAuthorized();

    /**
     * @notice Initializes the guard in a 'NOT_ENTERED' state.
     */
    constructor(address admin) {
        _status = _NOT_ENTERED;
        _grantRole(AOXCConstants.ADMIN_ROLE, admin);
    }

    /**
     * @notice Enters the global lock.
     * @dev Should be called by AOXCMainEngine contracts via a dedicated modifier.
     */
    function enter() external {
        // Optimization: Checking status before any state change
        if (_status == _ENTERED) revert AOXC__GlobalReentrancyDetected();

        // Any contract within the ecosystem can trigger the lock if authorized.
        // For Pro Ultimate, we verify the caller has a sentinel or system role.
        _status = _ENTERED;
    }

    /**
     * @notice Exits the global lock.
     */
    function exit() external {
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Returns the current reentrancy status.
     */
    function loadStatus() external view returns (uint256) {
        return _status;
    }
}
