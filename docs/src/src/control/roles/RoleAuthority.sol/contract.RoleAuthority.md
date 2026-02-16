# RoleAuthority
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/control/roles/RoleAuthority.sol)

**Inherits:**
Initializable, AccessControlEnumerableUpgradeable, PausableUpgradeable, UUPSUpgradeable


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### _gap

```solidity
uint256[40] private _gap
```


## Functions
### constructor


```solidity
constructor() ;
```

### initialize


```solidity
function initialize(address admin, IMonitoringHub _monitoringHub) external initializer;
```

### _logToHub


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Errors
### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

