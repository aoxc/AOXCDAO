# SequenceManager
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/monitoring/SequenceManager.sol)

**Inherits:**
AccessControl

**Title:**
SequenceManager

Maintains a global, immutable sequence of forensic event IDs for the AOXC ecosystem.

Ensuring that no two forensic logs can share the same global index.


## State Variables
### _globalSequenceId

```solidity
uint256 private _globalSequenceId
```


### _reporterNonces

```solidity
mapping(address => uint256) private _reporterNonces
```


## Functions
### constructor


```solidity
constructor(address admin) ;
```

### nextSequenceId

Increments and returns the next global sequence ID.


```solidity
function nextSequenceId(address reporter) external returns (uint256 sequenceId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reporter`|`address`|The address of the calling contract (e.g., BridgeAdapter).|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`sequenceId`|`uint256`|The globally unique ID for the forensic log.|


### getGlobalSequenceId


```solidity
function getGlobalSequenceId() external view returns (uint256);
```

### getReporterNonce


```solidity
function getReporterNonce(address reporter) external view returns (uint256);
```

## Events
### SequenceIncremented

```solidity
event SequenceIncremented(address indexed reporter, uint256 newSequenceId);
```

