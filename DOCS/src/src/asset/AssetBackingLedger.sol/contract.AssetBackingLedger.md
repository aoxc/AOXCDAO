# AssetBackingLedger
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/asset/AssetBackingLedger.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
AssetBackingLedger

**Author:**
AOXCDAO

RWA muhasebe motoru ve sistem limit yönetim merkezi.

UUPS mimarisi ve 26-parametre Forensic standartlarına tam uyumlu profesyonel sürüm.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### ASSET_MANAGER_ROLE

```solidity
bytes32 public constant ASSET_MANAGER_ROLE = keccak256("AOXC_ASSET_MANAGER_ROLE")
```


### EXTERNAL_AI_AGENT_ROLE

```solidity
bytes32 public constant EXTERNAL_AI_AGENT_ROLE = keccak256("EXTERNAL_AI_AGENT_ROLE")
```


### ACTION_DEPOSIT

```solidity
bytes32 public constant ACTION_DEPOSIT = keccak256("ACTION_ASSET_DEPOSIT")
```


### ACTION_WITHDRAW

```solidity
bytes32 public constant ACTION_WITHDRAW = keccak256("ACTION_ASSET_WITHDRAW")
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


### _agentRegistry

```solidity
mapping(address => AiAgentMetadata) private _agentRegistry
```


### activeAgentCount

```solidity
uint256 public activeAgentCount
```


### _gap

```solidity
uint256[40] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Kontrat başlatıcı fonksiyon.


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

### _processAccounting


```solidity
function _processAccounting(bytes32 assetId, uint256 amount, bool isIncrease) internal;
```

### setSystemLimit


```solidity
function setSystemLimit(uint256 newLimit) external onlyRole(ADMIN_ROLE);
```

### registerAiAgent


```solidity
function registerAiAgent(address agent, bytes32 contractHash) external onlyRole(ADMIN_ROLE);
```

### updateDependencies


```solidity
function updateDependencies(address hub, address rep) external onlyRole(ADMIN_ROLE);
```

### pause


```solidity
function pause() external onlyRole(ADMIN_ROLE);
```

### unpause


```solidity
function unpause() external onlyRole(ADMIN_ROLE);
```

### getAssetBalance


```solidity
function getAssetBalance(bytes32 assetId) external view returns (uint256);
```

### getAllAssetIds


```solidity
function getAllAssetIds() external view returns (bytes32[] memory);
```

### _triggerReputation


```solidity
function _triggerReputation(bytes32 actionType) internal;
```

### _logToHub


```solidity
function _logToHub(IMonitoringHub.Severity severity, string memory cat, string memory details)
    internal;
```

### _authorizeUpgrade

UUPS upgrade yetkilendirmesi.


```solidity
function _authorizeUpgrade(
    address /* newImplementation */
)
    internal
    override
    onlyRole(ADMIN_ROLE);
```

## Events
### AssetDeposited

```solidity
event AssetDeposited(
    address indexed manager, bytes32 indexed assetId, uint256 amount, uint256 total
);
```

### AssetWithdrawn

```solidity
event AssetWithdrawn(
    address indexed manager, bytes32 indexed assetId, uint256 amount, uint256 total
);
```

### SystemLimitUpdated

```solidity
event SystemLimitUpdated(uint256 oldLimit, uint256 newLimit);
```

### AiAgentRegistered

```solidity
event AiAgentRegistered(address indexed agent, bytes32 indexed contractHash);
```

### DependencyUpdated

```solidity
event DependencyUpdated(address indexed monitoringHub, address indexed reputationManager);
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
error AOXC__SystemCapReached(uint256 current, uint256 limit);
```

### AOXC__AgentAlreadyRegistered

```solidity
error AOXC__AgentAlreadyRegistered(address agent);
```

### AOXC__InvalidContractHash

```solidity
error AOXC__InvalidContractHash();
```

## Structs
### AiAgentMetadata

```solidity
struct AiAgentMetadata {
    bytes32 contractHash;
    uint256 registeredAt;
    uint256 totalOperations;
    bool isActive;
}
```

