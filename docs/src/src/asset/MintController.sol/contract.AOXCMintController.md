# AOXCMintController
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/asset/MintController.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
AOXCMintController

**Author:**
AOXC Protocol Team

Varlık dayanaklı token basımı ve itfası için merkezi hub.


## State Variables
### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("AOXC_MINTER_ROLE")
```


### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### OPERATOR_ROLE

```solidity
bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE")
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


### assetIdToToken

```solidity
mapping(bytes32 => IERC20) public assetIdToToken
```


### frozenAssets

```solidity
mapping(bytes32 => bool) public frozenAssets
```


### maxMintPerTx

```solidity
mapping(bytes32 => uint256) public maxMintPerTx
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
    address _ledger,
    address _monitoringHub,
    address _reputationManager
) external initializer;
```

### mint


```solidity
function mint(address to, uint256 amount, bytes32 assetId)
    external
    whenNotPaused
    nonReentrant
    onlyRole(MINTER_ROLE);
```

### redeem


```solidity
function redeem(uint256 amount, bytes32 assetId) external whenNotPaused nonReentrant;
```

### setAssetMapping


```solidity
function setAssetMapping(bytes32 assetId, address tokenAddress) external onlyRole(ADMIN_ROLE);
```

### setSafetyLimit


```solidity
function setSafetyLimit(bytes32 assetId, uint256 limit) external onlyRole(ADMIN_ROLE);
```

### toggleFreeze


```solidity
function toggleFreeze(bytes32 assetId, bool status) external onlyRole(OPERATOR_ROLE);
```

### pause


```solidity
function pause() external onlyRole(ADMIN_ROLE);
```

### unpause


```solidity
function unpause() external onlyRole(ADMIN_ROLE);
```

### _notifyHub


```solidity
function _notifyHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory message
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
### TokensMinted

```solidity
event TokensMinted(
    address indexed caller, address indexed to, uint256 amount, bytes32 indexed assetId
);
```

### TokensRedeemed

```solidity
event TokensRedeemed(
    address indexed caller, address indexed from, uint256 amount, bytes32 indexed assetId
);
```

## Errors
### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

### AOXC__ExceedsMintLimit

```solidity
error AOXC__ExceedsMintLimit(uint256 requested, uint256 limit);
```

### AOXC__AssetFrozen

```solidity
error AOXC__AssetFrozen(bytes32 assetId);
```

### AOXC__InvalidToken

```solidity
error AOXC__InvalidToken();
```

