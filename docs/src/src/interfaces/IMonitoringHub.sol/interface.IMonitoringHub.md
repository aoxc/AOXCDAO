# IMonitoringHub
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/IMonitoringHub.sol)

**Title:**
IMonitoringHub

**Author:**
AOXC Core Engineering

Enterprise-grade hyper-forensic monitoring interface for AOXC Protocol.

NatSpec standards strictly followed. Designed for UUPS/Proxy compatibility
and high-fidelity data throughput on X Layer.


## Functions
### logForensic

Primary portal for all AOXC forensic entries.


```solidity
function logForensic(ForensicLog calldata log) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`log`|`ForensicLog`|The full 26-channel forensic data struct.|


### getRecord

Retrieves a specific forensic record by its global index.


```solidity
function getRecord(uint256 index) external view returns (ForensicLog memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The sequence ID to query.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`ForensicLog`|log The complete 26-channel data structure.|


### getRecordCount

Returns the total number of forensic records emitted.


```solidity
function getRecordCount() external view returns (uint256);
```

### isMonitoringActive

Checks if the monitoring system is active and accepting logs.


```solidity
function isMonitoringActive() external view returns (bool);
```

## Events
### RecordLogged
Emitted when a 26-channel forensic record is sealed on-chain.


```solidity
event RecordLogged(
    uint256 indexed index,
    address indexed source,
    Severity indexed severity,
    string category,
    bytes32 correlationId
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|Global sequence ID of the log.|
|`source`|`address`|Reporting contract address.|
|`severity`|`Severity`|Incident level.|
|`category`|`string`|Module category.|
|`correlationId`|`bytes32`|Link to related events.|

## Structs
### ForensicLog
The 26-Channel Forensic Data Container.

Consolidated into a struct to prevent "Stack Too Deep" errors
while maintaining 360-degree transaction visibility.


```solidity
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
```

## Enums
### Severity
Severity levels for incident classification.

Organized by escalation priority.


```solidity
enum Severity {
    INFO, // Routine operational logs
    WARNING, // Deviations that require attention
    ERROR, // Failed execution but system remains stable
    CRITICAL, // Significant risk, potential fund loss
    EMERGENCY // Protocol-wide immediate action required (e.g., Pause)
}
```

