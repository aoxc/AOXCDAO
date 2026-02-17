# AOXCSafeguardVault
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/infrastructure/AOXCSafeguardVault.sol)

**Inherits:**
ReentrancyGuard

**Title:**
AOXCSafeguardVault

**Author:**
AOXC Core Engineering

Segregated reserve for autonomous victim compensation and emergency relief.

Fully integrated with the MonitoringHub for forensic accountability.


## State Variables
### SOVEREIGN
Sovereign Authority (Multisig: 0x20c0...CA84)


```solidity
address public immutable SOVEREIGN = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84
```


### COORDINATOR
Fleet Coordinator


```solidity
IAOXCAccessCoordinator public immutable COORDINATOR
```


### commander
Authorized Commander Module


```solidity
address public commander
```


## Functions
### constructor


```solidity
constructor(address _coordinator) ;
```

### setCommander

Links the SovereignCommander to this vault for automated aid.


```solidity
function setCommander(address _commander) external;
```

### releaseCompensation

Transfers aid/compensation to impacted users.

Strictly restricted to Sovereign or Authorized Commander.


```solidity
function releaseCompensation(address _victim, uint256 _amount) external nonReentrant;
```

### _logToHub

Internal forensic logging via MonitoringHub.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory category,
    string memory details
) internal;
```

### receive


```solidity
receive() external payable;
```

## Events
### SafeguardRefilled

```solidity
event SafeguardRefilled(uint256 amount);
```

### CompensationExecuted

```solidity
event CompensationExecuted(address indexed victim, uint256 amount);
```

### CommanderUpdated

```solidity
event CommanderUpdated(address indexed newCommander);
```

