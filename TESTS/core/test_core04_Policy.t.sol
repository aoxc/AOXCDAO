// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXC} from "../../src/core/AOXC.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IMonitoringHub} from "../../src/interfaces/IMonitoringHub.sol";
import {ITransferPolicy} from "../../src/interfaces/ITransferPolicy.sol";

/**
 * @title AOXCTransferPolicyEngine
 * @notice Real implementation of the transfer policy for integration testing.
 * @dev Full detailed implementation using OpenZeppelin 5.5.x compatible patterns.
 */
contract AOXCTransferPolicyEngine is ITransferPolicy {
    address public admin;
    bool public isActive;
    mapping(address => bool) public blacklisted;

    error Policy__Blacklisted(address account);
    error Policy__NotAuthorized();

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Policy__NotAuthorized();
        _;
    }

    constructor(address _admin) {
        admin = _admin;
        isActive = true;
    }

    /**
     * @notice Validates the transfer based on real-time blacklist and status.
     * @inheritdoc ITransferPolicy
     */
    function validateTransfer(
        address from,
        address to,
        uint256 /* amount */
    )
        external
        view
        override
    {
        if (!isActive) return;
        if (blacklisted[from]) revert Policy__Blacklisted(from);
        if (blacklisted[to]) revert Policy__Blacklisted(to);
    }

    /**
     * @notice Updates the blacklist status for a specific account.
     */
    function setBlacklist(address account, bool status) external onlyAdmin {
        blacklisted[account] = status;
    }

    /**
     * @notice Toggles the policy enforcement status.
     */
    function setPolicyActive(bool _active) external override onlyAdmin {
        isActive = _active;
    }

    function isPolicyActive() external view override returns (bool) {
        return isActive;
    }

    function policyName() external pure override returns (string memory) {
        return "AOXC_Core_Compliance_Engine";
    }

    function policyVersion() external pure override returns (uint256) {
        return 1;
    }

    function updatePolicyParameter(string calldata, uint256) external override onlyAdmin {
        // Dynamic policy adjustments logic
    }
}

/**
 * @title AOXCTransferPolicyTest
 * @notice Full integration test for AOXC Policy enforcement.
 * @dev Validates the handshake between ERC20 flows and the Policy Engine.
 */
contract AOXCTransferPolicyTest is Test {
    AOXC private token;
    AOXCTransferPolicyEngine private policyEngine;

    address private admin = makeAddr("admin");
    address private user1 = makeAddr("user1");
    address private user2 = makeAddr("user2");
    address private hubAddr = makeAddr("monitoringHub");

    uint256 private constant INITIAL_CAP = 1_000_000 ether;

    function setUp() public {
        // 1. Policy Engine Deployment
        policyEngine = new AOXCTransferPolicyEngine(admin);

        // 2. Implementation Deployment
        AOXC implementation = new AOXC();

        // 3. Proxy Initialization
        bytes memory initData = abi.encodeWithSelector(
            AOXC.initialize.selector,
            "AOXC Token",
            "AOXC",
            admin,
            address(policyEngine),
            address(0),
            IMonitoringHub(hubAddr),
            INITIAL_CAP
        );

        token = AOXC(address(new ERC1967Proxy(address(implementation), initData)));

        // 4. Provisioning
        vm.prank(admin);
        token.mint(user1, 100 ether);
    }

    /**
     * @notice Blacklist mekanizmasının transferi engellediğini doğrular.
     * @dev DÜZELTME: vm.expectRevert kullanıldığında işlem duracağı için success kontrolü kaldırıldı.
     */
    function testIntegrationBlacklistBlocksTransfer() public {
        // User1'i kara listeye al
        vm.prank(admin);
        policyEngine.setBlacklist(user1, true);

        // Transferin AOXC__PolicyViolation ile iptal edilmesini bekle
        vm.prank(user1);
        vm.expectRevert(AOXC.AOXC__PolicyViolation.selector);
        token.transfer(user2, 10 ether);
    }

    /**
     * @notice Politika ihlali olmayan durumlarda transferin başarısını doğrular.
     */
    function testIntegrationSuccessfulTransfer() public {
        vm.prank(user1);
        bool success = token.transfer(user2, 50 ether);

        assertTrue(success, "Transfer should return true");
        assertEq(token.balanceOf(user1), 50 ether, "Sender balance mismatch");
        assertEq(token.balanceOf(user2), 50 ether, "Recipient balance mismatch");
    }

    /**
     * @notice Politika motoru kapatıldığında kara listenin bypass edildiğini doğrular.
     */
    function testIntegrationPolicyDeactivation() public {
        vm.startPrank(admin);
        policyEngine.setBlacklist(user1, true);
        policyEngine.setPolicyActive(false); // Politika dev dışı
        vm.stopPrank();

        vm.prank(user1);
        bool success = token.transfer(user2, 10 ether);

        assertTrue(success, "Transfer should succeed when engine is inactive");
        assertEq(token.balanceOf(user2), 10 ether);
    }

    /**
     * @notice Politika motoru yetki kontrolünü doğrular.
     */
    function testPolicyEngineAccessControl() public {
        vm.prank(user2);
        vm.expectRevert(AOXCTransferPolicyEngine.Policy__NotAuthorized.selector);
        policyEngine.setBlacklist(user1, true);
    }
}
