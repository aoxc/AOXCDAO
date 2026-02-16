# ProofOfReserves
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/security/ProofOfReserves.sol)

**Inherits:**
AccessControl

**Title:**
ProofOfReserves

**Author:**
AOXC Core Engineering

Real-time on-chain verification of asset backing vs total supply.

Integrates with Ledger and Oracle to provide a definitive solvency status.
Optimized for Solidity 0.8.33 with strict adherence to Forge linting standards.


## State Variables
### LEDGER
The ledger tracking all collateral assets.


```solidity
IAssetBackingLedger public immutable LEDGER
```


### AOXP
The AOXP token contract representing total protocol liability.


```solidity
IAOXP public immutable AOXP
```


### ORACLE
The oracle adapter providing normalized price data.


```solidity
PriceOracleAdapter public immutable ORACLE
```


## Functions
### constructor


```solidity
constructor(address _ledger, address _aoxp, address _oracle, address admin) ;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ledger`|`address`|Address of the AssetBackingLedger.|
|`_aoxp`|`address`|Address of the IAOXP token.|
|`_oracle`|`address`|Address of the PriceOracleAdapter.|
|`admin`|`address`|Initial administrator for the AccessControl.|


### getProtocolHealth

Returns the current health of the protocol in basis points (BPS).


```solidity
function getProtocolHealth() public view returns (uint256 health);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`health`|`uint256`|10,000 means 100% collateralized, >10,000 means overcollateralized.|


### verifySolvency

Verification gate for institutional partners and dashboards.


```solidity
function verifySolvency() external returns (bool isSolvent);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isSolvent`|`bool`|Boolean indicating if the protocol meets minimum reserve requirements.|


### getReserveBalance

Helper to get the raw deficit or surplus in USD (18 decimals).


```solidity
function getReserveBalance() external view returns (int256 balance);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`balance`|`int256`|Signed difference between reserves and supply.|


## Events
### ReservesVerified

```solidity
event ReservesVerified(uint256 supply, uint256 reserves, uint256 timestamp);
```

## Errors
### AOXC__PoR_SystemUndercollateralized

```solidity
error AOXC__PoR_SystemUndercollateralized();
```

