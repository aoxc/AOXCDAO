# AOXCSovereignCommander
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/security/AOXCSovereignCommander.sol)

**Title:**
AOXCSovereignCommander

Centralized interface for modular sector isolation and forensic response.


## State Variables
### COORDINATOR

```solidity
IAOXCAccessCoordinator public immutable COORDINATOR
```


### SOVEREIGN

```solidity
address public immutable SOVEREIGN = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84
```


## Functions
### constructor


```solidity
constructor(address _coordinator) ;
```

### isolateSector

Freezes a specific sector in response to an anomaly.


```solidity
function isolateSector(bytes32 _sectorId, string calldata _reason) external;
```

### _logToHub


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory category,
    string memory details
) internal;
```

## Events
### SectorIsolationTriggered

```solidity
event SectorIsolationTriggered(bytes32 indexed sectorId, string reason);
```

