# IAOXCAccessCoordinator
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/interfaces/IAOXCAccessCoordinator.sol)

**Title:**
IAOXCAccessCoordinator

Interface defining the core authority and emergency signaling of the AOXC Fleet.

This bridge allows modular components (CircuitBreaker, ScorchedEarth, etc.) to
communicate with the central nervous system.


## Functions
### hasSovereignPower


```solidity
function hasSovereignPower(address account) external view returns (bool);
```

### isOperationAllowed


```solidity
function isOperationAllowed(bytes32 role, address account) external view returns (bool);
```

### triggerGlobalLockdown

Global signal for Scorched Earth protocols.


```solidity
function triggerGlobalLockdown() external;
```

### releaseGlobalLockdown

Releases system-wide pause.


```solidity
function releaseGlobalLockdown() external;
```

### triggerEmergencyPause

Standard emergency pause for automated sentinel response.

Resolves "Member not found" error in AOXCCircuitBreaker.


```solidity
function triggerEmergencyPause(string calldata reason) external;
```

### monitoringHub

Returns the active Monitoring Hub for forensic logging.


```solidity
function monitoringHub() external view returns (IMonitoringHub);
```

### setSectorStatus

Manages individual module/sector access states.


```solidity
function setSectorStatus(bytes32 sectorId, bool status) external;
```

