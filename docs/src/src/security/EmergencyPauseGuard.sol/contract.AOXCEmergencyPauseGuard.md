# AOXCEmergencyPauseGuard
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/security/EmergencyPauseGuard.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, UUPSUpgradeable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
AOXCEmergencyPauseGuard

**Author:**
AOXC Core Engineering

"Iron Fist" Circuit Breaker for the AOXC Ecosystem.

Re-engineered for Akdeniz V2 with wrapped modifiers for lint compliance and gas optimization.
Performance: Optimized bytecode via internal calls in modifiers.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### PAUSER_ROLE

```solidity
bytes32 public constant PAUSER_ROLE = keccak256("AOXC_PAUSER_ROLE")
```


### GUARDIAN_ROLE

```solidity
bytes32 public constant GUARDIAN_ROLE = keccak256("AOXC_GUARDIAN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### paused

```solidity
bool public paused
```


### lastPauseTime

```solidity
uint256 public lastPauseTime
```


### minPauseDuration

```solidity
uint256 public minPauseDuration
```


### GUARDIAN_THRESHOLD

```solidity
uint256 public constant GUARDIAN_THRESHOLD = 3
```


### activeGuardianVotes

```solidity
uint256 public activeGuardianVotes
```


### hasVotedForPause

```solidity
mapping(address => bool) public hasVotedForPause
```


### _status

```solidity
uint256 private _status
```


### _NOT_ENTERED

```solidity
uint256 private constant _NOT_ENTERED = 1
```


### _ENTERED

```solidity
uint256 private constant _ENTERED = 2
```


### _gap
Reserved storage gap for upgradeability protection (50 slots).


```solidity
uint256[43] private _gap
```


## Functions
### nonReentrant

Optimized Reentrancy Guard wrapping to satisfy enterprise lint rules and reduce contract size.


```solidity
modifier nonReentrant() ;
```

### _nonReentrantBefore


```solidity
function _nonReentrantBefore() internal;
```

### _nonReentrantAfter


```solidity
function _nonReentrantAfter() internal;
```

### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the Emergency Pause Guard logic.


```solidity
function initialize(address admin, address _monitoringHub, uint256 _minPauseDuration)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|Initial administrator and pauser.|
|`_monitoringHub`|`address`|Forensic logging hub address.|
|`_minPauseDuration`|`uint256`|Minimum seconds the system must stay paused.|


### pause

Manually pauses the entire protocol in case of an emergency.


```solidity
function pause(string calldata reason) external onlyRole(PAUSER_ROLE) nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reason`|`string`|The forensic justification for the pause.|


### triggerGuardianPause

Guardian consensus mechanism to trigger an emergency pause.

Automatically triggers pause when GUARDIAN_THRESHOLD is met.


```solidity
function triggerGuardianPause() external onlyRole(GUARDIAN_ROLE);
```

### unpause

Resumes protocol operations.

Enforcement of minPauseDuration to prevent premature recovery during active attacks.


```solidity
function unpause() external onlyRole(ADMIN_ROLE) nonReentrant;
```

### isPaused

Returns current pause state.


```solidity
function isPaused() external view returns (bool);
```

### _executePause


```solidity
function _executePause(string memory reason) internal;
```

### _authorizeUpgrade

Restricts implementation upgrades to the UPGRADER_ROLE.


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE);
```

## Events
### Paused

```solidity
event Paused(address indexed account, uint256 timestamp, string reason);
```

### Unpaused

```solidity
event Unpaused(address indexed account, uint256 timestamp);
```

### GuardianVoteCasted

```solidity
event GuardianVoteCasted(address indexed guardian, uint256 totalVotes);
```

### MinPauseDurationUpdated

```solidity
event MinPauseDurationUpdated(uint256 oldDuration, uint256 newDuration);
```

