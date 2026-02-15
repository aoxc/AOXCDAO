// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Test, console } from "forge-std/Test.sol";
import { AOXC } from "../src/core/AOXC.sol";

/// @title DeploySystemIntegrationTest
/// @notice Integration test to validate AOXC contract deployment via clone from X-Layer
/// @dev Ensures local testing environment mimics mainnet bytecode behavior
contract DeploySystemIntegrationTest is Test {
    /// @notice Reference to the locally cloned AOXC contract
    AOXC public clonedAoxc;

    /// @notice Mainnet logic contract address (X-Layer)
    address public constant TARGET_LOGIC = 0x97Bdd1fD1CAF756e00eFD42eBa9406821465B365;

    /// @notice Setup function executed before each test
    function setUp() public {
        /// @dev Create a deterministic local proxy address for testing
        address localProxy = makeAddr("localProxy");

        /// @dev Clone the mainnet bytecode to the local proxy address
        vm.etch(localProxy, TARGET_LOGIC.code);

        /// @dev Initialize AOXC instance at the local proxy
        clonedAoxc = AOXC(localProxy);
    }

    /// @notice Verifies that the cloned AOXC contract has been deployed correctly
    /// @dev Checks that bytecode exists at the local proxy and logs key information
    function test_ClonedContractDeployment() public view {
        console.log("=== STAGE 00: CONTRACT CLONE DEPLOYMENT ===");
        console.log("Local Proxy Address:", address(clonedAoxc));

        uint256 codeSize;
        address addr = address(clonedAoxc);

        assembly {
            codeSize := extcodesize(addr)
        }

        console.log("Bytecode Size at Local Address:", codeSize);

        /// @dev Assertion ensures that the local proxy contains valid bytecode
        assertTrue(codeSize > 0, "Error: Bytecode not found at local proxy address");
    }
}

