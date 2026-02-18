// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title AOXCStorage
 * @notice Centralized storage layout for AOXCMainEngine token (ERC-7201 compliant).
 * @dev Provides upgrade-safe storage slots using Namespaced Storage Pattern.
 * Identity: "AOXCMainEngine-DAO-V2-AKDENIZ-2026"
 */
library AOXCStorage {
    /**
     * @dev ERC-7201 Storage Slot calculation.
     * keccak256(abi.encode(uint256(keccak256("AOXCMainEngine-DAO-V2-AKDENIZ-2026")) - 1)) & ~bytes32(uint256(0xff))
     */
    bytes32 internal constant STORAGE_SLOT = 0x367f3747805167389a19c11867e3a34a17951a37651a148972b260907d083100; // Pre-calculated for performance

    /// @custom:storage-location erc7201:AOXCMainEngine-DAO-V2-AKDENIZ-2026
    struct MainStorage {
        // --- Governance & Policy ---
        address transferPolicy;
        address upgradeAuthorizer;
        bool policyEnforcementActive;
        bool isEmergencyHalt;
        // --- Metadata & Timestamps ---
        uint256 lastUpgradeTimestamp;
        uint256 lastPolicyChange;
        // --- Supply Management ---
        uint256 supplyCap;
        mapping(address => bool) isExcludedFromLimits;
        // --- Upgrade Authorization State (Multi-sig/Consensus) ---
        uint256 upgradeNonce;
        mapping(uint256 => mapping(address => bool)) upgradeApprovals;
        mapping(uint256 => uint256) approvalCounts;
        mapping(uint256 => address) pendingImplementation;
        // --- Forensic Tracking ---
        bytes32 lastActionHash;
        // --- Reserved Space for Future Upgrades ---
        uint256[37] _gap;
    }

    /**
     * @dev Returns the storage layout for AOXCMainEngine.
     * Renamed from 'layout' to 'getMainStorage' to avoid parser conflicts in Forge Doc.
     */
    function getMainStorage() internal pure returns (MainStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            ds.slot := slot
        }
    }

    // --- Internal Helper Functions (Setters) ---

    function setEmergencyHalt(bool status) internal {
        getMainStorage().isEmergencyHalt = status;
    }

    function setPolicyEnforcement(bool status) internal {
        MainStorage storage ds = getMainStorage();
        ds.policyEnforcementActive = status;
        ds.lastPolicyChange = block.timestamp;
    }

    function setUpgradeAuthorizer(address newAuthorizer) internal {
        MainStorage storage ds = getMainStorage();
        ds.upgradeAuthorizer = newAuthorizer;
        ds.lastUpgradeTimestamp = block.timestamp;
    }

    function setTransferPolicy(address newPolicy) internal {
        MainStorage storage ds = getMainStorage();
        ds.transferPolicy = newPolicy;
        ds.lastPolicyChange = block.timestamp;
    }

    function setSupplyCap(uint256 newCap) internal {
        getMainStorage().supplyCap = newCap;
    }

    function excludeFromLimits(address account, bool status) internal {
        getMainStorage().isExcludedFromLimits[account] = status;
    }

    // --- Internal View Helpers ---

    function isExcluded(address account) internal view returns (bool) {
        return getMainStorage().isExcludedFromLimits[account];
    }

    function getSupplyCap() internal view returns (uint256) {
        return getMainStorage().supplyCap;
    }

    function getUpgradeNonce() internal view returns (uint256) {
        return getMainStorage().upgradeNonce;
    }

    function getLastUpgradeTimestamp() internal view returns (uint256) {
        return getMainStorage().lastUpgradeTimestamp;
    }

    function getPendingImplementation(uint256 nonce) internal view returns (address) {
        return getMainStorage().pendingImplementation[nonce];
    }
}
