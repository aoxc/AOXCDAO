# AOXCErrors
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/libraries/AOXCErrors.sol)

**Title:**
AOXCErrors

**Author:**
AOXC Core Engineering

Centralized library for all AOXC Protocol custom errors.

Optimized for gas efficiency and Akdeniz V2 26-channel forensic logging.
Categories: 1xxx (Access), 2xxx (Finance), 3xxx (Forensic), 4xxx (Assets), 5xxx (Gov), 6xxx (Infra).


## Errors
### Unauthorized

```solidity
error Unauthorized(address actor);
```

### OnlyAdminAllowed

```solidity
error OnlyAdminAllowed();
```

### ProtocolPaused

```solidity
error ProtocolPaused();
```

### BlacklistedAccount

```solidity
error BlacklistedAccount(address account);
```

### ZeroAddressDetected

```solidity
error ZeroAddressDetected();
```

### InvalidConfiguration

```solidity
error InvalidConfiguration();
```

### RateLimitExceeded

```solidity
error RateLimitExceeded();
```

### SecurityAssumptionViolated

```solidity
error SecurityAssumptionViolated();
```

### ThresholdExceeded

```solidity
error ThresholdExceeded();
```

### RiskThresholdReached

```solidity
error RiskThresholdReached();
```

### SystemFrozen

```solidity
error SystemFrozen();
```

### ActionNotAllowed

```solidity
error ActionNotAllowed();
```

### InvalidState

```solidity
error InvalidState();
```

### InsufficientReserves

```solidity
error InsufficientReserves(uint256 bal, uint256 req);
```

### TransferFailed

```solidity
error TransferFailed();
```

### InvalidRecipient

```solidity
error InvalidRecipient();
```

### SlippageExceeded

```solidity
error SlippageExceeded();
```

### AllowanceExceeded

```solidity
error AllowanceExceeded();
```

### InvariantCheckFailed

```solidity
error InvariantCheckFailed();
```

### InvalidMonitoringHub

```solidity
error InvalidMonitoringHub();
```

### ForensicPayloadTooLarge

```solidity
error ForensicPayloadTooLarge();
```

### RiskThresholdExceeded

```solidity
error RiskThresholdExceeded(uint8 score);
```

### DuplicateNonce

```solidity
error DuplicateNonce(uint256 nonce);
```

### ForensicDataIncomplete

```solidity
error ForensicDataIncomplete();
```

### ForensicLogFailed

```solidity
error ForensicLogFailed();
```

### InvalidItemID

```solidity
error InvalidItemID(uint256 id);
```

### MintLimitReached

```solidity
error MintLimitReached();
```

### ItemLocked

```solidity
error ItemLocked();
```

### MetadataInconsistent

```solidity
error MetadataInconsistent();
```

### ProposalExpired

```solidity
error ProposalExpired(uint256 id);
```

### InsufficientReputation

```solidity
error InsufficientReputation();
```

### JurisdictionRestricted

```solidity
error JurisdictionRestricted(bytes32 region);
```

### UpgradeNotAuthorized

```solidity
error UpgradeNotAuthorized(address impl);
```

### ThresholdNotReached

```solidity
error ThresholdNotReached(uint256 req, uint256 cur);
```

### ProposalNotActive

```solidity
error ProposalNotActive();
```

### BridgeLimitReached

```solidity
error BridgeLimitReached();
```

### InvalidRelayer

```solidity
error InvalidRelayer();
```

### SequenceOutOfOrder

```solidity
error SequenceOutOfOrder();
```

