# IComplianceRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/IComplianceRegistry.sol)

**Title:**
IComplianceRegistry

Institutional-grade interface for blacklist enforcement and regulatory compliance management.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### addToBlacklist


```solidity
function addToBlacklist(address account, string calldata reason) external;
```

### removeFromBlacklist


```solidity
function removeFromBlacklist(address account) external;
```

### isBlacklisted


```solidity
function isBlacklisted(address account) external view returns (bool restricted);
```

### getBlacklistReason


```solidity
function getBlacklistReason(address account) external view returns (string memory reason);
```

### getBlacklistCount


```solidity
function getBlacklistCount() external view returns (uint256 count);
```

## Events
### Blacklisted

```solidity
event Blacklisted(address indexed account, string reason, uint256 timestamp);
```

### Unblacklisted

```solidity
event Unblacklisted(address indexed account, uint256 timestamp);
```

