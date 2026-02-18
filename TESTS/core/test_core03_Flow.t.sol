// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXCMainEngine} from "@core/core01_AoxcMainEngine_170226.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {ITransferPolicy} from "@api/api26_ITransferPolicy_170226.sol";

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

    function validateTransfer(address from, address to, uint256) external view override {
        if (!isActive) return;
        if (blacklisted[from]) revert Policy__Blacklisted(from);
        if (blacklisted[to]) revert Policy__Blacklisted(to);
    }

    function setBlacklist(address account, bool status) external onlyAdmin {
        blacklisted[account] = status;
    }

    function setPolicyActive(bool _active) external onlyAdmin {
        isActive = _active;
    }

    function isPolicyActive() external view returns (bool) { return isActive; }
    function policyName() external pure returns (string memory) { return "AOXC_Core_Compliance_Engine"; }
    function policyVersion() external pure returns (uint256) { return 1; }
    function updatePolicyParameter(string calldata, uint256) external onlyAdmin {}
}

contract AOXCTransferPolicyTest is Test {
    AOXCMainEngine private token;
    AOXCTransferPolicyEngine private policyEngine;

    address private admin = makeAddr("admin");
    address private user1 = makeAddr("user1");
    address private user2 = makeAddr("user2");
    address private hubAddr = makeAddr("monitoringHub");

    uint256 private constant INITIAL_CAP = 1_000_000 ether;

    function setUp() public {
        policyEngine = new AOXCTransferPolicyEngine(admin);
        AOXCMainEngine implementation = new AOXCMainEngine();

        bytes memory initData = abi.encodeWithSelector(
            AOXCMainEngine.initialize.selector,
            "AOXCMainEngine Token",
            "AOXCMainEngine",
            admin,
            address(policyEngine),
            address(0),
            IMonitoringHub(hubAddr),
            INITIAL_CAP
        );

        token = AOXCMainEngine(address(new ERC1967Proxy(address(implementation), initData)));

        vm.prank(admin);
        token.mint(user1, 100 ether);
    }

    function testIntegrationBlacklistBlocksTransfer() public {
        vm.prank(admin);
        policyEngine.setBlacklist(user1, true);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("AOXC__PolicyViolation()"));
        assertTrue(token.transfer(user2, 10 ether), "Transfer failed");
    }

    function testIntegrationSuccessfulTransfer() public {
        vm.prank(user1);
        bool success = token.transfer(user2, 50 ether);

        assertTrue(success, "Transfer should return true");
        assertEq(token.balanceOf(user1), 50 ether);
        assertEq(token.balanceOf(user2), 50 ether);
    }

    function testIntegrationPolicyDeactivation() public {
        vm.startPrank(admin);
        policyEngine.setBlacklist(user1, true);
        policyEngine.setPolicyActive(false);
        vm.stopPrank();

        vm.prank(user1);
        assertTrue(token.transfer(user2, 10 ether), "Should succeed when policy inactive");
    }

    function testPolicyEngineAccessControl() public {
        vm.prank(user2);
        vm.expectRevert(AOXCTransferPolicyEngine.Policy__NotAuthorized.selector);
        policyEngine.setBlacklist(user1, true);
    }
}
