# IAssetBackingLedger
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/IAssetBackingLedger.sol)

**Inherits:**
IERC165

**Title:**
IAssetBackingLedger

**Author:**
AOXC Core Engineering

Interface for the protocol's collateral tracking and valuation system.

High-precision accounting for multi-asset backing.


## Functions
### getTotalValue

Calculates the total USD value of all assets held in the backing.

PRO ULTIMATE: This must return a 1:1 oracle-normalized value with 18 decimals.
Required by AOXCInvariantChecker for solvency verification.


```solidity
function getTotalValue() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total valuation in USD (18 decimals).|


### getAssetValue

Returns the valuation of a specific asset.


```solidity
function getAssetValue(address asset) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|The contract address of the collateral asset.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The asset's current value contribution to the backing.|


### isDataFresh

Checks if the ledger's data is fresh and reliable.


```solidity
function isDataFresh() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the internal heartbeat is within acceptable parameters.|


## Events
### CollateralUpdated

```solidity
event CollateralUpdated(address indexed asset, uint256 amount, uint256 usdValue);
```

## Errors
### Ledger__StalePriceDetected

```solidity
error Ledger__StalePriceDetected(uint256 lastUpdate);
```

### Ledger__AssetNotSupported

```solidity
error Ledger__AssetNotSupported(address asset);
```

### Ledger__NegativeValueProtection

```solidity
error Ledger__NegativeValueProtection();
```

