// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Test } from "forge-std/Test.sol";
import { AOXC } from "../../src/core/AOXC.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title AOXC Governance & Voting Power Test Suite
 * @notice Delegasyon, checkpoint yönetimi ve oy gücü dinamiklerini doğrular.
 * @dev OpenZeppelin 5.5.x ERC20Votes standartlarına ve Foundry en iyi pratiklerine uygundur.
 */
contract AOXCGovernanceTest is Test {
    /// @notice Proxy üzerinden erişilen AOXC token örneği
    AOXC private token;

    /// @dev Test kimlikleri
    address private admin = makeAddr("admin");
    address private user1 = makeAddr("user1");
    address private user2 = makeAddr("user2");

    /// @dev Test sabitleri
    uint256 private constant USER1_INITIAL_BALANCE = 1000 ether;
    uint256 private constant TRANSFER_AMOUNT = 400 ether;

    /**
     * @notice Test ortamını hazırlar; UUPS Proxy ve delegasyon desteğini kurar.
     */
    function setUp() public {
        // 1. Implementation Katmanı
        AOXC implementation = new AOXC();

        // 2. Initialization Verisi (OpenZeppelin 5.5.x standartları)
        bytes memory initData = abi.encodeWithSelector(
            AOXC.initialize.selector,
            "AOXC Token",
            "AOXC",
            admin,
            address(0), // Policy Engine pasif
            address(0), // Authorizer pasif
            address(0), // Monitoring Hub pasif
            1_000_000 ether
        );

        // 3. Proxy Deploy ve Interface Sarmalama
        token = AOXC(address(new ERC1967Proxy(address(implementation), initData)));

        // 4. İlk Likidite Sağlama
        vm.prank(admin);
        token.mint(user1, USER1_INITIAL_BALANCE);
    }

    /**
     * @notice Oy gücünün delegasyon ve token akışıyla uyumlu değiştiğini doğrular.
     * @dev ERC20Votes: Bakiye transferi oy gücünü otomatik taşımaz; delegasyon güncellenmelidir.
     */
    function testDelegationAndVotingPower() public {
        // Delegasyon öncesi oy gücü 0 olmalıdır (ERC20Votes standardı)
        assertEq(token.getVotes(user1), 0, "Initial votes must be zero before delegation");

        // User1 kendi kendine delege ederek oy gücünü aktif eder
        vm.prank(user1);
        token.delegate(user1);
        assertEq(token.getVotes(user1), USER1_INITIAL_BALANCE, "Self-delegation voting power mismatch");

        // Token transferi: Oy gücü otomatik olarak azalmalıdır (User1 hala kendine delege olduğu için)
        vm.prank(user1);
        bool success = token.transfer(user2, TRANSFER_AMOUNT);
        assertTrue(success, "Transfer should return true");
        
        assertEq(
            token.getVotes(user1),
            USER1_INITIAL_BALANCE - TRANSFER_AMOUNT,
            "Voting power should decrease proportionally after transfer"
        );

        // User2, aldığı bakiyenin oy gücünü tekrar User1'e yönlendirir
        vm.prank(user2);
        token.delegate(user1);

        // Toplam oy gücü tekrar başlangıç bakiyesine konsolide olmalıdır
        assertEq(token.getVotes(user1), USER1_INITIAL_BALANCE, "Votes should consolidate back to user1");
    }

    /**
     * @notice Tarihsel oy gücü kayıtlarının (Checkpoints) doğruluğunu test eder.
     * @dev Geçmiş bloklardaki oy gücü, yönetişim teklifleri için kritiktir.
     */
    function testVotingCheckpoints() public {
        // Blok 1: Delegasyon başlar
        vm.prank(user1);
        token.delegate(user1);
        
        uint256 snapshotBlock = block.number;
        
        // Blok 2: Zamanı ilerlet (Yeni bir checkpoint oluşması için)
        vm.roll(snapshotBlock + 1);
        
        // Blok 3: Bakiye değişimi
        vm.prank(admin);
        token.mint(user1, 500 ether);
        
        // Geçmişe dönük kontrol: Snapshot bloğundaki oy gücü değişmemiş olmalı
        assertEq(
            token.getPastVotes(user1, snapshotBlock), 
            USER1_INITIAL_BALANCE, 
            "Historical voting power must remain constant"
        );
        
        // Güncel oy gücü artmış olmalı
        assertEq(
            token.getVotes(user1), 
            USER1_INITIAL_BALANCE + 500 ether, 
            "Current voting power mismatch after mint"
        );
    }
}
