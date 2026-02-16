# IAOXP
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IAOXP.sol)

**Inherits:**
IERC165

**Title:**
IAOXP

**Author:**
AOXC Core Engineering

Interface for Soulbound Experience Points (XP) and Reputation Badges.

Compliant with 2026 standards: Includes ERC-165 for interface detection
and explicit supply tracking for Invariant Checkers.


## Functions
### totalSupply

Returns the global total supply of XP/Tokens.

Required for AOXCInvariantChecker solvency audits.


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total circulating supply in 10^18 decimals.|


### awardXp

Awards Experience Points (XP) or Badges to a participant.


```solidity
function awardXp(address to, uint256 id, uint256 amount, bytes calldata data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The recipient address.|
|`id`|`uint256`|Token/XP category identifier (e.g., 0 for General XP, 1+ for Badges).|
|`amount`|`uint256`|The quantity to award.|
|`data`|`bytes`|Additional metadata for the transaction (off-chain reference).|


### getUserXp

Returns the total XP accumulated by a user.


```solidity
function getUserXp(address user) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The participant's address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total XP balance for the given user.|


### hasBadge

Checks if a user possesses a specific badge.


```solidity
function hasBadge(address user, uint256 badgeId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The participant's address.|
|`badgeId`|`uint256`|The unique identifier of the badge.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the user owns the badge, false otherwise.|


## Events
### XpAwarded

```solidity
event XpAwarded(address indexed to, uint256 indexed id, uint256 amount);
```

### BadgeGranted

```solidity
event BadgeGranted(address indexed user, uint256 indexed badgeId);
```

## Errors
### AOXP__UnauthorizedMinter

```solidity
error AOXP__UnauthorizedMinter(address account);
```

### AOXP__SoulboundTokenNonTransferable

```solidity
error AOXP__SoulboundTokenNonTransferable();
```

### AOXP__InvalidXpAmount

```solidity
error AOXP__InvalidXpAmount();
```

