// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {AOXCMainEngine} from "@core/core01_AoxcMainEngine_170226.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";

/**
 * @title Monitoring Hub Implementation for Testing Environment
 * @notice Provides a concrete implementation of IMonitoringHub to satisfy interface requirements.
 */
contract MonitoringHub is IMonitoringHub {
    mapping(uint256 => ForensicLog) private _logs;
    uint256 private _logCount;

    function logForensic(ForensicLog calldata log) external override {
        _logs[_logCount] = log;
        _logCount++;
    }

    function getRecord(uint256 index) external view override returns (ForensicLog memory) {
        return _logs[index];
    }

    // Arayüz gereksinimlerini tamamlamak için eksik fonksiyonları ekliyoruz
    function getRecordCount() external view override returns (uint256) {
        return _logCount;
    }

    function isMonitoringActive() external pure override returns (bool) {
        return true;
    }
}

/**
 * @title AOXCMainEngine Initialization Test Suite
 */
contract AOXCInitTest is Test {
    AOXCMainEngine private implementation;
    AOXCMainEngine private proxyToken;
    MonitoringHub private hub;

    address private admin = makeAddr("admin");
    address private policy = makeAddr("policy");
    address private authorizer = makeAddr("authorizer");

    uint256 private constant INITIAL_CAP = 1_000_000 * 10 ** 18;

    function setUp() public {
        implementation = new AOXCMainEngine();
        hub = new MonitoringHub();

        bytes memory initData = abi.encodeWithSelector(
            AOXCMainEngine.initialize.selector,
            "AOXCMainEngine Token",
            "AOXCMainEngine",
            admin,
            address(policy),
            address(authorizer),
            IMonitoringHub(address(hub)),
            INITIAL_CAP
        );

        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        proxyToken = AOXCMainEngine(address(proxy));
    }

    function testSuccessfulInitialization() public view {
        assertEq(proxyToken.name(), "AOXCMainEngine Token");
        assertEq(proxyToken.symbol(), "AOXCMainEngine");
        assertEq(proxyToken.supplyCap(), INITIAL_CAP);
        assertTrue(proxyToken.hasRole(proxyToken.DEFAULT_ADMIN_ROLE(), admin));
        assertEq(address(proxyToken.monitoringHub()), address(hub));
    }

    function testImplementationCannotBeInitialized() public {
        vm.expectRevert();
        implementation.initialize("Fake", "FAKE", admin, policy, authorizer, IMonitoringHub(address(hub)), INITIAL_CAP);
    }

    function testProxyCannotBeReinitialized() public {
        vm.expectRevert();
        proxyToken.initialize("Double", "INIT", admin, policy, authorizer, IMonitoringHub(address(hub)), INITIAL_CAP);
    }

    function testRoleAssignment() public view {
        assertTrue(proxyToken.hasRole(proxyToken.ADMIN_ROLE(), admin));
        assertTrue(proxyToken.hasRole(proxyToken.MINT_ROLE(), admin));
        assertTrue(proxyToken.hasRole(proxyToken.UPGRADER_ROLE(), admin));
    }
}
