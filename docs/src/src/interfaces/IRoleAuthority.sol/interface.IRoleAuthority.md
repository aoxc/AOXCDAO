# IRoleAuthority
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IRoleAuthority.sol)

**Title:**
IRoleAuthority

**Author:**
AOXC Core Engineering

Interface for the central access control and authority management.


## Functions
### hasRole


```solidity
function hasRole(bytes32 role, address account) external view returns (bool);
```

### getRoleAdmin


```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32);
```

### grantRole


```solidity
function grantRole(bytes32 role, address account) external;
```

### revokeRole


```solidity
function revokeRole(bytes32 role, address account) external;
```

### renounceRole


```solidity
function renounceRole(bytes32 role, address account) external;
```

### isGuardian


```solidity
function isGuardian(address account) external view returns (bool);
```

### isGovernor


```solidity
function isGovernor(address account) external view returns (bool);
```

### isSentinel


```solidity
function isSentinel(address account) external view returns (bool);
```

## Events
### RoleGranted

```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
```

### RoleRevoked

```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
```

