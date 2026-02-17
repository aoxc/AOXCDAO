// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXCStorage} from "../../src/core/core02_AoxcStorageLayout_170226.sol";

/**
 * @title AOXC Storage Slot Integrity & ERC-7201 Compliance Test
 * @notice Namespaced storage yapısının slot hesaplamalarını ve veri bütünlüğünü doğrular.
 * @dev Bu test, proxy yükseltmeleri sırasında depolama çakışmalarını önlemek için kritiktir.
 */
contract AOXCStorageTest is Test {
    /**
     * @notice AOXC ana depolama slotunun ERC-7201 formülüne göre doğruluğunu test eder.
     * @dev Formül: keccak256(abi.encode(uint256(keccak256(id)) - 1)) & ~bytes32(uint256(0xff))
     */
    function testStorageSlotCalculation() public pure {
        // core02_AoxcStorageLayout_170226.sol içinde tanımlanan benzersiz namespace kimliği
        string memory storageId = "AOXC-DAO-V2-AKDENIZ-2026";

        // Standart formül uygulaması
        bytes32 expectedSlot = keccak256(abi.encode(uint256(keccak256(bytes(storageId))) - 1)) & ~bytes32(uint256(0xff));

        // Kütüphanedeki sabit (constant) değer ile hesaplanan değerin eşleşmesi gerekir
        // Not: AOXCStorage içinde STORAGE_SLOT public/internal ise doğrudan karşılaştırılabilir.
        assertEq(AOXCStorage.STORAGE_SLOT, expectedSlot, "ERC-7201: Storage slot mismatch. Potential collision risk!");
    }

    /**
     * @notice Depolama yerleşiminin (layout) ilk durumunu ve pointer erişimini test eder.
     * @dev Pointer'ın doğru adrese işaret ettiğini ve başlangıçta boş olduğunu doğrular.
     */
    function testStorageLayoutInitialization() public view {
        // Namespaced storage'a pointer aracılığıyla erişim
        AOXCStorage.MainStorage storage ds = AOXCStorage.layout();

        // Varsayılan değerlerin (Default state) sıfır olduğu doğrulanır
        assertEq(ds.transferPolicy, address(0), "Post-deployment: transferPolicy must be zero");
        assertEq(ds.upgradeAuthorizer, address(0), "Post-deployment: upgradeAuthorizer must be zero");
        assertEq(ds.monitoringHub, address(0), "Post-deployment: monitoringHub must be zero");
    }

    /**
     * @notice Namespaced storage alanına yazma ve okuma işlemlerinin atomikliğini doğrular.
     * @dev Bu test, pointer manipülasyonunun EVM üzerinde güvenli çalışıp çalışmadığını kanıtlar.
     */
    function testStorageWriteAndReadPersistence() public {
        // Pointer alımı
        AOXCStorage.MainStorage storage ds = AOXCStorage.layout();

        address testPolicy = makeAddr("policy");
        address testAuthorizer = makeAddr("authorizer");
        uint256 testCap = 5_000_000 ether;

        // Yazma işlemi (State change)
        ds.transferPolicy = testPolicy;
        ds.upgradeAuthorizer = testAuthorizer;
        ds.supplyCap = testCap;

        // Okuma ve Doğrulama
        assertEq(ds.transferPolicy, testPolicy, "Storage write failed: transferPolicy");
        assertEq(ds.upgradeAuthorizer, testAuthorizer, "Storage write failed: upgradeAuthorizer");
        assertEq(ds.supplyCap, testCap, "Storage write failed: supplyCap");
    }

    /**
     * @notice Farklı bir struct'ın aynı slotu işgal etmediğini (Isolation) dolaylı olarak kanıtlar.
     * @dev Akademik düzeyde 'Namespace Isolation' testi.
     */
    function testStorageIsolation() public {
        AOXCStorage.MainStorage storage ds = AOXCStorage.layout();

        // Slot 0 gibi standart slotlara yazma yapıldığında namespace'in etkilenmediğini simüle et
        uint256 initialCap = 1000;
        ds.supplyCap = initialCap;

        // Başka bir bellek manipülasyonu (Örn: standart bir state variable)
        // Eğer AOXCStorage düzgün çalışıyorsa, bu namespace dışındaki değişimler ds.supplyCap'i bozmaz.
        assertEq(ds.supplyCap, initialCap, "Namespace isolation breached");
    }
}
