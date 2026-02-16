# QuasarSentry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/security/sentinel/QUASAR_SENTRY.sol)

**Inherits:**
AccessControl, ReentrancyGuard

**Title:**
QuasarSentry

SECTOR_ID 2: Fleet Security and Defense

Re-engineered for audit safety and naming consistency.


## State Variables
### SECTOR_NAME

```solidity
string public constant SECTOR_NAME = "QUASAR_SENTRY"
```


### SECTOR_ID

```solidity
uint256 public constant SECTOR_ID = 2
```


### QUASAR_CAPTAIN_ROLE

```solidity
bytes32 public constant QUASAR_CAPTAIN_ROLE = keccak256("QUASAR_CAPTAIN_ROLE")
```


### QUASAR_APEX

```solidity
bytes32 public constant QUASAR_APEX = keccak256("DEPT_QUASAR_APEX")
```


### QUASAR_KINETIC

```solidity
bytes32 public constant QUASAR_KINETIC = keccak256("DEPT_QUASAR_KINETIC")
```


### QUASAR_FLUX

```solidity
bytes32 public constant QUASAR_FLUX = keccak256("DEPT_QUASAR_FLUX")
```


### QUASAR_NEURAL

```solidity
bytes32 public constant QUASAR_NEURAL = keccak256("DEPT_QUASAR_NEURAL")
```


### QUASAR_AEGIS

```solidity
bytes32 public constant QUASAR_AEGIS = keccak256("DEPT_QUASAR_AEGIS")
```


### QUASAR_PULSE

```solidity
bytes32 public constant QUASAR_PULSE = keccak256("DEPT_QUASAR_PULSE")
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


### QUASAR_TOKEN

```solidity
QuasarToken public immutable QUASAR_TOKEN
```


### fleetWideLockdown

```solidity
bool public fleetWideLockdown
```


### sectorBlacklist

```solidity
mapping(address => bool) public sectorBlacklist
```


## Functions
### onlyRanked


```solidity
modifier onlyRanked(bytes32 _deptId) ;
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

### triggerGlobalLockdown


```solidity
function triggerGlobalLockdown(bool _status) external onlyRanked(QUASAR_APEX);
```

### quarantineSector

External call with try-catch. Correctly uses MONITORING_HUB.


```solidity
function quarantineSector(address _targetSector, string calldata _reason)
    external
    onlyRanked(QUASAR_KINETIC);
```

### finalizeThreatReport


```solidity
function finalizeThreatReport(uint256 _level) external onlyRanked(QUASAR_NEURAL);
```

### swapToAoxc


```solidity
function swapToAoxc(uint256 _quasarAmount) external nonReentrant;
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


```solidity
function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal;
```

## Events
### FleetLockdownStatus

```solidity
event FleetLockdownStatus(bool status, address indexed commander);
```

### SectorQuarantined

```solidity
event SectorQuarantined(address indexed targetSector, string reason);
```

### ThreatLevelEscalated

```solidity
event ThreatLevelEscalated(uint256 level);
```

### SwapToAoxc

```solidity
event SwapToAoxc(address indexed user, uint256 quasarAmount, uint256 aoxcAmount);
```

### SwapFromAoxc

```solidity
event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 quasarAmount);
```

