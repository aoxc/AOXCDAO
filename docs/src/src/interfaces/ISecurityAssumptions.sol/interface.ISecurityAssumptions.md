# ISecurityAssumptions
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/ISecurityAssumptions.sol)

**Title:**
ISecurityAssumptions

Explicit security assumptions relied upon by the protocol


## Functions
### assumesGuardianHonesty

Guardians are assumed to act honestly within defined emergency procedures


```solidity
function assumesGuardianHonesty() external pure returns (bool);
```

### assumesTimelockRespected

Governance actions are assumed to respect enforced timelock constraints


```solidity
function assumesTimelockRespected() external pure returns (bool);
```

### assumesBridgeIntegrity

External bridge infrastructure is assumed to validate messages correctly


```solidity
function assumesBridgeIntegrity() external pure returns (bool);
```

