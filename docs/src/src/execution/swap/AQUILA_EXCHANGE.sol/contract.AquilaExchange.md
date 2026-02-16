# AquilaExchange
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/execution/swap/AQUILA_EXCHANGE.sol)

**Inherits:**
AccessControl, ReentrancyGuard

**Title:**
AquilaExchange

SECTOR_ID 5: Economic Exchange and Liquidity Hub

Re-engineered for audit compliance and gas efficiency.


## State Variables
### SECTOR_NAME

```solidity
string public constant SECTOR_NAME = "AQUILA_EXCHANGE"
```


### SECTOR_ID

```solidity
uint256 public constant SECTOR_ID = 5
```


### AQUILA_CAPTAIN_ROLE

```solidity
bytes32 public constant AQUILA_CAPTAIN_ROLE = keccak256("AQUILA_CAPTAIN_ROLE")
```


### AQUILA_APEX

```solidity
bytes32 public constant AQUILA_APEX = keccak256("DEPT_AQUILA_APEX")
```


### AQUILA_KINETIC

```solidity
bytes32 public constant AQUILA_KINETIC = keccak256("DEPT_AQUILA_KINETIC")
```


### AQUILA_FLUX

```solidity
bytes32 public constant AQUILA_FLUX = keccak256("DEPT_AQUILA_FLUX")
```


### AQUILA_NEURAL

```solidity
bytes32 public constant AQUILA_NEURAL = keccak256("DEPT_AQUILA_NEURAL")
```


### AQUILA_AEGIS

```solidity
bytes32 public constant AQUILA_AEGIS = keccak256("DEPT_AQUILA_AEGIS")
```


### AQUILA_PULSE

```solidity
bytes32 public constant AQUILA_PULSE = keccak256("DEPT_AQUILA_PULSE")
```


### REPUTATION_MANAGER

```solidity
IReputationManager public immutable REPUTATION_MANAGER
```


### MONITORING_HUB

```solidity
IMonitoringHub public immutable MONITORING_HUB
```


### AOXC_TOKEN

```solidity
IERC20 public immutable AOXC_TOKEN
```


### AQUILA_TOKEN

```solidity
AquilaToken public immutable AQUILA_TOKEN
```


### registry

```solidity
mapping(bytes32 => MarketPair) public registry
```


## Functions
### onlyQualified


```solidity
modifier onlyQualified(bytes32 _deptId) ;
```

### constructor


```solidity
constructor(
    address _reputation,
    address _monitoring,
    address _andromeda,
    address _captain,
    address _aoxcToken
) ;
```

### manageLiquidity

Liquidity management now emits event with data.
In a real DEX, this would interact with a pool contract.


```solidity
function manageLiquidity(bytes32 _pair, uint256 _amount)
    external
    onlyQualified(AQUILA_FLUX)
    nonReentrant;
```

### recalibratePricing


```solidity
function recalibratePricing(bytes32 _pair, uint256 _newFee)
    external
    onlyQualified(AQUILA_NEURAL);
```

### haltMarket


```solidity
function haltMarket(bytes32 _pair, string calldata _reason)
    external
    onlyQualified(AQUILA_AEGIS);
```

### swapToAoxc


```solidity
function swapToAoxc(uint256 _aquilaAmount) external nonReentrant;
```

### swapFromAoxc


```solidity
function swapFromAoxc(uint256 _aoxcAmount) external nonReentrant;
```

### _checkRank


```solidity
function _checkRank(bytes32 _deptId) internal view;
```

### _getRankRequirement


```solidity
function _getRankRequirement(bytes32 _deptId) internal pure returns (uint256);
```

### _log


```solidity
function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal;
```

## Events
### TradeExecuted

```solidity
event TradeExecuted(address indexed trader, bytes32 indexed pair, uint256 amount);
```

### LiquidityInjected

```solidity
event LiquidityInjected(bytes32 indexed pair, uint256 amount);
```

### MarketHalted

```solidity
event MarketHalted(bytes32 indexed pair, string reason);
```

### SwapToAoxc

```solidity
event SwapToAoxc(address indexed user, uint256 aquilaAmount, uint256 aoxcAmount);
```

### SwapFromAoxc

```solidity
event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 aquilaAmount);
```

## Structs
### MarketPair

```solidity
struct MarketPair {
    uint256 tradeFee;
    uint256 volumeLimit;
    bool isTradingEnabled;
}
```

