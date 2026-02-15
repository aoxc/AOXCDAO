# ITransferPolicy
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/ITransferPolicy.sol)

**Title:**
ITransferPolicy

Institutional-grade interface for ecosystem-wide transfer validation and compliance enforcement.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### validateTransfer

Evaluates a proposed transfer against institutional compliance parameters.

Should revert with a Custom Error if the transfer violates active policies.


```solidity
function validateTransfer(address from, address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|  The source address of the asset movement.|
|`to`|`address`|    The destination address of the asset movement.|
|`amount`|`uint256`|The total volume of assets to be validated.|


### isPolicyActive

Returns the current operational status of the policy engine.


```solidity
function isPolicyActive() external view returns (bool active);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`active`|`bool`|Boolean flag indicating if the policy is currently enforced.|


### policyName

Returns the institutional identifier of the policy.


```solidity
function policyName() external pure returns (string memory name);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|Semantic string identifying the specific policy implementation.|


### policyVersion

Returns the cryptographic versioning index of the policy logic.


```solidity
function policyVersion() external pure returns (uint256 version);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`version`|`uint256`|Unsigned integer representing the current iteration.|


### setPolicyActive

Activates or deactivates the policy engine.


```solidity
function setPolicyActive(bool active) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`active`|`bool`|Boolean flag to set policy status.|


### updatePolicyParameter

Updates a numeric parameter of the policy (e.g., maxTxAmount).


```solidity
function updatePolicyParameter(string calldata parameter, uint256 newValue) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`parameter`|`string`|Semantic identifier of the parameter.|
|`newValue`|`uint256`| New numeric value for the parameter.|


## Events
### TransferValidated
Emitted when a transfer passes validation.


```solidity
event TransferValidated(
    address indexed from, address indexed to, uint256 amount, uint256 timestamp
);
```

### TransferRejected
Emitted when a transfer fails validation.


```solidity
event TransferRejected(
    address indexed from, address indexed to, uint256 amount, uint256 timestamp, string reason
);
```

### PolicyStatusChanged
Emitted when policy status changes (activated/deactivated).


```solidity
event PolicyStatusChanged(bool active, uint256 timestamp);
```

### PolicyParametersUpdated
Emitted when policy parameters are updated.


```solidity
event PolicyParametersUpdated(string parameter, uint256 newValue, uint256 timestamp);
```

