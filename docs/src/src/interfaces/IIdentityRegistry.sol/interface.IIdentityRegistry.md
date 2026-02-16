# IIdentityRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IIdentityRegistry.sol)

**Title:**
IIdentityRegistry

Institutional interface for identity verification, KYC telemetry, and account registry.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### register


```solidity
function register(address account, string calldata id) external;
```

### deregister


```solidity
function deregister(address account) external;
```

### getIdentity


```solidity
function getIdentity(address account) external view returns (string memory identityId);
```

### isRegistered


```solidity
function isRegistered(address account) external view returns (bool registered);
```

### getRegisteredCount


```solidity
function getRegisteredCount() external view returns (uint256 totalCount);
```

## Events
### IdentityRegistered

```solidity
event IdentityRegistered(address indexed account, string id, uint256 timestamp);
```

### IdentityDeregistered

```solidity
event IdentityDeregistered(address indexed account, uint256 timestamp);
```

