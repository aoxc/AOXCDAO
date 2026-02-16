# ISecurityAssumptions
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/ISecurityAssumptions.sol)

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

