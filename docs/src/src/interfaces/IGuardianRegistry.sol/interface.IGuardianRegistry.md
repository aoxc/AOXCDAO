# IGuardianRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/IGuardianRegistry.sol)

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

