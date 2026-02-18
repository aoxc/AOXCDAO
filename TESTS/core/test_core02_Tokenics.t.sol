// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXCMainEngine} from "@core/core01_AoxcMainEngine_170226.sol";
import {AOXCMonitoringHub} from "@data/data01_AoxcMonitoringHub_170226.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";

/**
 * @title AOXCMainEngine Ecosystem Integrated Security Test
 * @notice Validates the forensic handshake between AOXCMainEngine Token and Monitoring Hub.
 * @dev Focuses on Role-Based Access Control (RBAC) and 26-channel logging integrity.
 */
contract AOXCHubIntegrationTest is Test {
    AOXCMainEngine private token;
    AOXCMonitoringHub private hub;

    // Identities
    address private admin = makeAddr("admin");
    address private user = makeAddr("user");

    uint256 private constant SUPPLY_CAP = 1_000_000 ether;

    /**
     * @notice System Orchestration: Deploys Hub and Token through UUPS Proxies.
     * @dev Ensures that AOXCMainEngine Token is granted the REPORTER_ROLE within the Hub.
     */
    function setUp() public {
        vm.startPrank(admin);

        // 1. Deploy Monitoring Hub via Proxy
        AOXCMonitoringHub hubImpl = new AOXCMonitoringHub();
        bytes memory hubInit = abi.encodeWithSelector(AOXCMonitoringHub.initialize.selector, admin);
        ERC1967Proxy hubProxy = new ERC1967Proxy(address(hubImpl), hubInit);
        hub = AOXCMonitoringHub(address(hubProxy));

        // 2. Deploy AOXCMainEngine Token via Proxy
        AOXCMainEngine tokenImpl = new AOXCMainEngine();
        bytes memory tokenInit = abi.encodeWithSelector(
            AOXCMainEngine.initialize.selector,
            "AOXCMainEngine Token",
            "AOXCMainEngine",
            admin,
            address(0), // Policy
            address(0), // Authorizer
            IMonitoringHub(address(hub)),
            SUPPLY_CAP
        );
        ERC1967Proxy tokenProxy = new ERC1967Proxy(address(tokenImpl), tokenInit);
        token = AOXCMainEngine(address(tokenProxy));

        /**
         * @dev CRITICAL STEP: The Hub's logForensic is protected by REPORTER_ROLE.
         * The AOXCMainEngine token contract must be authorized to report its own forensic data.
         */
        hub.grantRole(hub.REPORTER_ROLE(), address(token));

        vm.stopPrank();
    }

    /**
     * @notice Verifies the 26-channel forensic signal during a Mint operation.
     * @dev Validates that the sequenceId is correctly incremented and stored.
     */
    function testForensicFlowOnMint() public {
        vm.startPrank(admin);

        uint256 mintAmount = 1000 ether;
        token.mint(user, mintAmount);

        // Analysis:
        // Record 1: Token initialization log (during deploy)
        // Record 2: Mint operation log
        uint256 count = hub.getRecordCount();
        assertEq(count, 2, "Should have 2 forensic records");

        IMonitoringHub.ForensicLog memory mintLog = hub.getRecord(2);
        assertEq(mintLog.category, "MINT", "Log category mismatch");
        assertEq(mintLog.actor, admin, "Actor should be the admin who called mint");
        assertEq(mintLog.source, address(token), "Source should be the token contract");

        vm.stopPrank();
    }

    /**
     * @notice Ensures anti-spam protection (LOG_COOLDOWN) is enforced for non-critical logs.
     * @dev Academic test for temporal constraints in forensic reporting.
     */
    function testLogRateLimiting() public {
        vm.startPrank(admin);

        // Success: First mint
        token.mint(user, 1 ether);

        // Failure: Immediate second mint (Cooldown is 1s, severity is INFO < CRITICAL)
        // Note: AOXCMainEngine uses try-catch for logging, so the tx won't revert, but the log won't be saved.
        token.mint(user, 1 ether);

        uint256 countAfterSpam = hub.getRecordCount();
        // Record count shouldn't increase if the Hub's logForensic reverts due to cooldown
        // (Assuming the try-catch in AOXCMainEngine.sol is working as intended)
        assertEq(countAfterSpam, 2, "Spam log should have been ignored by rate limiter");

        vm.stopPrank();
    }
}
