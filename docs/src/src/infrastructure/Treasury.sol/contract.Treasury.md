# Treasury
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/infrastructure/Treasury.sol)

**Inherits:**
[ITreasury](/src/infrastructure/AOXCSwap.sol/interface.ITreasury.md), Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
Treasury

**Author:**
AOXC Core Engineering

Central ecosystem vault with Akdeniz V2 Forensic standard and cross-chain bridging.

Fully compliant with OZ 5.x (No __UUPSUpgradeable_init) and standard ReentrancyGuard.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### MANAGER_ROLE

```solidity
bytes32 public constant MANAGER_ROLE = keccak256("AOXC_MANAGER_ROLE")
```


### GUARDIAN_ROLE

```solidity
bytes32 public constant GUARDIAN_ROLE = keccak256("AOXC_GUARDIAN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### reputationManager

```solidity
IReputationManager public reputationManager
```


### bridgeAdapter

```solidity
IBridgeAdapter public bridgeAdapter
```


### timelock

```solidity
address public timelock
```


### _supportedTokensList

```solidity
address[] private _supportedTokensList
```


### isTokenSupported

```solidity
mapping(address => bool) public isTokenSupported
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

Proxy initialization for Akdeniz V2.

__UUPSUpgradeable_init is not present in OZ 5.x.


```solidity
function initialize(
    address admin,
    address _monitoringHub,
    address _timelock,
    address _bridgeAdapter,
    address _reputationManager
) external initializer;
```

### getSupportedTokens

Returns the list of all tokens currently supported by the Treasury.


```solidity
function getSupportedTokens() external view override returns (address[] memory);
```

### getTotalReserves

Returns total reserves value (Simplified balance check).


```solidity
function getTotalReserves() external view override returns (uint256 totalReserves);
```

### deposit

Primary deposit mechanism for Native and ERC20 assets.


```solidity
function deposit(address token, uint256 amount)
    external
    payable
    override
    whenNotPaused
    nonReentrant;
```

### withdraw

Controlled withdrawal through Governance (Timelock) or authorized Manager roles.


```solidity
function withdraw(address token, address to, uint256 amount) external override nonReentrant;
```

### emergencyWithdraw

Guardian-led emergency asset recovery.


```solidity
function emergencyWithdraw(address token, address to, uint256 amount)
    external
    override
    onlyRole(GUARDIAN_ROLE)
    nonReentrant;
```

### bridgeOut

Cross-chain liquidity deployment via Bridge Adapter.


```solidity
function bridgeOut(uint256 targetChainId, address token, uint256 amount, address recipient)
    external
    payable
    onlyRole(ADMIN_ROLE)
    nonReentrant;
```

### addSupportedToken


```solidity
function addSupportedToken(address token) external override onlyRole(ADMIN_ROLE);
```

### removeSupportedToken


```solidity
function removeSupportedToken(address token) external override onlyRole(ADMIN_ROLE);
```

### getBalance


```solidity
function getBalance(address token) public view override returns (uint256);
```

### _executeTransfer


```solidity
function _executeTransfer(address token, address to, uint256 amount) internal;
```

### _logToHub


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details,
    uint8 riskScore
) internal;
```

### pause


```solidity
function pause() external onlyRole(ADMIN_ROLE);
```

### unpause


```solidity
function unpause() external onlyRole(ADMIN_ROLE);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

### receive


```solidity
receive() external payable;
```

## Events
### TokenSupportUpdated

```solidity
event TokenSupportUpdated(address indexed token, bool status);
```

### Deposited

```solidity
event Deposited(address indexed sender, address indexed token, uint256 amount);
```

### Withdrawn

```solidity
event Withdrawn(address indexed recipient, address indexed token, uint256 amount);
```

### EmergencyAssetReleased

```solidity
event EmergencyAssetReleased(address indexed token, uint256 amount, address recipient);
```

