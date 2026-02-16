# IMintController
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IMintController.sol)

**Title:**
IMintController

Institutional interface for regulating token issuance protocols and fiscal yearly quotas.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### mint

Executes the issuance of new tokens into institutional circulation.

Implementation must enforce strict minting limits and administrative roles.


```solidity
function mint(address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|    The destination account for the newly generated assets.|
|`amount`|`uint256`|The total volume of assets to be synthesized.|


### setMintLimit

Configures the maximum permissible token issuance for the current fiscal cycle.


```solidity
function setMintLimit(uint256 newLimit) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newLimit`|`uint256`|The updated threshold for institutional asset generation.|


### resetYearlyCounter

Resets the yearly mint counter (typically once per fiscal year).


```solidity
function resetYearlyCounter() external;
```

### setMintActive

Activates or deactivates the minting mechanism.


```solidity
function setMintActive(bool active) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`active`|`bool`|Boolean flag to set minting status.|


### getMintLimit

Returns the active token issuance ceiling for the current cycle.


```solidity
function getMintLimit() external view returns (uint256 currentLimit);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`currentLimit`|`uint256`|The maximum allowed minting volume.|


### getMintedThisYear

Returns the cumulative volume of assets issued within the current fiscal year.


```solidity
function getMintedThisYear() external view returns (uint256 yearlyTotal);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`yearlyTotal`|`uint256`|The total volume processed since the annual reset.|


### isMintActive

Returns whether minting is currently active.


```solidity
function isMintActive() external view returns (bool active);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`active`|`bool`|Boolean flag indicating if minting is enabled.|


## Events
### MintExecuted
Emitted when a mint operation is executed.


```solidity
event MintExecuted(address indexed to, uint256 amount, uint256 timestamp);
```

### MintLimitUpdated
Emitted when the mint limit is updated.


```solidity
event MintLimitUpdated(uint256 newLimit, uint256 timestamp);
```

### MintCounterReset
Emitted when the yearly mint counter is reset.


```solidity
event MintCounterReset(uint256 timestamp);
```

### MintStatusChanged
Emitted when minting is paused or resumed.


```solidity
event MintStatusChanged(bool active, uint256 timestamp);
```

