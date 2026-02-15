# ISystemInvariant
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/ISystemInvariant.sol)

**Title:**
ISystemInvariant

Defines system-wide invariants that must hold at all times


## Functions
### invariantTotalSupplyBacked

Total supply must always be fully backed by recorded assets


```solidity
function invariantTotalSupplyBacked() external view returns (bool);
```

### invariantTransferPolicyEnforced

All transfers must be subject to compliance and policy checks


```solidity
function invariantTransferPolicyEnforced() external view returns (bool);
```

### invariantStorageIntegrity

Upgrades must preserve storage layout integrity


```solidity
function invariantStorageIntegrity() external view returns (bool);
```

