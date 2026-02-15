// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Test, console } from "forge-std/Test.sol";
import { AOXC } from "../src/core/AOXC.sol";
import { AOXCStorage } from "../src/core/AOXCStorage.sol";

/* ============================================================
    [V2 LOGIC LAYER]
   ============================================================ */

/**
 * @title AOXC_V2
 * @notice Logic implementation for Version 2 of the AOXC token.
 * @dev Inherits from AOXC and introduces updated supply cap management.
 */
contract AOXC_V2 is AOXC {
    uint256 public constant REVISION = 2;
    string public constant FORENSIC_STATUS = "26-CHANNEL_ACTIVE";

    /**
     * @dev Gap updated to camelCase to satisfy Forge-Lint (mixed-case-variable).
     * Total storage integrity is maintained through ERC-7201.
     */
    uint256[50] private _gapV2;

    /**
     * @notice Updates the supply cap in V2 logic.
     * @dev Uses the standardized 'getMainStorage' helper to access namespaced storage.
     * @param newCap The new maximum supply cap to be enforced.
     */
    function updateSupplyCap(uint256 newCap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newCap == 0) revert AOXC__InvalidSupplyCap();

        AOXCStorage.MainStorage storage ds = AOXCStorage.getMainStorage();
        ds.supplyCap = newCap;
    }

    /**
     * @notice Returns the current supply cap from namespaced storage.
     * @return The current supply cap value.
     */
    function getSupplyCap() external view returns (uint256) {
        return AOXCStorage.getMainStorage().supplyCap;
    }

    /**
     * @notice Version check helper.
     * @return True to confirm V2 logic is active.
     */
    function isV2() external pure returns (bool) {
        return true;
    }
}

/* ============================================================
    [UPGRADE INTEGRATION TEST]
   ============================================================ */

/**
 * @title UpgradeSystemIntegrationTest
 * @notice High-fidelity integration test for proxy upgrade sequences.
 * @dev Executes real state transitions without mocks.
 */
contract UpgradeSystemIntegrationTest is Test {
    // Assets located on production-simulated state
    address public constant PROXY_TOKEN = 0xeB9580c3946BB47d73AAE1d4f7A94148B554b2F4;
    address public constant ADMIN_VAULT = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84;

    // EIP-1967: keccak-256(uint256(keccak256("eip1967.proxy.implementation")) - 1)
    bytes32 internal constant IMPL_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    uint256 internal constant SCAN_DEPTH = 32;

    struct GlobalAudit {
        uint256 v1Supply;
        uint256 v2Supply;
        uint256 gasUsed;
        address v2LogicAddr;
        bytes32 codeHash;
    }

    GlobalAudit public report;

    /**
     * @notice Executes the absolute final upgrade report sequence.
     * @dev Phases include snapshotting, logic deployment, memory manipulation, and forensic audit.
     */
    function test_ABSOLUTE_FINAL_REPORT() public {
        AOXC v1 = AOXC(PROXY_TOKEN);
        report.v1Supply = v1.totalSupply();

        // PHASE 1: STORAGE SNAPSHOT (PRE-UPGRADE)
        bytes32[] memory v1Storage = new bytes32[](SCAN_DEPTH);
        for (uint256 i = 0; i < SCAN_DEPTH; i++) {
            v1Storage[i] = vm.load(PROXY_TOKEN, bytes32(i));
        }

        // PHASE 2: DEPLOY V2 LOGIC
        AOXC_V2 v2Logic = new AOXC_V2();
        report.v2LogicAddr = address(v2Logic);
        report.codeHash = keccak256(report.v2LogicAddr.code);

        // PHASE 3: UPGRADE PROXY (EIP-1967 Slot Manipulation)
        vm.store(PROXY_TOKEN, IMPL_SLOT, bytes32(uint256(uint160(report.v2LogicAddr))));

        AOXC_V2 v2 = AOXC_V2(PROXY_TOKEN);

        // PHASE 4: ADMIN OPERATION (POST-UPGRADE TEST)
        vm.startPrank(ADMIN_VAULT);
        uint256 gasStart = gasleft();

        v2.updateSupplyCap(10_000_000_000 * 1e18);

        report.gasUsed = gasStart - gasleft();
        vm.stopPrank();

        // PHASE 5: POST-UPGRADE SNAPSHOT & AUDIT
        report.v2Supply = v2.totalSupply();

        bytes32[] memory v2Storage = new bytes32[](SCAN_DEPTH);
        for (uint256 i = 0; i < SCAN_DEPTH; i++) {
            v2Storage[i] = vm.load(PROXY_TOKEN, bytes32(i));
        }

        _renderComprehensiveAudit(v1Storage, v2Storage);

        // PHASE 6: CRITICAL ASSERTIONS
        assertEq(report.v1Supply, report.v2Supply, "CRITICAL: Supply Drift!");
        assertTrue(v2.hasRole(0x00, ADMIN_VAULT), "CRITICAL: Admin Auth Lost!");
        assertEq(v2.REVISION(), 2, "CRITICAL: Version Mismatch!");
        assertTrue(v2.isV2(), "CRITICAL: Logic Switch Failed!");
    }

    /**
     * @dev Internal helper for forensic audit visualization.
     */
    function _renderComprehensiveAudit(bytes32[] memory v1Storage, bytes32[] memory v2Storage)
        internal
        view
    {
        console.log("\n====================================================================");
        console.log(" AOXC V2 FORENSIC UPGRADE REPORT");
        console.log("====================================================================");
        console.log("Logic Address:", report.v2LogicAddr);
        console.log("CodeHash:", vm.toString(report.codeHash));
        console.log("Gas Used:", report.gasUsed);
        console.log("\nStorage Diff Scan (0-31):");

        for (uint256 i = 0; i < SCAN_DEPTH; i++) {
            bool stable = (v1Storage[i] == v2Storage[i]);
            string memory status = stable ? "OK" : "DRIFT";
            console.log(i, status, vm.toString(v2Storage[i]));
        }
        console.log("====================================================================\n");
    }
}
