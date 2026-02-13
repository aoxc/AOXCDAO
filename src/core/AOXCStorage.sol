// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title AOXCStorage
 * @notice Centralized storage layout for AOXC token (ERC-7201 compliant).
 * @dev Provides upgrade-safe storage slots using Namespaced Storage Pattern.
 * Identity: "AOXC-DAO-V2-AKDENIZ-2026"
 */
library AOXCStorage {
    /**
     * @dev ERC-7201 Storage Slot calculation.
     * keccak256(abi.encode(uint256(keccak256("AOXC-DAO-V2-AKDENIZ-2026")) - 1)) & ~bytes32(uint256(0xff))
     */
    bytes32 private constant STORAGE_SLOT = keccak256(
        abi.encode(uint256(keccak256("AOXC-DAO-V2-AKDENIZ-2026")) - 1)
    ) & ~bytes32(uint256(0xff));

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
        bytes32 lastActionHash; // Son kritik işlemin izini storage'da tutmak için

        // --- Reserved Space for Future Upgrades ---
        // 38 olan gap, yeni eklediğimiz actionHash ile 37'ye düşürülmeli (toplam slot koruması)
        uint256[37] _gap;
    }

    /**
     * @dev Returns the storage layout for AOXC.
     */
    function layout() internal pure returns (MainStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            ds.slot := slot
        }
    }

    // --- Internal Helper Functions (Setters) ---

    function setEmergencyHalt(bool status) internal {
        layout().isEmergencyHalt = status;
    }

    function setPolicyEnforcement(bool status) internal {
        MainStorage storage ds = layout();
        ds.policyEnforcementActive = status;
        ds.lastPolicyChange = block.timestamp;
    }

    function setUpgradeAuthorizer(address newAuthorizer) internal {
        MainStorage storage ds = layout();
        ds.upgradeAuthorizer = newAuthorizer;
        ds.lastUpgradeTimestamp = block.timestamp;
    }

    function setTransferPolicy(address newPolicy) internal {
        MainStorage storage ds = layout();
        ds.transferPolicy = newPolicy;
        ds.lastPolicyChange = block.timestamp;
    }

    function setSupplyCap(uint256 newCap) internal {
        layout().supplyCap = newCap;
    }

    function excludeFromLimits(address account, bool status) internal {
        layout().isExcludedFromLimits[account] = status;
    }

    // --- Internal View Helpers ---

    function isExcluded(address account) internal view returns (bool) {
        return layout().isExcludedFromLimits[account];
    }

    function getSupplyCap() internal view returns (uint256) {
        return layout().supplyCap;
    }

    function getUpgradeNonce() internal view returns (uint256) {
        return layout().upgradeNonce;
    }

    function getLastUpgradeTimestamp() internal view returns (uint256) {
        return layout().lastUpgradeTimestamp;
    }

    function getPendingImplementation(uint256 nonce) internal view returns (address) {
        return layout().pendingImplementation[nonce];
    }
}
