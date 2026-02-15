// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {
    ContextUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCBaseReporter
 * @author AOXC Core Engineering
 * @notice Ultimate engine automating 26-channel forensic data collection.
 * @dev Optimized for Akdeniz V2 with assembly-level hashing to eliminate forge-lint [asm-keccak256].
 */
abstract contract AOXCBaseReporter is ContextUpgradeable {
    IMonitoringHub public monitoringHub;
    uint256 private _localNonce;

    /**
     * @dev Reserved storage gap for upgradeability protection (50 slots total).
     * 1 slot used by monitoringHub, 1 slot by _localNonce = 48 slots gap.
     */
    uint256[48] private _gap;

    /**
     * @notice Performs forensic logging by calling the MonitoringHub.
     * @dev Uses a try-catch block to ensure forensic logging failure doesn't revert the main transaction.
     */
    function _performForensicLog(
        IMonitoringHub.Severity severity,
        string memory category,
        string memory details,
        address related,
        uint8 riskScore,
        bytes memory metadata
    ) internal virtual {
        // Stop execution if MonitoringHub is not set to prevent gas waste
        if (address(monitoringHub) == address(0)) return;

        uint256 currentNonce = ++_localNonce;

        // 26-Channel Payload Delivery
        try monitoringHub.logForensic(
            IMonitoringHub.ForensicLog({
                source: address(this),
                actor: _msgSender(),
                origin: tx.origin,
                related: related,
                severity: severity,
                category: category,
                details: details,
                riskScore: riskScore,
                nonce: currentNonce,
                chainId: block.chainid,
                blockNumber: block.number,
                timestamp: block.timestamp,
                gasUsed: gasleft(),
                value: msg.value,
                stateRoot: bytes32(0),
                txHash: bytes32(0),
                selector: msg.sig,
                version: 1,
                actionReq: (severity >= IMonitoringHub.Severity.CRITICAL),
                isUpgraded: true,
                environment: 0,
                correlationId: _generateCorrelationId(currentNonce),
                policyHash: bytes32(0),
                sequenceId: 0,
                metadata: metadata,
                proof: ""
            })
        ) {
        // Success: Log recorded
        }
            catch {
            // Critical: Ensure main execution flow is never interrupted by logging failures
        }
    }

    /**
     * @notice Generates a unique correlation ID using optimized inline assembly.
     * @dev Replaces abi.encodePacked with Yul for maximum efficiency and lint compliance.
     * @param nonce The local nonce for this reporting contract.
     * @return correlationId The calculated 32-byte hash.
     */
    function _generateCorrelationId(uint256 nonce) internal view returns (bytes32 correlationId) {
        uint256 ts = block.timestamp;
        address sender = _msgSender();
        bytes32 bh = blockhash(block.number - 1);

        assembly {
            // Load free memory pointer
            let ptr := mload(0x40)

            // Store variables sequentially in memory
            mstore(ptr, ts) // 32 bytes
            mstore(add(ptr, 0x20), sender) // 32 bytes (address padded)
            mstore(add(ptr, 0x40), nonce) // 32 bytes
            mstore(add(ptr, 0x60), bh) // 32 bytes

            // Hash 128 bytes of data (4 x 32)
            correlationId := keccak256(ptr, 0x80)
        }
    }

    /**
     * @notice Configures the MonitoringHub address with zero-address validation.
     * @param _hub Address of the deployed MonitoringHub contract.
     */
    function _setMonitoringHub(address _hub) internal virtual {
        if (_hub == address(0)) revert AOXCErrors.ZeroAddressDetected();
        monitoringHub = IMonitoringHub(_hub);
    }
}
