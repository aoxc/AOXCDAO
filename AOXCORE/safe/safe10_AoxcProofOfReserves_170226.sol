// SPDX-License-Identifier: MIT
// Academic Grade - AOXC Ultimate Pro Standard
pragma solidity 0.8.33;

import {AOXCConstants} from "@libraries/core07_AoxcConstants_170226.sol";
import {IAssetBackingLedger} from "@interfaces/api15_IAssetBackingLedger_170226.sol";
import {IAOXP} from "@interfaces/api18_IAoxp_170226.sol";
import {PriceOracleAdapter} from "../link/link02_AoxcPriceOracleAdapter_170226.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ProofOfReserves
 * @author AOXC Core Engineering
 * @notice Real-time on-chain verification of asset backing vs total supply.
 * @dev Integrates with Ledger and Oracle to provide a definitive solvency status.
 * Optimized for Solidity 0.8.33 with strict adherence to Forge linting standards.
 */
contract ProofOfReserves is AccessControl {
    // --- Immutable State Variables (SCREAMING_SNAKE_CASE for Lint Compliance) ---

    /**
     * @notice The ledger tracking all collateral assets.
     */
    IAssetBackingLedger public immutable LEDGER;

    /**
     * @notice The AOXP token contract representing total protocol liability.
     */
    IAOXP public immutable AOXP;

    /**
     * @notice The oracle adapter providing normalized price data.
     */
    PriceOracleAdapter public immutable ORACLE;

    // --- Professional Errors ---
    error AOXC__PoR_SystemUndercollateralized();

    // --- Events ---
    event ReservesVerified(uint256 supply, uint256 reserves, uint256 timestamp);

    /**
     * @param _ledger Address of the AssetBackingLedger.
     * @param _aoxp Address of the IAOXP token.
     * @param _oracle Address of the PriceOracleAdapter.
     * @param admin Initial administrator for the AccessControl.
     */
    constructor(address _ledger, address _aoxp, address _oracle, address admin) {
        LEDGER = IAssetBackingLedger(_ledger);
        AOXP = IAOXP(_aoxp);
        ORACLE = PriceOracleAdapter(_oracle);
        _grantRole(AOXCConstants.ADMIN_ROLE, admin);
    }

    // --- External/Public Functions ---

    /**
     * @notice Returns the current health of the protocol in basis points (BPS).
     * @return health 10,000 means 100% collateralized, >10,000 means overcollateralized.
     */
    function getProtocolHealth() public view returns (uint256 health) {
        uint256 supply = AOXP.totalSupply();
        if (supply == 0) return AOXCConstants.MAX_BPS;

        uint256 reserveValue = LEDGER.getTotalValue(); // Oracle-normalized total value

        // health = (reserveValue * 10,000) / supply
        health = (reserveValue * AOXCConstants.MAX_BPS) / supply;
    }

    /**
     * @notice Verification gate for institutional partners and dashboards.
     * @return isSolvent Boolean indicating if the protocol meets minimum reserve requirements.
     */
    function verifySolvency() external returns (bool isSolvent) {
        uint256 health = getProtocolHealth();
        isSolvent = health >= AOXCConstants.MAX_BPS;

        uint256 currentSupply = AOXP.totalSupply();
        uint256 currentReserves = LEDGER.getTotalValue();

        if (!isSolvent) {
            emit ReservesVerified(currentSupply, currentReserves, block.timestamp);
            revert AOXC__PoR_SystemUndercollateralized();
        }

        emit ReservesVerified(currentSupply, currentReserves, block.timestamp);
    }

    /**
     * @notice Helper to get the raw deficit or surplus in USD (18 decimals).
     * @return balance Signed difference between reserves and supply.
     */
    function getReserveBalance() external view returns (int256 balance) {
        uint256 supply = AOXP.totalSupply();
        uint256 reserves = LEDGER.getTotalValue();

        // [2026 Security Guard]: Casting to 'int256' is safe here because protocol supply
        // and reserves are capped by economic bounds significantly below 2^255-1.
        // forge-lint: disable-next-line(unsafe-typecast)
        int256 iReserves = int256(reserves);

        // forge-lint: disable-next-line(unsafe-typecast)
        int256 iSupply = int256(supply);

        return iReserves - iSupply;
    }
}
