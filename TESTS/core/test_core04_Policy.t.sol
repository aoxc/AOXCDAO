// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXCMainEngine} from "@core/core01_AoxcMainEngine_170226.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {ITransferPolicy} from "@api/api26_ITransferPolicy_170226.sol";

contract MockPolicy is ITransferPolicy {
    bool public active = true;

    // Interface gereksinimi: Politika durumunu değiştirme
    function setPolicyActive(bool _active) external override {
        active = _active;
    }

    // Interface gereksinimi: Transfer doğrulama
    function validateTransfer(address, address, uint256) external view override {
        if (active) revert("MockPolicy: Transfer Blocked");
    }

    // Diğer zorunlu interface fonksiyonları
    function isPolicyActive() external view override returns (bool) { return active; }
    function policyName() external pure override returns (string memory) { return "Mock"; }
    function policyVersion() external pure override returns (uint256) { return 1; }
    function updatePolicyParameter(string calldata, uint256) external override {}
}

contract AOXCPolicyTest is Test {
    AOXCMainEngine private token;
    MockPolicy private policy;
    address private admin = makeAddr("admin");
    address private user1 = makeAddr("user1");
    address private user2 = makeAddr("user2");

    function setUp() public {
        policy = new MockPolicy();
        AOXCMainEngine impl = new AOXCMainEngine();
        
        bytes memory data = abi.encodeWithSelector(
            AOXCMainEngine.initialize.selector,
            "Test", "TST", admin, address(policy), address(0), IMonitoringHub(makeAddr("hub")), 1_000_000 ether
        );
        
        token = AOXCMainEngine(address(new ERC1967Proxy(address(impl), data)));
        
        vm.prank(admin);
        token.mint(user1, 100 ether);
    }

    function testPolicyEnforcement() public {
        vm.prank(user1);
        vm.expectRevert("MockPolicy: Transfer Blocked");
        assertTrue(token.transfer(user2, 10 ether), "Transfer failed");
    }

    function testPolicyBypassWhenDisabled() public {
        // Interface fonksiyonu üzerinden devre dışı bırakıyoruz
        policy.setPolicyActive(false);
        
        vm.prank(user1);
        assertTrue(token.transfer(user2, 10 ether), "Transfer failed even when policy disabled");
    }
}
