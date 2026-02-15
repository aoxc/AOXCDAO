# ITreasury
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/ITreasury.sol)

**Title:**
ITreasury

Interface defining the full institutional liquidity operations for the AOXC ecosystem.

AOXC Ultimate Protocol: Multi-Asset Vertical Alignment and Secure Liquidity Management.


## Functions
### deposit

Facilitates the ingestion of capital into the institutional reserve.


```solidity
function deposit(address token, uint256 amount) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`| The ERC20 token address or zero address for native ETH.|
|`amount`|`uint256`|Total volume of assets to be deposited.|


### withdraw

Dispatches capital from the institutional reserve to a specified recipient.

Access control and internal accounting must be handled by the implementation.


```solidity
function withdraw(address token, address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|  The ERC20 token address or zero address for native ETH.|
|`to`|`address`|     The destination address for the asset transfer.|
|`amount`|`uint256`| Total volume of assets to be withdrawn.|


### emergencyWithdraw

Executes an emergency withdrawal (admin-only).


```solidity
function emergencyWithdraw(address token, address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|  The ERC20 token address or zero address for native ETH.|
|`to`|`address`|     The destination address for the asset transfer.|
|`amount`|`uint256`| Total volume of assets to be withdrawn.|


### addSupportedToken

Adds a new token to the supported list.


```solidity
function addSupportedToken(address token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The ERC20 token address or zero address for native ETH.|


### removeSupportedToken

Removes a token from the supported list.


```solidity
function removeSupportedToken(address token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The ERC20 token address or zero address for native ETH.|


### getBalance

Returns the current liquidity balance held within the treasury for a given token.


```solidity
function getBalance(address token) external view returns (uint256 currentBalance);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The ERC20 token address or zero address for native ETH.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`currentBalance`|`uint256`|Total asset volume documented in the state.|


### getTotalReserves

Returns the total reserves across all supported tokens.

Implementation may aggregate balances of multiple tokens.


```solidity
function getTotalReserves() external view returns (uint256 totalReserves);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalReserves`|`uint256`|Aggregated asset volume.|


### getSupportedTokens

Returns the list of all supported tokens in the treasury.


```solidity
function getSupportedTokens() external view returns (address[] memory tokens);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tokens`|`address[]`|Array of token addresses (zero address for native ETH).|


## Events
### Deposit
Emitted when assets are deposited into the treasury.


```solidity
event Deposit(address indexed from, address indexed token, uint256 amount, uint256 timestamp);
```

### Withdraw
Emitted when assets are withdrawn from the treasury.


```solidity
event Withdraw(address indexed to, address indexed token, uint256 amount, uint256 timestamp);
```

### EmergencyWithdraw
Emitted when an emergency withdrawal occurs (admin-only).


```solidity
event EmergencyWithdraw(
    address indexed to, address indexed token, uint256 amount, uint256 timestamp
);
```

### TokenSupported
Emitted when a new token is added to the supported list.


```solidity
event TokenSupported(address indexed token, uint256 timestamp);
```

### TokenUnsupported
Emitted when a token is removed from the supported list.


```solidity
event TokenUnsupported(address indexed token, uint256 timestamp);
```

