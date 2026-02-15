# PriceOracleAdapter
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/infrastructure/PriceOracleAdapter.sol)

**Inherits:**
AccessControl

**Title:**
PriceOracleAdapter

**Author:**
AOXC Core Engineering

Standardized price feed aggregator for the AOXC ecosystem.

Normalizes all price data to 18 decimals and enforces strict staleness checks.
Optimized for Solidity 0.8.33 with zero-lint warning policy.


## State Variables
### TARGET_DECIMALS
The target decimals for all normalized prices within the AOXC ecosystem.


```solidity
uint8 public constant TARGET_DECIMALS = 18
```


### assetFeeds
Maps asset addresses to their respective oracle configurations.


```solidity
mapping(address => FeedConfig) public assetFeeds
```


## Functions
### constructor


```solidity
constructor(address admin) ;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|Initial administrator authorized to manage price feeds.|


### setAssetFeed

Sets or updates the price feed for a specific asset.


```solidity
function setAssetFeed(address asset, address feed, uint256 heartbeat)
    external
    onlyRole(AOXCConstants.ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|The address of the collateral/asset.|
|`feed`|`address`|The address of the Chainlink-compatible aggregator.|
|`heartbeat`|`uint256`|The maximum allowable delay for price updates.|


### getPrice

Retrieves the latest price normalized to 18 decimals.

Implements security checks for stale or negative prices.


```solidity
function getPrice(address asset) external view returns (uint256 normalizedPrice);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|The address of the asset to price.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`normalizedPrice`|`uint256`|The price in USD with 18 decimal precision.|


## Events
### FeedUpdated

```solidity
event FeedUpdated(address indexed asset, address indexed feed, uint256 heartbeat);
```

## Errors
### AOXC__Oracle_StalePrice

```solidity
error AOXC__Oracle_StalePrice();
```

### AOXC__Oracle_InvalidPrice

```solidity
error AOXC__Oracle_InvalidPrice();
```

### AOXC__Oracle_FeedNotSet

```solidity
error AOXC__Oracle_FeedNotSet();
```

## Structs
### FeedConfig

```solidity
struct FeedConfig {
    address feedAddress;
    uint256 heartbeat; // Maximum time between updates (e.g., 3600s for ETH/USD)
    bool isActive;
}
```

