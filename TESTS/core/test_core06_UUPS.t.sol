// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXC} from "../../src/core/AOXC.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title AOXC UUPS Upgrade Security Test Suite
 * @notice Yükseltilebilirlik (upgradability) mekanizmasının yetkilendirme katmanını test eder.
 * @dev OpenZeppelin 5.x UUPS standartlarına uygun olarak tasarlanmıştır.
 */
contract AOXCUpgradeTest is Test {
    /// @notice Proxy üzerinden erişilen AOXC token örneği
    AOXC private proxyToken;

    /// @dev Test rolleri
    address private admin = makeAddr("admin");
    address private attacker = makeAddr("attacker");

    /**
     * @notice Test ortamını hazırlar; ilk implementasyonu ve proxy'yi deploy eder.
     */
    function setUp() public {
        // 1. V1 Implementation Deploy
        AOXC implementation = new AOXC();

        // 2. Initialization Verisi
        bytes memory initData = abi.encodeWithSelector(
            AOXC.initialize.selector, "AOXC Token", "AOXC", admin, address(0), address(0), address(0), 1_000_000 ether
        );

        // 3. Proxy Deploy: V1'e yönlendirilir
        proxyToken = AOXC(address(new ERC1967Proxy(address(implementation), initData)));
    }

    /**
     * @notice Yükseltme yetkisinin (UPGRADER_ROLE) erişim kontrolünü doğrular.
     * @dev Akademik bir güvenlik testi olarak hem yetkisiz erişimi (negative test)
     * hem de yetkili erişimi (positive test) kapsar.
     */
    function testUpgradeAccessControl() public {
        // Yeni bir mantık (implementation) kontratı deploy et (V2 olarak düşünelim)
        AOXC newImplementation = new AOXC();

        // SENARYO 1: Yetkisiz bir adres (Attacker) yükseltme yapmaya çalışır
        vm.prank(attacker);
        // Not: OpenZeppelin AccessControl hata mesajı veya özel AOXC hatası beklenir
        vm.expectRevert();
        proxyToken.upgradeToAndCall(address(newImplementation), "");

        // SENARYO 2: Yetkili adres (Admin) yükseltme yapar
        // Admin'in setUp aşamasında UPGRADER_ROLE aldığı varsayılmaktadır.
        vm.prank(admin);
        proxyToken.upgradeToAndCall(address(newImplementation), "");

        // Başarılı yükseltme sonrası yeni implementasyonun adresi kontrol edilebilir
        // (ERC1967 depolama slotu olan 0x360... üzerinden kontrol akademik bir yaklaşımdır)
        bytes32 implementationSlot =
            vm.load(address(proxyToken), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
        assertEq(
            address(uint160(uint256(implementationSlot))), address(newImplementation), "Upgrade verification failed"
        );
    }

    /**
     * @notice Yükseltme sırasında veri bütünlüğünün (state persistence) korunduğunu test eder.
     */
    function testStatePersistenceAfterUpgrade() public {
        // Önce bir bakiye oluşturalım
        address user = makeAddr("user");
        vm.prank(admin);
        token().mint(user, 500 ether);

        // Yükseltme yap
        AOXC v2Impl = new AOXC();
        vm.prank(admin);
        proxyToken.upgradeToAndCall(address(v2Impl), "");

        // Bakiye hala yerinde mi? (EVM depolama alanı değişmemeli)
        assertEq(token().balanceOf(user), 500 ether, "State lost during upgrade");
    }

    /// @dev Yardımcı fonksiyon: proxyToken'ı AOXC tipinde döndürür
    function token() internal view returns (AOXC) {
        return proxyToken;
    }
}
