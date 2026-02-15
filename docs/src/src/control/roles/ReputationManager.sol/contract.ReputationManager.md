# ReputationManager
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/control/roles/ReputationManager.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
ReputationManager

**Author:**
AOXC Core Engineering

Akdeniz V2 Reputation Engine - Full 26-Channel Forensic Integration.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE")
```


### OPERATOR_ROLE

```solidity
bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")
```


### aoxp

```solidity
IAOXP public aoxp
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### actions

```solidity
mapping(bytes32 => ActionConfig) public actions
```


### _users

```solidity
mapping(address => UserData) private _users
```


### thresholds

```solidity
uint256[] public thresholds
```


### multipliers

```solidity
uint256[] public multipliers
```


### minMultiplier

```solidity
uint256 public minMultiplier
```


### maxMultiplier

```solidity
uint256 public maxMultiplier
```


### _gap

```solidity
uint256[42] private _gap
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
    address _aoxp,
    address _monitoringHub,
    uint256 _minMultiplier,
    uint256 _maxMultiplier,
    uint256[] memory _thresholds,
    uint256[] memory _multipliers
) external initializer;
```

### setAction


```solidity
function setAction(bytes32 actionType, uint256 reward, uint256 weight, uint256 cooldown)
    external
    onlyRole(ADMIN_ROLE);
```

### processAction


```solidity
function processAction(address user, bytes32 actionType)
    external
    onlyRole(OPERATOR_ROLE)
    whenNotPaused
    nonReentrant;
```

### getMultiplier


```solidity
function getMultiplier(address user) external view returns (uint256);
```

### _calculateMultiplier


```solidity
function _calculateMultiplier(uint256 score) internal view returns (uint256);
```

### _logToHub

26-Channel Akdeniz V2 Forensic Logging


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### ActionConfigured

```solidity
event ActionConfigured(
    bytes32 indexed actionType, uint256 reward, uint256 weight, uint256 cooldown
);
```

### ReputationProcessed

```solidity
event ReputationProcessed(address indexed user, bytes32 indexed actionType, uint256 newScore);
```

## Structs
### ActionConfig

```solidity
struct ActionConfig {
    uint256 reward;
    uint256 weight;
    uint256 cooldown;
}
```

### UserData

```solidity
struct UserData {
    uint256 score;
    uint256 multiplier;
    uint256 lastAction;
}
```

