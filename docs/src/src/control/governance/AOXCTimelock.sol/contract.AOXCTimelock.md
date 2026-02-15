# AOXCTimelock
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/control/governance/AOXCTimelock.sol)

**Inherits:**
Initializable, TimelockControllerUpgradeable, UUPSUpgradeable


## State Variables
### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")
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
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors,
    address admin,
    address _monitoring
) external initializer;
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
function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE);
```

## Events
### UpgradeAuthorized

```solidity
event UpgradeAuthorized(address indexed newImplementation);
```

