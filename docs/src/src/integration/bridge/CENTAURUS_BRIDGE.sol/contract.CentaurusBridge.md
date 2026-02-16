# CentaurusBridge
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/integration/bridge/CENTAURUS_BRIDGE.sol)

**Inherits:**
AccessControl, ReentrancyGuard

**Title:**
CentaurusBridge

SECTOR_ID 3: Cross-Chain Logistics and Data Dispatch

Fixed for Solc 0.8.33 memory/calldata conversion (Error 9553 fix).


## State Variables
### SECTOR_NAME

```solidity
string public constant SECTOR_NAME = "CENTAURUS_BRIDGE"
```


### SECTOR_ID

```solidity
uint256 public constant SECTOR_ID = 3
```


### CENTAURUS_CAPTAIN_ROLE

```solidity
bytes32 public constant CENTAURUS_CAPTAIN_ROLE = keccak256("CENTAURUS_CAPTAIN_ROLE")
```


### CENTAURUS_APEX

```solidity
bytes32 public constant CENTAURUS_APEX = keccak256("DEPT_CENTAURUS_APEX")
```


### CENTAURUS_KINETIC

```solidity
bytes32 public constant CENTAURUS_KINETIC = keccak256("DEPT_CENTAURUS_KINETIC")
```


### CENTAURUS_FLUX

```solidity
bytes32 public constant CENTAURUS_FLUX = keccak256("DEPT_CENTAURUS_FLUX")
```


### CENTAURUS_NEURAL

```solidity
bytes32 public constant CENTAURUS_NEURAL = keccak256("DEPT_CENTAURUS_NEURAL")
```


### CENTAURUS_AEGIS

```solidity
bytes32 public constant CENTAURUS_AEGIS = keccak256("DEPT_CENTAURUS_AEGIS")
```


### CENTAURUS_PULSE

```solidity
bytes32 public constant CENTAURUS_PULSE = keccak256("DEPT_CENTAURUS_PULSE")
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


### CENTAURUS_TOKEN

```solidity
CentaurusToken public immutable CENTAURUS_TOKEN
```


### activeRoutes

```solidity
mapping(uint256 => LogisticsPath) public activeRoutes
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

### dispatchData


```solidity
function dispatchData(uint256 _targetChain, bytes32 _dataHash)
    external
    onlyQualified(CENTAURUS_KINETIC)
    nonReentrant;
```

### establishRoute


```solidity
function establishRoute(uint256 _chainId, uint256 _strength)
    external
    onlyQualified(CENTAURUS_APEX);
```

### heartbeatSignal


```solidity
function heartbeatSignal(uint256 _chainId, uint256 _newStrength)
    external
    onlyQualified(CENTAURUS_PULSE);
```

### swapToAoxc


```solidity
function swapToAoxc(uint256 _centaurusAmount) external nonReentrant;
```

### swapFromAoxc


```solidity
function swapFromAoxc(uint256 _aoxcAmount) external nonReentrant;
```

### _checkRank


```solidity
function _checkRank(bytes32 _deptId) internal view;
```

### _getRequiredRank


```solidity
function _getRequiredRank(bytes32 _deptId) internal pure returns (uint256);
```

### _log

Memory bridge implemented to avoid Error 9553.


```solidity
function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal;
```

## Events
### RouteEstablished

```solidity
event RouteEstablished(uint256 indexed chainId, bool status);
```

### SignalRecalibrated

```solidity
event SignalRecalibrated(uint256 indexed chainId, uint256 newStrength);
```

### DispatchInitiated

```solidity
event DispatchInitiated(address indexed actor, uint256 targetChainId, bytes32 dataHash);
```

### SwapToAoxc

```solidity
event SwapToAoxc(address indexed user, uint256 centaurusAmount, uint256 aoxcAmount);
```

### SwapFromAoxc

```solidity
event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 centaurusAmount);
```

## Structs
### LogisticsPath

```solidity
struct LogisticsPath {
    uint256 targetChainId;
    bool isVerified;
    uint256 signalStrength; // 0-100
}
```

