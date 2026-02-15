# IAOXCAndromedaCore
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/IAOXCAndromedaCore.sol)

**Title:**
IAOXCAndromedaCore

**Author:**
AOXCDAO Institutional Engineering

Central coordination interface for the AOXC v2 Prime "Andromeda" Ecosystem.

Defines the communication protocols between the 11 functional hangars.
This interface serves as the "Single Source of Truth" for module authorization
and protocol state management, ensuring MiCA and FinCEN compliance through
structured governance gates.
🎓 LEVEL: Pro Ultimate Academic
🏛️ MODULE: Core Infrastructure
🛡️ STANDARD: OpenZeppelin 5.5.x Compliance


## Functions
### getHangarManifest

Retrieves the full manifest record of a specific hangar.


```solidity
function getHangarManifest(bytes32 moduleId) external view returns (HangarManifest memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`moduleId`|`bytes32`|The unique Keccak256 identifier of the hangar.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`HangarManifest`|HangarManifest The structured record of the requested module.|


### isAuthorizedModule

Validates if a specific address is an authorized hangar for a given module ID.


```solidity
function isAuthorizedModule(address caller, bytes32 targetModule) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`caller`|`address`|The address to verify.|
|`targetModule`|`bytes32`|The module ID they claim to represent.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the caller is the registered and active hangar address.|


### getProtocolState

Returns the current operational state of the entire ecosystem.


```solidity
function getProtocolState() external view returns (ProtocolState);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`ProtocolState`|ProtocolState Current state (Active, Paused, or Upgrading).|


### transitionProtocolState

Transitions the protocol to a new state.

Must be restricted to high-tier governance (AOXCGovernor).


```solidity
function transitionProtocolState(ProtocolState newState) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newState`|`ProtocolState`|The target state to enter.|


### anchorHangar

Anchors (registers) a new functional hangar into the Andromeda ecosystem.

This is the primary method for modular expansion.


```solidity
function anchorHangar(bytes32 moduleId, address hangarAddress, uint256 version) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`moduleId`|`bytes32`|The unique identifier for the module.|
|`hangarAddress`|`address`|The physical address of the deployed contract.|
|`version`|`uint256`|The initial version of the module.|


### setHangarStatus

Updates the operational status of an existing hangar.


```solidity
function setHangarStatus(bytes32 moduleId, bool status) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`moduleId`|`bytes32`|The identifier of the module to modify.|
|`status`|`bool`|The new operational status (true for active).|


## Events
### ModuleAnchored
Emitted when a new hangar module is formally anchored to the core.


```solidity
event ModuleAnchored(bytes32 indexed moduleId, address indexed hangarAddress, uint256 version);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`moduleId`|`bytes32`|The unique identifier of the module.|
|`hangarAddress`|`address`|The physical address of the hangar.|
|`version`|`uint256`|The semantic version of the anchored module.|

### ProtocolStateTransition
Emitted when the protocol transitions between operational states.


```solidity
event ProtocolStateTransition(
    ProtocolState indexed previousState, ProtocolState indexed newState
);
```

### ComplianceStatusUpdated
Emitted when a hangar's compliance status is updated by the ComplianceRegistry.


```solidity
event ComplianceStatusUpdated(bytes32 indexed moduleId, bool status);
```

## Errors
### Andromeda_UnauthorizedModule
Thrown when a non-authorized module attempts a restricted action.


```solidity
error Andromeda_UnauthorizedModule(address caller, bytes32 requiredModule);
```

### Andromeda_ModuleAlreadyAnchored
Thrown when attempting to register a module ID that already exists.


```solidity
error Andromeda_ModuleAlreadyAnchored(bytes32 moduleId);
```

### Andromeda_InvalidHangarAddress
Thrown when a provided hangar address is null or invalid.


```solidity
error Andromeda_InvalidHangarAddress(address hangar);
```

### Andromeda_ProtocolStateLock
Thrown when the protocol is in a state that prevents the requested action.


```solidity
error Andromeda_ProtocolStateLock(ProtocolState currentState);
```

## Structs
### HangarManifest
Structural manifest for an anchored hangar module.


```solidity
struct HangarManifest {
    bytes32 moduleId;
    address hangarAddress;
    uint256 version;
    bool isCompliant;
    bool isActive;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`moduleId`|`bytes32`|Keccak256 hash identifier (e.g., keccak256("GOVERNANCE")).|
|`hangarAddress`|`address`|Contract address of the functional module.|
|`version`|`uint256`|Internal semantic versioning (Major.Minor.Patch).|
|`isCompliant`|`bool`|Regulatory compliance verification status.|
|`isActive`|`bool`|Operational availability status.|

## Enums
### ProtocolState
Operational states of the AOXC ecosystem.

**Notes:**
- state-definition: ACTIVE Normal protocol operations.

- state-definition: EMERGENCY_PAUSE Global circuit breaker triggered.

- state-definition: UPGRADE_MODE Controlled migration for smart contract upgrades.


```solidity
enum ProtocolState {
    ACTIVE,
    EMERGENCY_PAUSE,
    UPGRADE_MODE
}
```

