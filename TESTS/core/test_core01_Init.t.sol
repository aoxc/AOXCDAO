// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Test } from "forge-std/Test.sol";
import { AOXC } from "../../src/core/AOXC.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IMonitoringHub } from "../../src/interfaces/IMonitoringHub.sol";

/**
 * @title Monitoring Hub Implementation for Testing Environment
 * @notice Provides a concrete implementation of IMonitoringHub to satisfy interface requirements.
 * @dev This contract ensures that all forensic logging and security alerts are captured during tests.
 */
contract MonitoringHub is IMonitoringHub {
    mapping(uint256 => ForensicLog) private _logs;
    uint256 private _logCount;

    /**
     * @inheritdoc IMonitoringHub
     */
    function logForensic(ForensicLog calldata log) external override {
        _logs[_logCount] = log;
        _logCount++;
    }

    /**
     * @inheritdoc IMonitoringHub
     */
    function getRecordCount() external view override returns (uint256) { return 0; }
    function isMonitoringActive() external view override returns (bool) { return true; }
    function isMonitoringActive() external view override returns (bool) { return true; }
    function getRecordCount() external view override returns (uint256) { return 0; }
    function logSecurityAlert(string calldata reason, IMonitoringHub.Severity severity) external override {
        // Implementation for security alert tracking in tests
    }

    /**
     * @inheritdoc IMonitoringHub
     * @dev Resolves Error (4822) by matching the exact return type defined in the interface.
     */
    function getRecord(uint256 index) external view override returns (ForensicLog memory) {
        return _logs[index];
    }
}

/**
 * @title AOXC Initialization Test Suite
 * @notice Validates the deployment, proxy initialization, and role-based access control of AOXC.
 * @dev Follows academic standards for smart contract testing using the Foundry framework.
 */
contract AOXCInitTest is Test {
    AOXC private implementation;
    AOXC private proxyToken;
    MonitoringHub private hub;

    address private admin = makeAddr("admin");
    address private policy = makeAddr("policy");
    address private authorizer = makeAddr("authorizer");

    uint256 private constant INITIAL_CAP = 1_000_000 * 10 ** 18;

    /**
     * @notice Orchestrates the deployment sequence: Implementation -> Hub -> Proxy.
     */
    function setUp() public {
        // 1. Deploy the Logic (Implementation) contract
        implementation = new AOXC();

        // 2. Deploy a concrete Monitoring Hub
        hub = new MonitoringHub();

        // 3. Prepare initialization data using the AOXC initialize selector
        bytes memory initData = abi.encodeWithSelector(
            AOXC.initialize.selector,
            "AOXC Token",
            "AOXC",
            admin,
            policy,
            authorizer,
            IMonitoringHub(address(hub)),
            INITIAL_CAP
        );

        // 4. Deploy the ERC1967 Proxy and link it to the implementation
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);

        // 5. Wrap the proxy address in the AOXC interface
        proxyToken = AOXC(address(proxy));
    }

    /**
     * @notice Verifies that the proxy state reflects the parameters provided during initialization.
     */
    function testSuccessfulInitialization() public view {
        assertEq(proxyToken.name(), "AOXC Token");
        assertEq(proxyToken.symbol(), "AOXC");
        assertEq(proxyToken.supplyCap(), INITIAL_CAP);
        assertTrue(proxyToken.hasRole(proxyToken.DEFAULT_ADMIN_ROLE(), admin));
        assertEq(address(proxyToken.monitoringHub()), address(hub));
    }

    /**
     * @notice Ensures the UUPS security pattern by verifying the implementation cannot be re-initialized.
     * @dev Validates the execution of _disableInitializers() in the constructor.
     */
    function testImplementationCannotBeInitialized() public {
        vm.expectRevert(); 
        implementation.initialize("Fake", "FAKE", admin, policy, authorizer, IMonitoringHub(address(hub)), INITIAL_CAP);
    }

    /**
     * @notice Validates that the proxy cannot be initialized multiple times (re-entrancy protection).
     */
    function testProxyCannotBeReinitialized() public {
        vm.expectRevert();
        proxyToken.initialize("Double", "INIT", admin, policy, authorizer, IMonitoringHub(address(hub)), INITIAL_CAP);
    }

    /**
     * @notice Confirms that all administrative and operational roles are correctly assigned to the admin.
     */
    function testRoleAssignment() public view {
        assertTrue(proxyToken.hasRole(proxyToken.ADMIN_ROLE(), admin));
        assertTrue(proxyToken.hasRole(proxyToken.MINT_ROLE(), admin));
        assertTrue(proxyToken.hasRole(proxyToken.UPGRADER_ROLE(), admin));
    }
}
