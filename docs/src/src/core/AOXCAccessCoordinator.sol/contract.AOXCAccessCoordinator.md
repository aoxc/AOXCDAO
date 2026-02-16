# AOXCAccessCoordinator
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/core/AOXCAccessCoordinator.sol)

**Inherits:**
AccessControlEnumerable, Pausable

**Title:**
AOXCAccessCoordinator

**Author:**
AOXC Core Engineering

The central nervous system of AOXC V2. Coordinates roles and emergency states.

Acts as the definitive source of truth for permissions and protocol-wide circuit breaking.


## State Variables
### currentStatus

```solidity
SystemStatus public currentStatus
```


## Functions
### constructor


```solidity
constructor(address rootAdmin) ;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`rootAdmin`|`address`|The initial super-admin address (usually a DAO or Multisig).|


### triggerEmergencyPause

Triggers a protocol-wide emergency pause.

Accessible by SENTINEL_ROLE for rapid response or ADMIN_ROLE.


```solidity
function triggerEmergencyPause(string calldata reason) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reason`|`string`|The descriptive reason for the emergency action.|


### resumeProtocol

Resumes the protocol after safety verification.

Strictly restricted to ADMIN_ROLE.


```solidity
function resumeProtocol() external onlyRole(AOXCConstants.ADMIN_ROLE);
```

### isOperationAllowed

Global check to see if an operation is allowed under current system status.


```solidity
function isOperationAllowed(bytes32 role, address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|The role identifier being checked.|
|`account`|`address`|The address of the user or contract.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the operation is permitted.|


### terminateProtocol

Permanently shuts down the protocol (Nuclear Option).

Irreversible action. Use with extreme caution.


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

## Errors
### AOXCUnauthorizedAccount
Error thrown when an account lacks the required role.


```solidity
error AOXCUnauthorizedAccount(address account, bytes32 neededRole);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address that attempted the unauthorized action.|
|`neededRole`|`bytes32`|The specific role required for the action.|

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

