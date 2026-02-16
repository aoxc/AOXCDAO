# AOXCComplianceEvents
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/monitoring/ComplianceEvents.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, ReentrancyGuard

**Title:**
AOXCComplianceEvents

**Author:**
AOXC Core Engineering

Event emitter and logging relay for compliance-related actions.

Re-engineered for Akdeniz V2 Forensic Logging (26-channel) standard.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### COMPLIANCE_ROLE

```solidity
bytes32 public constant COMPLIANCE_ROLE = keccak256("AOXC_COMPLIANCE_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### _gap

```solidity
uint256[47] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the compliance event module.


```solidity
function initialize(address admin, address _monitoringHub) external initializer;
```

### emitBlacklist

Logs and emits a blacklist event.


```solidity
function emitBlacklist(address account, string calldata reason)
    external
    nonReentrant
    onlyRole(COMPLIANCE_ROLE);
```

### emitUnblacklist

Logs and emits a restoration event.


```solidity
function emitUnblacklist(address account) external nonReentrant onlyRole(COMPLIANCE_ROLE);
```

### _logToHub

Internal telemetry helper fixed for the Akdeniz V2 Forensic standard.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details,
    address related
) internal;
```

## Events
### Blacklisted

```solidity
event Blacklisted(address indexed account, string reason, uint256 timestamp, address reporter);
```

### Unblacklisted

```solidity
event Unblacklisted(address indexed account, uint256 timestamp, address reporter);
```

## Errors
### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

