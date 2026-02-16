# AOXCStorage
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/core/AOXCStorage.sol)

**Title:**
AOXCStorage

Centralized storage layout for AOXC token (ERC-7201 compliant).

Provides upgrade-safe storage slots using Namespaced Storage Pattern.
Identity: "AOXC-DAO-V2-AKDENIZ-2026"


## State Variables
### STORAGE_SLOT
ERC-7201 Storage Slot calculation.
keccak256(abi.encode(uint256(keccak256("AOXC-DAO-V2-AKDENIZ-2026")) - 1)) & ~bytes32(uint256(0xff))


```solidity
bytes32 private constant STORAGE_SLOT =
    0x367f3747805167389a19c11867e3a34a17951a37651a148972b260907d083100
```


## Functions
### getMainStorage

Returns the storage layout for AOXC.
Renamed from 'layout' to 'getMainStorage' to avoid parser conflicts in Forge Doc.


```solidity
function getMainStorage() internal pure returns (MainStorage storage ds);
```

### setEmergencyHalt


```solidity
function setEmergencyHalt(bool status) internal;
```

### setPolicyEnforcement


```solidity
function setPolicyEnforcement(bool status) internal;
```

### setUpgradeAuthorizer


```solidity
function setUpgradeAuthorizer(address newAuthorizer) internal;
```

### setTransferPolicy


```solidity
function setTransferPolicy(address newPolicy) internal;
```

### setSupplyCap


```solidity
function setSupplyCap(uint256 newCap) internal;
```

### excludeFromLimits


```solidity
function excludeFromLimits(address account, bool status) internal;
```

### isExcluded


```solidity
function isExcluded(address account) internal view returns (bool);
```

### getSupplyCap


```solidity
function getSupplyCap() internal view returns (uint256);
```

### getUpgradeNonce


```solidity
function getUpgradeNonce() internal view returns (uint256);
```

### getLastUpgradeTimestamp


```solidity
function getLastUpgradeTimestamp() internal view returns (uint256);
```

### getPendingImplementation


```solidity
function getPendingImplementation(uint256 nonce) internal view returns (address);
```

## Structs
### MainStorage
**Note:**
storage-location: erc7201:AOXC-DAO-V2-AKDENIZ-2026


```solidity
struct MainStorage {
    // --- Governance & Policy ---
    address transferPolicy;
    address upgradeAuthorizer;
    bool policyEnforcementActive;
    bool isEmergencyHalt;
    // --- Metadata & Timestamps ---
    uint256 lastUpgradeTimestamp;
    uint256 lastPolicyChange;
    // --- Supply Management ---
    uint256 supplyCap;
    mapping(address => bool) isExcludedFromLimits;
    // --- Upgrade Authorization State (Multi-sig/Consensus) ---
    uint256 upgradeNonce;
    mapping(uint256 => mapping(address => bool)) upgradeApprovals;
    mapping(uint256 => uint256) approvalCounts;
    mapping(uint256 => address) pendingImplementation;
    // --- Forensic Tracking ---
    bytes32 lastActionHash;
    // --- Reserved Space for Future Upgrades ---
    uint256[37] _gap;
}
```

