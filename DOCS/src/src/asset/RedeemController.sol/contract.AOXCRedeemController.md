# AOXCRedeemController
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/asset/RedeemController.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
AOXCRedeemController

**Author:**
AOXC Protocol Team

Token imhası ve varlık tahliye yönetimi.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### REDEEMER_ROLE

```solidity
bytes32 public constant REDEEMER_ROLE = keccak256("AOXC_REDEEMER_ROLE")
```


### token

```solidity
AOXC public token
```


### ledger

```solidity
AssetBackingLedger public ledger
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### reputationManager

```solidity
IReputationManager public reputationManager
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


```solidity
function initialize(
    address admin,
    address _token,
    address _ledger,
    address _monitoringHub,
    address _reputationManager
) external initializer;
```

### redeem


```solidity
function redeem(address from, uint256 amount, bytes32 assetId)
    external
    whenNotPaused
    nonReentrant
    onlyRole(REDEEMER_ROLE);
```

### pause


```solidity
function pause() external onlyRole(ADMIN_ROLE);
```

### unpause


```solidity
function unpause() external onlyRole(ADMIN_ROLE);
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
function _authorizeUpgrade(
    address /* newImplementation */
)
    internal
    override
    onlyRole(ADMIN_ROLE);
```

## Events
### TokensRedeemed

```solidity
event TokensRedeemed(
    address indexed caller, address indexed from, uint256 indexed amount, bytes32 assetId
);
```

### BackingReleased

```solidity
event BackingReleased(
    address indexed caller, bytes32 indexed assetId, uint256 amount, uint256 timestamp
);
```

## Errors
### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

### AOXC__InsufficientTokens

```solidity
error AOXC__InsufficientTokens();
```

### AOXC__InvalidAssetId

```solidity
error AOXC__InvalidAssetId();
```

