# ISentinelExecutor
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/interfaces/ISentinelExecutor.sol)

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

