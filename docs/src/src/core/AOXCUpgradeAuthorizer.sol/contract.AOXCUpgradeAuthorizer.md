# AOXCUpgradeAuthorizer
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/core/AOXCUpgradeAuthorizer.sol)

**Inherits:**
Initializable, AccessControlEnumerableUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard, [IAOXCUpgradeAuthorizer](/src/interfaces/IAOXCUpgradeAuthorizer.sol/interface.IAOXCUpgradeAuthorizer.md)

**Title:**
AOXCUpgradeAuthorizer

**Author:**
AOXC Core Engineering

Enterprise-grade multi-sig approval and rate-limiting mechanism for AOXC upgrades.

Fully compliant with 26-channel MonitoringHub forensic standards.


## State Variables
### UPGRADE_ADMIN_ROLE

```solidity
bytes32 public constant UPGRADE_ADMIN_ROLE = keccak256("AOXC_UPGRADE_ADMIN_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### lastUpgradeTimestamp

```solidity
uint256 public lastUpgradeTimestamp
```


### minUpgradeInterval

```solidity
uint256 public minUpgradeInterval
```


### upgradeNonce

```solidity
uint256 public upgradeNonce
```


### requiredApprovals

```solidity
uint256 public requiredApprovals
```


### implementationApprovals

```solidity
mapping(uint256 => mapping(address => uint256)) public implementationApprovals
```


### _hasApproved

```solidity
mapping(uint256 => mapping(address => mapping(address => bool))) private _hasApproved
```


### _gap

```solidity
uint256[41] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the Upgrade Authorizer.


```solidity
function initialize(
    address admin,
    address _monitoringHub,
    uint256 _requiredApprovals,
    uint256 _minInterval
) external initializer;
```

### approveUpgrade

Casts a vote for a specific new implementation address.


```solidity
function approveUpgrade(address newImplementation)
    external
    onlyRole(UPGRADE_ADMIN_ROLE)
    whenNotPaused;
```

### validateUpgrade

Validates an upgrade request during the UUPS transaction lifecycle.


```solidity
function validateUpgrade(address caller, address newImplementation)
    external
    override
    whenNotPaused
    nonReentrant;
```

### setRequiredApprovals


```solidity
function setRequiredApprovals(uint256 newRequired) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### setMinInterval


```solidity
function setMinInterval(uint256 newInterval) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### isUpgradeAuthorized


```solidity
function isUpgradeAuthorized(address implementation) external view override returns (bool);
```

### getAuthorizerVersion


```solidity
function getAuthorizerVersion() external pure override returns (uint256);
```

### _logToHub

High-fidelity 26-channel forensic logging.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE);
```

## Errors
### AOXC__UnauthorizedCaller

```solidity
error AOXC__UnauthorizedCaller(address caller);
```

### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

### AOXC__InsufficientApprovals

```solidity
error AOXC__InsufficientApprovals(uint256 required, uint256 current);
```

### AOXC__UpgradeRateLimited

```solidity
error AOXC__UpgradeRateLimited(uint256 nextAvailable);
```

### AOXC__AlreadyApproved

```solidity
error AOXC__AlreadyApproved();
```

### AOXC__InvalidImplementation

```solidity
error AOXC__InvalidImplementation();
```

