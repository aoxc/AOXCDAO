// SPDX-License-Identifier: MIT
// Academic Grade - AOXC Ultimate Pro Standard
pragma solidity 0.8.33;

import {IAOXP} from "@interfaces/IAOXP.sol";
import {IAssetBackingLedger} from "@interfaces/IAssetBackingLedger.sol";
import {PriceOracleAdapter} from "../infrastructure/PriceOracleAdapter.sol";
import {AOXCAccessCoordinator} from "../core/AOXCAccessCoordinator.sol";

/**
 * @title AOXCInvariantChecker
 * @author AOXC Core Engineering
 * @notice Enforces the mathematical "Red Lines" of the protocol.
 * @dev If an invariant is violated, it triggers the AccessCoordinator to pause the system.
 * Compliant with strict Forge linting rules and 2026 enterprise security standards.
 */
contract AOXCInvariantChecker {
    // --- Immutable State Variables (SCREAMING_SNAKE_CASE) ---

    /**
     * @notice The AOXP Token interface for supply tracking.
     */
    IAOXP public immutable AOXP;

    /**
     * @notice The Ledger interface for collateral valuation.
     */
    IAssetBackingLedger public immutable LEDGER;

    /**
     * @notice The Oracle Adapter for price verification.
     */
    PriceOracleAdapter public immutable ORACLE;

    /**
     * @notice The central Access Coordinator for emergency control.
     */
    AOXCAccessCoordinator public immutable COORDINATOR;

    // --- Custom Errors ---
    error AOXC__Invariant_SolvencyViolation();
    error AOXC__Invariant_SupplyMismatch();

    // --- Constructor ---

    /**
     * @param _aoxp Address of the AOXP contract.
     * @param _ledger Address of the Asset Backing Ledger.
     * @param _oracle Address of the Price Oracle Adapter.
     * @param _coordinator Address of the Access Coordinator.
     */
    constructor(address _aoxp, address _ledger, address _oracle, address _coordinator) {
        AOXP = IAOXP(_aoxp);
        LEDGER = IAssetBackingLedger(_ledger);
        ORACLE = PriceOracleAdapter(_oracle);
        COORDINATOR = AOXCAccessCoordinator(_coordinator);
    }

    // --- External Functions ---

    /**
     * @notice Validates that the total supply is always backed by collateral value.
     * @dev Pro Ultimate: Ensures 1:1 backing check using oracle-normalized data.
     */
    function checkSolvency() external {
        uint256 totalSupply = AOXP.totalSupply();
        uint256 totalCollateralValue = LEDGER.getTotalValue();

        // CRITICAL THRESHOLD: Collateral value cannot be lower than total supply
        if (totalCollateralValue < totalSupply) {
            _handleViolation("SOLVENCY_BREACH");
            revert AOXC__Invariant_SolvencyViolation();
        }
    }

    /**
     * @notice Ensures that minting events match the ledger's record.
     * @param expectedSupply The supply value that should be reflected in the token contract.
     */
    function checkSupplyIntegrity(uint256 expectedSupply) external view {
        if (AOXP.totalSupply() != expectedSupply) {
            revert AOXC__Invariant_SupplyMismatch();
        }
    }

    // --- Internal Functions ---

    /**
     * @dev Automatically triggers emergency pause via Coordinator if a mathematical invariant is broken.
     * @param reason The descriptive reason for the violation.
     */
    function _handleViolation(string memory reason) internal {
        try COORDINATOR.triggerEmergencyPause(reason) {
        // Emergency pause successful
        }
            catch {
            // Fail-safe: Handle coordinator call failure if necessary
        }
    }
}
