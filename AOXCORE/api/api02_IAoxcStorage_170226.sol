// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IAOXCStorage
 * @author AOXCDAO Institutional Engineering
 * @notice Akdeniz V2 Forensic Storage Interface.
 * @dev Namespaced Storage (ERC-7201) structure for institutional data.
 */
interface IAOXCStorage {
    /**
     * @notice Structural layout for the main protocol storage.
     * @param protocolFee Protocol transaction fee in BPS.
     * @param lastForensicBlock Last security scan block number.
     * @param reserveThreshold Minimum required reserve threshold.
     * @param feeCollector Institutional address for fee collection.
     * @param isEmergencyActive Global circuit breaker status.
     */
    struct MainStorage {
        uint256 protocolFee;
        uint256 lastForensicBlock;
        uint256 reserveThreshold;
        address feeCollector;
        bool isEmergencyActive;
    }
}

/**
 * @title AOXCStorageLib
 * @author AOXCDAO Institutional Engineering
 * @notice Library for accessing Akdeniz V2 namespaced storage.
 */
library AOXCStorageLib {
    /**
     * @notice Storage slot seed for "aoxc.v2.storage.main".
     * @dev Value: keccak256("aoxc.v2.storage.main")
     */
    bytes32 internal constant AKDENIZ_MAIN_STORAGE_SLOT =
        0xedbb9b1d1af287a7eef677d0c66220cce633d61fbed8f49ada54d6f8461e74bf;

    /**
     * @notice Returns the storage pointer for the main protocol state.
     * @dev Solhint 'no-inline-assembly' is disabled due to ERC-7201 requirements.
     * @return store Reference to the MainStorage struct in storage.
     */
    function akdenizStorage() internal pure returns (IAOXCStorage.MainStorage storage store) {
        bytes32 slot = AKDENIZ_MAIN_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            store.slot := slot
        }
    }
}
