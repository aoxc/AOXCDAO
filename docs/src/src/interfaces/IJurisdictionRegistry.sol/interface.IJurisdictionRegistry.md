# IJurisdictionRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IJurisdictionRegistry.sol)

**Title:**
IJurisdictionRegistry

Institutional interface for regional legal compliance and cross-border regulatory telemetry.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### assignJurisdiction

Designates an institutional regional identifier to a specific account.

Should implement administrative access control.


```solidity
function assignJurisdiction(address user, uint256 jurisdictionId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|          The target account for regional classification.|
|`jurisdictionId`|`uint256`|The unique identifier of the legal jurisdiction.|


### revokeJurisdiction

Invalidates the current regional classification of an account.


```solidity
function revokeJurisdiction(address user) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The account whose jurisdiction status is to be decommissioned.|


### registerJurisdiction

Registers a new jurisdiction entry in the registry.


```solidity
function registerJurisdiction(uint256 jurisdictionId, string calldata name) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|Unique identifier of the jurisdiction.|
|`name`|`string`|          Semantic name of the jurisdiction.|


### removeJurisdiction

Removes a jurisdiction entry from the registry.


```solidity
function removeJurisdiction(uint256 jurisdictionId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|Unique identifier of the jurisdiction.|


### isAllowed

Verifies if an account possesses active compliance clearance for transactions.


```solidity
function isAllowed(address account) external view returns (bool allowed);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The subject address for compliance verification.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`allowed`|`bool`|Boolean flag indicating the regulatory clearance status.|


### getJurisdictionName

Returns the semantic name of a specific regional jurisdiction.


```solidity
function getJurisdictionName(uint256 jurisdictionId) external view returns (string memory name);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|The identifier for the targeted region.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The institutional name string for the jurisdiction.|


### getUserJurisdiction

Retrieves the designated jurisdiction identifier for a given account.


```solidity
function getUserJurisdiction(address user) external view returns (uint256 jurisdictionId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The account to be queried.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|The assigned regional index.|


### getJurisdictionCount

Returns the total volume of documented jurisdictions within the registry.


```solidity
function getJurisdictionCount() external view returns (uint256 count);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`count`|`uint256`|Total number of registered regional identifiers.|


### jurisdictionExists

Returns whether a jurisdiction ID is currently registered.


```solidity
function jurisdictionExists(uint256 jurisdictionId) external view returns (bool exists);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`jurisdictionId`|`uint256`|The identifier to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`exists`|`bool`|Boolean flag indicating if the jurisdiction exists.|


## Events
### JurisdictionAssigned
Emitted when a jurisdiction is assigned to a user.


```solidity
event JurisdictionAssigned(address indexed user, uint256 jurisdictionId, uint256 timestamp);
```

### JurisdictionRevoked
Emitted when a jurisdiction is revoked from a user.


```solidity
event JurisdictionRevoked(address indexed user, uint256 timestamp);
```

### JurisdictionRegistered
Emitted when a new jurisdiction is registered in the system.


```solidity
event JurisdictionRegistered(uint256 jurisdictionId, string name, uint256 timestamp);
```

### JurisdictionRemoved
Emitted when a jurisdiction entry is removed from the system.


```solidity
event JurisdictionRemoved(uint256 jurisdictionId, uint256 timestamp);
```

