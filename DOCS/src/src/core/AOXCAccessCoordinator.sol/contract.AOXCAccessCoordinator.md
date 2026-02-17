# AOXCAccessCoordinator
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/core/AOXCAccessCoordinator.sol)

**Inherits:**
[IAOXCAccessCoordinator](/src/interfaces/IAOXCAccessCoordinator.sol/interface.IAOXCAccessCoordinator.md), AccessControlEnumerable, Pausable

**Title:**
AOXCAccessCoordinator

**Author:**
AOXC Core Engineering

The central nervous system of AOXC V2. Coordinates roles, forensic monitoring, and emergency states.

Acts as the definitive source of truth for permissions and protocol-wide circuit breaking.


## State Variables
### currentStatus

```solidity
SystemStatus public currentStatus
```


### _monitoringHub

```solidity
IMonitoringHub private _monitoringHub
```


### sectorStatus

```solidity
mapping(bytes32 => bool) public sectorStatus
```


### SOVEREIGN_MULTISIG

```solidity
address public immutable SOVEREIGN_MULTISIG = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84
```


## Functions
### constructor


```solidity
constructor(address rootAdmin, address initialHub) ;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`rootAdmin`|`address`|The initial super-admin address.|
|`initialHub`|`address`|The initial Monitoring Hub address.|


### monitoringHub

Returns the active Monitoring Hub for forensic logging.


```solidity
function monitoringHub() external view override returns (IMonitoringHub);
```

### setSectorStatus

Enables or disables a specific operational sector (e.g., Andromeda, Aquila).


```solidity
function setSectorStatus(bytes32 sectorId, bool status) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sectorId`|`bytes32`|keccak256 hash of the sector identifier.|
|`status`|`bool`|True for active, false for frozen.|


### hasSovereignPower

Check if an account has Sovereign level powers.

Core verification for AOXCScorchedEarth.


```solidity
function hasSovereignPower(address account) external view override returns (bool);
```

### triggerGlobalLockdown

Global trigger for Scorched Earth and Emergency Pause.

Satisfies requirements for Plan C activation.


```solidity
function triggerGlobalLockdown() external override;
```

### triggerEmergencyPause

Standard emergency pause for automated sentinel response.

Corrects the 'abstract' error by implementing the interface requirement.


```solidity
function triggerEmergencyPause(string calldata reason) external override;
```

### releaseGlobalLockdown

Releases the global lockdown and restores flow.


```solidity
function releaseGlobalLockdown() external override;
```

### isOperationAllowed

Checks if an operation is permitted under current system state.


```solidity
function isOperationAllowed(bytes32 role, address account)
    external
    view
    override
    returns (bool);
```

### updateMonitoringHub

Updates the forensic monitoring hub.


```solidity
function updateMonitoringHub(address newHub) external onlyRole(AOXCConstants.ADMIN_ROLE);
```

### terminateProtocol

Irreversible termination of the protocol logic.


```solidity
function terminateProtocol() external onlyRole(AOXCConstants.ADMIN_ROLE);
```

## Events
### SystemStatusChanged

```solidity
event SystemStatusChanged(
    SystemStatus indexed previous, SystemStatus indexed current, address indexed actor
);
```

### EmergencyActionTriggered

```solidity
event EmergencyActionTriggered(string reason, address indexed sentinel);
```

### SectorStatusUpdated

```solidity
event SectorStatusUpdated(bytes32 indexed sectorId, bool status);
```

### MonitoringHubUpdated

```solidity
event MonitoringHubUpdated(address indexed newHub);
```

## Errors
### AOXCUnauthorizedAccount

```solidity
error AOXCUnauthorizedAccount(address account, bytes32 neededRole);
```

### AlreadyInState

```solidity
error AlreadyInState(SystemStatus status);
```

## Enums
### SystemStatus

```solidity
enum SystemStatus {
    ACTIVE,
    DEGRADED,
    EMERGENCY_PAUSE,
    TERMINATED
}
```

