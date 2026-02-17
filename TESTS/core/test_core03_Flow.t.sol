// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXC} from "../../src/core/AOXC.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IMonitoringHub} from "../../src/interfaces/IMonitoringHub.sol";

/**
 * @title MonitoringHub (Academic Test Implementation)
 * @notice IMonitoringHub arayüzünün 26 kanallı struct yapısına tam uyumlu implementasyonu.
 * @dev Test ortamında gerçek kontrat davranışını simüle eder ve 'override' hatalarını giderir.
 */
contract MonitoringHub is IMonitoringHub {
    /**
     * @notice AOXC.sol tarafından çağrılan ana forensic fonksiyonu.
     * @dev Struct kullanımı, gerçek MonitoringHub ile %100 uyumludur.
     */
    function logForensic(ForensicLog calldata log) external override {
        // Test sırasında loglar izlenebilir
    }

    /**
     * @notice Güvenlik uyarılarını işleyen fonksiyon.
     */
    function getRecordCount() external view override returns (uint256) {
        return 0;
    }

    function isMonitoringActive() external view override returns (bool) {
        return true;
    }

    function isMonitoringActive() external view override returns (bool) {
        return true;
    }

    function getRecordCount() external view override returns (uint256) {
        return 0;
    }
    function logSecurityAlert(string calldata reason, IMonitoringHub.Severity severity) external override {}

    /**
     * @notice Belirli bir kaydı döndüren fonksiyon.
     * @dev Dönüş tipi arayüzdeki ForensicLog memory yapısıyla eşleşmek zorundadır (Hata 4822 çözümü).
     */
    function getRecord(uint256) external view override returns (ForensicLog memory) {
        ForensicLog memory emptyLog;
        return emptyLog;
    }

    function getRecordCount() external view override returns (uint256) {
        return 0;
    }

    function isMonitoringActive() external view override returns (bool) {
        return true;
    }
}

/**
 * @title AOXC Transfer & Flow Control Test Suite
 * @notice ERC20 transfer limitlerini, duraklatma mekanizmalarını ve akış kontrolünü test eder.
 * @dev Foundry 'vm.prank' ve 'vm.expectRevert' özelliklerini kullanarak asimetrik testler gerçekleştirir.
 */
contract AOXCTransferTest is Test {
    AOXC private token;
    MonitoringHub private hub;

    address private admin = makeAddr("admin");
    address private user1 = makeAddr("user1");
    address private user2 = makeAddr("user2");

    uint256 private constant INITIAL_MINT = 100 ether;
    uint256 private constant MAX_CAP = 1_000_000 ether;

    /**
     * @notice Test ortamını hazırlar. UUPS Proxy mimarisini ve Hub bağlantısını kurar.
     */
    function setUp() public {
        // 1. Concrete Hub Deployment
        hub = new MonitoringHub();

        // 2. Logic Layer Deployment
        AOXC implementation = new AOXC();

        // 3. Initialization Vector (Academic Standard)
        bytes memory initData = abi.encodeWithSelector(
            AOXC.initialize.selector,
            "AOXC Token",
            "AOXC",
            admin,
            address(0), // PolicyEngine (Test kapsamında devre dışı)
            address(0), // Authorizer
            IMonitoringHub(address(hub)),
            MAX_CAP
        );

        // 4. ERC1967 Proxy Deployment & Wrapping
        token = AOXC(address(new ERC1967Proxy(address(implementation), initData)));

        // 5. Initial Liquidity Provision
        vm.prank(admin);
        token.mint(user1, INITIAL_MINT);
    }

    /**
     * @notice Standart ERC20 transfer işleminin doğruluğunu test eder.
     */
    function testTransferSuccess() public {
        uint256 transferAmount = 50 ether;

        vm.prank(user1);
        bool success = token.transfer(user2, transferAmount);

        assertTrue(success, "Transfer should succeed");
        assertEq(token.balanceOf(user1), INITIAL_MINT - transferAmount);
        assertEq(token.balanceOf(user2), transferAmount);
    }

    /**
     * @notice Acil durum durdurma (Emergency Halt) mekanizmasının transferleri engellediğini kanıtlar.
     * @dev Circuit-breaker pattern doğrulaması.
     */
    function testTransferRevertsOnEmergencyHalt() public {
        vm.prank(admin);
        token.toggleEmergencyHalt(true);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("AOXC__EmergencyHaltActive()"));
        token.transfer(user2, 10 ether);
    }

    /**
     * @notice Sistemin acil durum sonrası normale dönebildiğini doğrular.
     */
    function testTransferResumesAfterEmergencyHaltDisabled() public {
        vm.startPrank(admin);
        token.toggleEmergencyHalt(true);
        token.toggleEmergencyHalt(false);
        vm.stopPrank();

        vm.prank(user1);
        bool success = token.transfer(user2, 20 ether);

        assertTrue(success, "Transfer should resume after halt is disabled");
    }

    /**
     * @notice Yetersiz bakiye durumunda işlemin atomik olarak iptal edildiğini test eder.
     */
    function testTransferInsufficientBalanceReverts() public {
        uint256 overBalance = INITIAL_MINT + 1 ether;

        vm.prank(user1);
        vm.expectRevert(); // ERC20 level revert
        token.transfer(user2, overBalance);
    }
}
