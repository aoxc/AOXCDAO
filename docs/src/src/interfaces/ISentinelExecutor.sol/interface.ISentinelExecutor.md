# ISentinelExecutor
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/ISentinelExecutor.sol)

**Title:**
ISentinelExecutor

Interface for automated security interventions based on forensic risk analysis.


## Functions
### triggerIntervention

Triggers an emergency action on a target contract.


```solidity
function triggerIntervention(address target, uint8 actionCode) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The contract address to intervene (e.g., Treasury, Swap).|
|`actionCode`|`uint8`|Internal code representing the type of intervention (0: Pause, 1: Blacklist, 2: Fund Rescue).|


### isUnderSanction

Validates if a transaction origin is under investigation.


```solidity
function isUnderSanction(address account) external view returns (bool);
```

