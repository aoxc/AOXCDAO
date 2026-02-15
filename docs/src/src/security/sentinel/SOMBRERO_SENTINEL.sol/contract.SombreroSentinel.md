# SombreroSentinel
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/security/sentinel/SOMBRERO_SENTINEL.sol)

**Inherits:**
AccessControl, ReentrancyGuard

**Title:**
SombreroSentinel

SECTOR_ID 2: Security Surveillance and Intervention

Re-engineered to solve Error 9553 (calldata/memory mismatch)


## State Variables
### SECTOR_NAME

```solidity
string public constant SECTOR_NAME = "SOMBRERO_SENTINEL"
```


### SECTOR_ID

```solidity
uint256 public constant SECTOR_ID = 2
```


### SOMBRERO_CAPTAIN_ROLE

```solidity
bytes32 public constant SOMBRERO_CAPTAIN_ROLE = keccak256("SOMBRERO_CAPTAIN_ROLE")
```


### SOMBRERO_APEX

```solidity
bytes32 public constant SOMBRERO_APEX = keccak256("DEPT_SOMBRERO_APEX")
```


### SOMBRERO_KINETIC

```solidity
bytes32 public constant SOMBRERO_KINETIC = keccak256("DEPT_SOMBRERO_KINETIC")
```


### SOMBRERO_FLUX

```solidity
bytes32 public constant SOMBRERO_FLUX = keccak256("DEPT_SOMBRERO_FLUX")
```


### SOMBRERO_NEURAL

```solidity
bytes32 public constant SOMBRERO_NEURAL = keccak256("DEPT_SOMBRERO_NEURAL")
```


### SOMBRERO_AEGIS

```solidity
bytes32 public constant SOMBRERO_AEGIS = keccak256("DEPT_SOMBRERO_AEGIS")
```


### SOMBRERO_PULSE

```solidity
bytes32 public constant SOMBRERO_PULSE = keccak256("DEPT_SOMBRERO_PULSE")
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


### SOMBRERO_TOKEN

```solidity
SombreroToken public immutable SOMBRERO_TOKEN
```


### protocols

```solidity
mapping(bytes32 => SecurityProtocol) public protocols
```


### fleetWideRedAlert

```solidity
bool public fleetWideRedAlert
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

### _initializeProtocols


```solidity
function _initializeProtocols() internal;
```

### triggerRedAlert


```solidity
function triggerRedAlert(bool _active) external onlyQualified(SOMBRERO_APEX);
```

### reportAnomaly


```solidity
function reportAnomaly(string calldata _threatType, address _suspect)
    external
    onlyQualified(SOMBRERO_PULSE);
```

### executeIntervention


```solidity
function executeIntervention(address _targetSector, string calldata _reason)
    external
    onlyQualified(SOMBRERO_KINETIC);
```

### swapToAoxc


```solidity
function swapToAoxc(uint256 _sombreroAmount) external nonReentrant;
```

### swapFromAoxc


```solidity
function swapFromAoxc(uint256 _aoxcAmount) external nonReentrant;
```

### _checkQualification


```solidity
function _checkQualification(bytes32 _deptId) internal view;
```

### _log

FIX: Parametreleri 'memory' yaparak literal string kabulünü sağlıyoruz.


```solidity
function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal;
```

## Events
### ThreatDetected

```solidity
event ThreatDetected(string threatType, address indexed suspect, uint256 severity);
```

### FleetStateChanged

```solidity
event FleetStateChanged(bool isRedAlert, address indexed commander);
```

### InterventionExecuted

```solidity
event InterventionExecuted(address indexed targetSector, string reason);
```

### SwapToAoxc

```solidity
event SwapToAoxc(address indexed user, uint256 sombreroAmount, uint256 aoxcAmount);
```

### SwapFromAoxc

```solidity
event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 sombreroAmount);
```

## Structs
### SecurityProtocol

```solidity
struct SecurityProtocol {
    uint256 minRank;
    bool alertActive;
    uint256 incidentCount;
}
```

