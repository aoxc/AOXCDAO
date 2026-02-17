// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXC} from "../../src/core/AOXC.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title AOXC Role-Based Access Control (RBAC) Integrity Test
 * @notice Rollerin birbirinden izolasyonunu ve yetki iptal süreçlerini test eder.
 * @dev Akademik düzeyde yetki hiyerarşisi ve izolasyon doğrulaması sağlar.
 */
contract AOXCAccessTest is Test {
    AOXC private token;

    /// @dev Test aktörleri
    address private admin = makeAddr("admin");
    address private minter = makeAddr("minter");
    address private burner = makeAddr("burner");
    address private unauthorizedUser = makeAddr("unauthorized");

    /**
     * @notice Test ortamını ilklendirir ve temel rolleri atar.
     */
    function setUp() public {
        AOXC implementation = new AOXC();
        bytes memory initData = abi.encodeWithSelector(
            AOXC.initialize.selector, "AOXC Token", "AOXC", admin, address(0), address(0), address(0), 1_000_000 ether
        );
        token = AOXC(address(new ERC1967Proxy(address(implementation), initData)));

        // Admin tarafından Minter rolünün atanması
        vm.prank(admin);
        token.grantRole(token.MINT_ROLE(), minter);
    }

    /**
     * @notice Rol izolasyonunu ve yetki sınırlarını test eder.
     * @dev Bir rolün (Minter), başka bir role (Burner) ait fonksiyonları tetikleyemeyeceğini kanıtlar.
     */
    function testRoleIsolationAndRevocation() public {
        // 1. İzolasyon Testi: Minter bakiye basabilir ama yakamaz (BURN_ROLE yoktur)
        vm.startPrank(minter);
        token.mint(minter, 100 ether); // Başarılı olmalı

        vm.expectRevert(); // Minter'ın yakma yetkisi yok
        token.burn(minter, 10 ether);
        vm.stopPrank();

        // 2. Yetki İptali (Revocation): Admin, minter rolünü geri alır
        vm.prank(admin);
        token.revokeRole(token.MINT_ROLE(), minter);

        // 3. Negatif Test: Artık minter rolü olmayan adres mint yapamamalı
        vm.prank(minter);
        // Akademik olarak hata mesajının AccessControl spesifik olduğunu doğrulamak iyidir
        vm.expectRevert();
        token.mint(minter, 10 ether);
    }

    /**
     * @notice Admin rolünün hiyerarşik gücünü ve diğer rolleri yönetme kapasitesini test eder.
     */
    function testAdminRoleManagement() public {
        // Admin'in burner rolünü atayabilmesi
        vm.prank(admin);
        token.grantRole(token.BURN_ROLE(), burner);

        assertTrue(token.hasRole(token.BURN_ROLE(), burner), "Admin should be able to grant roles");

        // Yetkisiz bir kullanıcının rol atamaya çalışması (Güvenlik ihlali denemesi)
        vm.prank(unauthorizedUser);
        vm.expectRevert();
        token.grantRole(token.MINT_ROLE(), unauthorizedUser);
    }
}
