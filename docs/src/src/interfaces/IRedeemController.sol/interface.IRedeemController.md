# IRedeemController
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IRedeemController.sol)

**Title:**
IRedeemController

Institutional interface for regulating token redemption protocols and daily liquidity quotas.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### burn

Executes the permanent removal of tokens from circulation via redemption.

Should implement strict access control and quota verification.


```solidity
function burn(address from, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|  The account from which tokens will be extracted and neutralized.|
|`amount`|`uint256`|The total volume of assets to be decommissioned.|


### setRedeemLimit

Configures the maximum permissible asset redemption volume for a 24-hour cycle.


```solidity
function setRedeemLimit(uint256 newLimit) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newLimit`|`uint256`|The updated threshold for institutional liquidity exits.|


### resetDailyCounter

Resets the daily redemption counter (typically once per 24h).


```solidity
function resetDailyCounter() external;
```

### setRedeemActive

Activates or deactivates the redemption mechanism.


```solidity
function setRedeemActive(bool active) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`active`|`bool`|Boolean flag to set redemption status.|


### getRedeemLimit

Returns the active 24-hour redemption ceiling.


```solidity
function getRedeemLimit() external view returns (uint256 currentLimit);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`currentLimit`|`uint256`|The maximum allowed volume for the current period.|


### getRedeemedToday

Returns the cumulative volume of assets redeemed within the current 24-hour window.


```solidity
function getRedeemedToday() external view returns (uint256 dailyTotal);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dailyTotal`|`uint256`|The total volume processed since the last reset.|


### isRedeemActive

Returns whether redemption is currently active.


```solidity
function isRedeemActive() external view returns (bool active);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`active`|`bool`|Boolean flag indicating if redemption is enabled.|


## Events
### RedeemExecuted
Emitted when a redemption (burn) is executed.


```solidity
event RedeemExecuted(address indexed from, uint256 amount, uint256 timestamp);
```

### RedeemLimitUpdated
Emitted when the daily redemption limit is updated.


```solidity
event RedeemLimitUpdated(uint256 newLimit, uint256 timestamp);
```

### RedeemCounterReset
Emitted when the daily redemption counter is reset.


```solidity
event RedeemCounterReset(uint256 timestamp);
```

### RedeemStatusChanged
Emitted when redemption is paused or resumed.


```solidity
event RedeemStatusChanged(bool active, uint256 timestamp);
```

