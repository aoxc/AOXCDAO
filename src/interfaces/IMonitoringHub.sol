// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IMonitoringHub
 * @author AOXC Core Engineering
 * @notice Enterprise-grade hyper-forensic monitoring interface for AOXC Protocol.
 * @dev NatSpec standards strictly followed. Designed for UUPS/Proxy compatibility
 * and high-fidelity data throughput on X Layer.
 */
interface IMonitoringHub {
    /**
     * @notice Severity levels for incident classification.
     * @dev Organized by escalation priority.
     */
    enum Severity {
        INFO, // Routine operational logs
        WARNING, // Deviations that require attention
        ERROR, // Failed execution but system remains stable
        CRITICAL, // Significant risk, potential fund loss
        EMERGENCY // Protocol-wide immediate action required (e.g., Pause)
    }

    /**
     * @notice The 26-Channel Forensic Data Container.
     * @dev Consolidated into a struct to prevent "Stack Too Deep" errors
     * while maintaining 360-degree transaction visibility.
     */
    struct ForensicLog {
        // --- Infrastructure & Actor Group (1-4) ---
        address source; // 1. The contract emitting the log
        address actor; // 2. Immediate caller (msg.sender)
        address origin; // 3. Original transaction initiator (tx.origin)
        address related; // 4. Secondary address involved (Counterparty/Target)
        // --- Categorization Group (5-8) ---
        Severity severity; // 5. Incident criticality
        string category; // 6. Strategic module identifier (e.g., "MINT", "GOV", "GAME")
        string details; // 7. Human-readable description of the event
        uint8 riskScore; // 8. Algorithmic risk rating (0-100)
        // --- Temporal & Sequential Group (9-12) ---
        uint256 nonce; // 9. Contract-specific sequential counter
        uint256 chainId; // 10. Network ID (X Layer)
        uint256 blockNumber; // 11. Block height at mintage
        uint256 timestamp; // 12. Unix timestamp of the event
        // --- Technical Forensic Group (13-16) ---
        uint256 gasUsed; // 13. Snapshot of gas consumption
        uint256 value; // 14. Native asset value transferred (OKB)
        bytes32 stateRoot; // 15. Cryptographic snapshot of the contract state
        bytes32 txHash; // 16. Transaction identifier
        // --- Logic & Proxy Group (17-20) ---
        bytes4 selector; // 17. Function selector executed
        uint8 version; // 18. Forensic schema version (V1)
        bool actionReq; // 19. Flag for automated response systems
        bool isUpgraded; // 20. Indicates if logic is via Proxy/Implementation
        // --- Extended Telemetry Group (21-26) ---
        uint8 environment; // 21. 0:Prod, 1:Test, 2:Dev
        bytes32 correlationId; // 22. ID to link multiple related transactions
        bytes32 policyHash; // 23. Reference to the active compliance policy
        uint256 sequenceId; // 24. Global ecosystem-wide counter
        bytes metadata; // 25. THE VAULT: Dynamic packing for items/docs/large data
        bytes proof; // 26. THE PROOF: ZK-proofs or digital signatures
    }

    /**
     * @notice Emitted when a 26-channel forensic record is sealed on-chain.
     * @param index Global sequence ID of the log.
     * @param source Reporting contract address.
     * @param severity Incident level.
     * @param category Module category.
     * @param correlationId Link to related events.
     */
    event RecordLogged(
        uint256 indexed index,
        address indexed source,
        Severity indexed severity,
        string category,
        bytes32 correlationId
    );

    /**
     * @notice Primary portal for all AOXC forensic entries.
     * @param log The full 26-channel forensic data struct.
     */
    function logForensic(ForensicLog calldata log) external;

    /**
     * @notice Retrieves a specific forensic record by its global index.
     * @param index The sequence ID to query.
     * @return log The complete 26-channel data structure.
     */
    function getRecord(uint256 index) external view returns (ForensicLog memory);

    /**
     * @notice Returns the total number of forensic records emitted.
     */
    function getRecordCount() external view returns (uint256);

    /**
     * @notice Checks if the monitoring system is active and accepting logs.
     */
    function isMonitoringActive() external view returns (bool);
}
