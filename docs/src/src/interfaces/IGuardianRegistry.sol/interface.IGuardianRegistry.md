# IGuardianRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IGuardianRegistry.sol)

**Title:**
IGuardianRegistry

Institutional interface for managing emergency responder authorizations.

AOXC Ultimate Protocol: Vertical Alignment & Technical Eloquence.


## Functions
### isGuardian

Returns the authorization status of a potential guardian.


```solidity
function isGuardian(address account) external view returns (bool status);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to be verified.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`status`|`bool`| Boolean flag indicating institutional authorization.|


## Events
### GuardianAdded

```solidity
event GuardianAdded(address indexed guardian, uint256 timestamp);
```

### GuardianRemoved

```solidity
event GuardianRemoved(address indexed guardian, uint256 timestamp);
```

