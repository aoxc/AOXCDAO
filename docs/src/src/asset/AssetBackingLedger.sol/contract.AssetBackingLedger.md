# AssetBackingLedger
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/asset/AssetBackingLedger.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
AssetBackingLedger

**Author:**
AOXC Core Engineering

Central accounting module for collateral assets in the AOXC ecosystem.

Fully compliant with 26-channel MonitoringHub and UUPS Proxy pattern (OZ v5).


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### ASSET_MANAGER_ROLE

```solidity
bytes32 public constant ASSET_MANAGER_ROLE = keccak256("AOXC_ASSET_MANAGER_ROLE")
```


### OPERATOR_ROLE

```solidity
bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### reputationManager

```solidity
IReputationManager public reputationManager
```


### totalAssets

```solidity
uint256 public totalAssets
```


### systemLimit

```solidity
uint256 public systemLimit
```


### _assetIds

```solidity
bytes32[] private _assetIds
```


### _assetBalances

```solidity
mapping(bytes32 => uint256) private _assetBalances
```


### _isAssetKnown

```solidity
mapping(bytes32 => bool) private _isAssetKnown
```


### _gap

```solidity
uint256[43] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Proxy initialization.


```solidity
function initialize(address admin, address _monitoringHub, address _reputationManager)
    external
    initializer;
```

### depositAsset


```solidity
function depositAsset(bytes32 assetId, uint256 amount)
    external
    onlyRole(ASSET_MANAGER_ROLE)
    whenNotPaused
    nonReentrant;
```

### withdrawAsset


```solidity
function withdrawAsset(bytes32 assetId, uint256 amount)
    external
    onlyRole(ASSET_MANAGER_ROLE)
    whenNotPaused
    nonReentrant;
```

### setSystemLimit


```solidity
function setSystemLimit(uint256 newLimit) external onlyRole(DEFAULT_ADMIN_ROLE);
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
function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE);
```

## Events
### AssetDeposited

```solidity
event AssetDeposited(
    address indexed caller, bytes32 indexed assetId, uint256 amount, uint256 timestamp
);
```

### AssetWithdrawn

```solidity
event AssetWithdrawn(
    address indexed caller, bytes32 indexed assetId, uint256 amount, uint256 timestamp
);
```

### TotalAssetsUpdated

```solidity
event TotalAssetsUpdated(uint256 oldTotal, uint256 newTotal, uint256 timestamp);
```

### SystemLimitUpdated

```solidity
event SystemLimitUpdated(uint256 oldLimit, uint256 newLimit);
```

## Errors
### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

### AOXC__ZeroAmount

```solidity
error AOXC__ZeroAmount();
```

### AOXC__InsufficientBalance

```solidity
error AOXC__InsufficientBalance();
```

### AOXC__InvalidAssetId

```solidity
error AOXC__InvalidAssetId();
```

### AOXC__SystemCapReached

```solidity
error AOXC__SystemCapReached(uint256 currentTotal, uint256 limit);
```

### AOXC__OnlyTimelock

```solidity
error AOXC__OnlyTimelock();
```

