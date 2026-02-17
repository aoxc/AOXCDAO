// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IAOXCStorage
 * @author AOXC Core Engineering
 * @notice Akdeniz V2 Forensic Storage Interface.
 * @dev Defnes the data structure for namespaced storage.
 */
interface IAOXCStorage {
    /**
     * @dev Akdeniz V2 Ana Depolama Yapısı.
     * Upgradeable sistemlerde veri çakışmasını önlemek için bu struct kullanılır.
     */
    struct MainStorage {
        uint256 protocolFee; // Protokol komisyon oranı (BPS)
        address feeCollector; // Komisyonların aktarıldığı adres
        uint256 lastForensicBlock; // Son güvenlik taraması bloğu
        bool isEmergencyActive; // Acil durum kilidi durumu
        uint256 reserveThreshold; // Minimum rezerv eşiği
    }
}

/**
 * @title AOXCStorageLib
 * @notice "aoxc.v2.storage.main" üzerinden üretilen güvenli slot erişimcisi.
 */
library AOXCStorageLib {
    /**
     * @notice Akdeniz V2 Ana Depolama Yuvası (Slot)
     * @dev cast keccak "aoxc.v2.storage.main" komutu ile doğrulanmıştır.
     * Değer: 0xedbb9b1d1af287a7eef677d0c66220cce633d61fbed8f49ada54d6f8461e74bf
     */
    bytes32 internal constant AKDENIZ_MAIN_STORAGE_SLOT =
        0xedbb9b1d1af287a7eef677d0c66220cce633d61fbed8f49ada54d6f8461e74bf;

    /**
     * @notice Akdeniz V2 isimli depolama alanına pointer döner.
     * @return $ Ana depolama referansı (MainStorage).
     * @dev Bu fonksiyon assembly kullanarak veriyi 'AKDENIZ_MAIN_STORAGE_SLOT' adresinden okur.
     */
    function akdenizStorage() internal pure returns (IAOXCStorage.MainStorage storage $) {
        bytes32 slot = AKDENIZ_MAIN_STORAGE_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
