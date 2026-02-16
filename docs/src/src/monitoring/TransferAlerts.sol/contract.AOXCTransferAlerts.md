# AOXCTransferAlerts
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/monitoring/TransferAlerts.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, UUPSUpgradeable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
AOXCTransferAlerts

**Author:**
AOXC Core Engineering

Suspicious transfer activity monitor with 26-channel forensic telemetry.

Optimized for UUPS Proxy pattern with internal reentrancy control and lint-compliant naming.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### MONITOR_ROLE

```solidity
bytes32 public constant MONITOR_ROLE = keccak256("AOXC_MONITOR_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### totalAlertsLogged

```solidity
uint256 public totalAlertsLogged
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
Storage gap for future upgrades (lint: mixed-case-variable).
Name changed from _gap to _gap to comply with linting rules.


```solidity
uint256[47] private _gap
```


## Functions
### nonReentrant

Modifier logic is wrapped in internal functions to reduce code size (lint: unwrapped-modifier-logic).


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

Initializes the Transfer Alerts module.


```solidity
function initialize(address admin, address _monitoringHub) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|Initial administrator and monitor.|
|`_monitoringHub`|`address`|Address of the AOXC Monitoring Hub.|


### alertTransfer

Reports suspicious transfers to the Monitoring Hub.


```solidity
function alertTransfer(address from, address to, uint256 amount, string calldata reason)
    external
    nonReentrant
    onlyRole(MONITOR_ROLE);
```

### _authorizeUpgrade

Authorizes the upgrade and logs the event for forensic auditing.


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|The address of the new contract logic.|


## Events
### TransferAlert

```solidity
event TransferAlert(
    address indexed from,
    address indexed to,
    uint256 amount,
    string reason,
    uint256 timestamp,
    address reporter
);
```

