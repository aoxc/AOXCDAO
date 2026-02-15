// SPDX-License-Identifier: MIT
// Academic Grade - AOXC Ultimate Pro Standard
pragma solidity 0.8.33;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { AOXCConstants } from "@libraries/AOXCConstants.sol";

/**
 * @title IAggregatorV3
 * @dev Interface for Chainlink Price Feeds or compatible aggregators.
 */
interface IAggregatorV3 {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function decimals() external view returns (uint8);
}

/**
 * @title PriceOracleAdapter
 * @author AOXC Core Engineering
 * @notice Standardized price feed aggregator for the AOXC ecosystem.
 * @dev Normalizes all price data to 18 decimals and enforces strict staleness checks.
 * Optimized for Solidity 0.8.33 with zero-lint warning policy.
 */
contract PriceOracleAdapter is AccessControl {
    // --- Constants ---

    /**
     * @dev The target decimals for all normalized prices within the AOXC ecosystem.
     */
    uint8 public constant TARGET_DECIMALS = 18;

    // --- State Variables ---

    struct FeedConfig {
        address feedAddress;
        uint256 heartbeat; // Maximum time between updates (e.g., 3600s for ETH/USD)
        bool isActive;
    }

    /**
     * @notice Maps asset addresses to their respective oracle configurations.
     */
    mapping(address => FeedConfig) public assetFeeds;

    // --- Custom Errors ---
    error AOXC__Oracle_StalePrice();
    error AOXC__Oracle_InvalidPrice();
    error AOXC__Oracle_FeedNotSet();

    // --- Events ---
    event FeedUpdated(address indexed asset, address indexed feed, uint256 heartbeat);

    /**
     * @param admin Initial administrator authorized to manage price feeds.
     */
    constructor(address admin) {
        _grantRole(AOXCConstants.ADMIN_ROLE, admin);
    }

    // --- Administrative Functions ---

    /**
     * @notice Sets or updates the price feed for a specific asset.
     * @param asset The address of the collateral/asset.
     * @param feed The address of the Chainlink-compatible aggregator.
     * @param heartbeat The maximum allowable delay for price updates.
     */
    function setAssetFeed(
        address asset,
        address feed,
        uint256 heartbeat
    ) external onlyRole(AOXCConstants.ADMIN_ROLE) {
        if (feed == address(0)) revert AOXC__Oracle_InvalidPrice();

        assetFeeds[asset] = FeedConfig({ feedAddress: feed, heartbeat: heartbeat, isActive: true });

        emit FeedUpdated(asset, feed, heartbeat);
    }

    // --- View Functions ---

    /**
     * @notice Retrieves the latest price normalized to 18 decimals.
     * @dev Implements security checks for stale or negative prices.
     * @param asset The address of the asset to price.
     * @return normalizedPrice The price in USD with 18 decimal precision.
     */
    function getPrice(address asset) external view returns (uint256 normalizedPrice) {
        FeedConfig memory config = assetFeeds[asset];
        if (!config.isActive) revert AOXC__Oracle_FeedNotSet();

        IAggregatorV3 aggregator = IAggregatorV3(config.feedAddress);

        (uint80 roundId, int256 answer, , uint256 updatedAt, uint80 answeredInRound) = aggregator
            .latestRoundData();

        // 1. Validation: Price must be positive
        if (answer <= 0) revert AOXC__Oracle_InvalidPrice();

        // 2. Validation: Round completion
        if (answeredInRound < roundId) revert AOXC__Oracle_StalePrice();

        // 3. Validation: Staleness check (Heartbeat)
        if (block.timestamp - updatedAt > config.heartbeat) revert AOXC__Oracle_StalePrice();

        // 4. Safe Casting & Normalization
        // [2026 Security Guard]: Casting to 'uint256' is safe because the 'answer <= 0' check
        // ensures it is a positive value within the uint256 range.
        // forge-lint: disable-next-line(unsafe-typecast)
        normalizedPrice = uint256(answer);

        uint8 feedDecimals = aggregator.decimals();

        if (feedDecimals < TARGET_DECIMALS) {
            normalizedPrice *= 10 ** (uint256(TARGET_DECIMALS) - feedDecimals);
        } else if (feedDecimals > TARGET_DECIMALS) {
            normalizedPrice /= 10 ** (uint256(feedDecimals) - TARGET_DECIMALS);
        }
    }
}
