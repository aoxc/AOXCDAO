# PegasusOracle
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/integration/oracle/PEGASUS_ORACLE.sol)

**Inherits:**
AccessControl, ReentrancyGuard

**Title:**
PegasusOracle

SECTOR_ID 4: Oracle and Intelligence Synthesis

Academic and Professional Grade Smart Contract with AOXP Multiplier Logic


## State Variables
### SECTOR_NAME

```solidity
string public constant SECTOR_NAME = "PEGASUS_ORACLE"
```


### SECTOR_ID

```solidity
uint256 public constant SECTOR_ID = 4
```


### PEGASUS_APEX

```solidity
bytes32 public constant PEGASUS_APEX = keccak256("DEPT_PEGASUS_APEX")
```


### PEGASUS_KINETIC

```solidity
bytes32 public constant PEGASUS_KINETIC = keccak256("DEPT_PEGASUS_KINETIC")
```


### PEGASUS_FLUX

```solidity
bytes32 public constant PEGASUS_FLUX = keccak256("DEPT_PEGASUS_FLUX")
```


### PEGASUS_NEURAL

```solidity
bytes32 public constant PEGASUS_NEURAL = keccak256("DEPT_PEGASUS_NEURAL")
```


### PEGASUS_AEGIS

```solidity
bytes32 public constant PEGASUS_AEGIS = keccak256("DEPT_PEGASUS_AEGIS")
```


### PEGASUS_PULSE

```solidity
bytes32 public constant PEGASUS_PULSE = keccak256("DEPT_PEGASUS_PULSE")
```


### PEGASUS_CAPTAIN_ROLE

```solidity
bytes32 public constant PEGASUS_CAPTAIN_ROLE = keccak256("PEGASUS_CAPTAIN_ROLE")
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


### PEGASUS_TOKEN

```solidity
PegasusToken public immutable PEGASUS_TOKEN
```


### oracleRegistry

```solidity
mapping(bytes32 => IntelligenceReport) public oracleRegistry
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

### synthesizeData


```solidity
function synthesizeData(bytes32 _dataKey, uint256 _rawValue, bytes32 _proof)
    external
    onlyQualified(PEGASUS_NEURAL)
    nonReentrant;
```

### ingestStream

IngestStream fixed to avoid 'Unused Function Parameter' warning.


```solidity
function ingestStream(bytes32 _dataKey, uint256 _value) external onlyQualified(PEGASUS_PULSE);
```

### invalidateData


```solidity
function invalidateData(bytes32 _dataKey, string calldata _reason)
    external
    onlyQualified(PEGASUS_AEGIS);
```

### swapToAoxc


```solidity
function swapToAoxc(uint256 pegasusAmount) external nonReentrant;
```

### swapFromAoxc


```solidity
function swapFromAoxc(uint256 aoxcAmount) external nonReentrant;
```

### _checkRank

Logic moved to internal function to optimize bytecode and contract size.


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
### IntelligenceSynthesized

```solidity
event IntelligenceSynthesized(bytes32 indexed dataKey, uint256 value, address indexed synther);
```

### DataBlacklisted

```solidity
event DataBlacklisted(bytes32 indexed dataKey, string reason);
```

### SwapToAoxc

```solidity
event SwapToAoxc(address indexed user, uint256 pegasusAmount, uint256 aoxcAmount);
```

### SwapFromAoxc

```solidity
event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 pegasusAmount);
```

### StreamIngested

```solidity
event StreamIngested(bytes32 indexed dataKey, uint256 value);
```

## Structs
### IntelligenceReport

```solidity
struct IntelligenceReport {
    uint256 timestamp;
    uint256 value;
    bytes32 sourceHash;
    bool isValidated;
}
```

