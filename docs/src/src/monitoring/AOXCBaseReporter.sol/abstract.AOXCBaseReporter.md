# AOXCBaseReporter
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/monitoring/AOXCBaseReporter.sol)

**Inherits:**
ContextUpgradeable

**Title:**
AOXCBaseReporter

**Author:**
AOXC Core Engineering

Ultimate engine automating 26-channel forensic data collection.

Optimized for Akdeniz V2 with assembly-level hashing to eliminate forge-lint [asm-keccak256].


## State Variables
### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### _localNonce

```solidity
uint256 private _localNonce
```


### _gap
Reserved storage gap for upgradeability protection (50 slots total).
1 slot used by monitoringHub, 1 slot by _localNonce = 48 slots gap.


```solidity
uint256[48] private _gap
```


## Functions
### _performForensicLog

Performs forensic logging by calling the MonitoringHub.

Uses a try-catch block to ensure forensic logging failure doesn't revert the main transaction.


```solidity
function _performForensicLog(
    IMonitoringHub.Severity severity,
    string memory category,
    string memory details,
    address related,
    uint8 riskScore,
    bytes memory metadata
) internal virtual;
```

### _generateCorrelationId

Generates a unique correlation ID using optimized inline assembly.

Replaces abi.encodePacked with Yul for maximum efficiency and lint compliance.


```solidity
function _generateCorrelationId(uint256 nonce) internal view returns (bytes32 correlationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nonce`|`uint256`|The local nonce for this reporting contract.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`correlationId`|`bytes32`|The calculated 32-byte hash.|


### _setMonitoringHub

Configures the MonitoringHub address with zero-address validation.


```solidity
function _setMonitoringHub(address _hub) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_hub`|`address`|Address of the deployed MonitoringHub contract.|


