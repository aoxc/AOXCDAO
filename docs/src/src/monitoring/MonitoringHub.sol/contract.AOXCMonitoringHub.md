# AOXCMonitoringHub
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/monitoring/MonitoringHub.sol)

**Inherits:**
[IMonitoringHub](/src/security/sentinel/QUASAR_SENTRY.sol/interface.IMonitoringHub.md), Initializable, AccessControlUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
AOXCMonitoringHub

**Author:**
AOXC Core Engineering

Centralized hyper-forensic hub for the AOXC ecosystem.

V5 Compliance: Standard ReentrancyGuard is used as it is stateless in V5.

Implements the 26-channel data schema and integrated risk filtering.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### REPORTER_ROLE

```solidity
bytes32 public constant REPORTER_ROLE = keccak256("AOXC_REPORTER_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### _forensicRecords

```solidity
mapping(uint256 => ForensicLog) private _forensicRecords
```


### _globalSequenceId

```solidity
uint256 private _globalSequenceId
```


### _active

```solidity
bool private _active
```


### _lastLogTimestamp

```solidity
mapping(address => uint256) private _lastLogTimestamp
```


### LOG_COOLDOWN

```solidity
uint256 public constant LOG_COOLDOWN = 1 seconds
```


### _gap

```solidity
uint256[48] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the 26-channel Monitoring Hub.


```solidity
function initialize(address admin) external initializer;
```

### logForensic

Seals a 26-channel forensic log onto the blockchain.


```solidity
function logForensic(ForensicLog calldata log)
    external
    override
    onlyRole(REPORTER_ROLE)
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`log`|`ForensicLog`|The full forensic data package.|


### setStatus


```solidity
function setStatus(bool active) external onlyRole(ADMIN_ROLE);
```

### getRecord


```solidity
function getRecord(uint256 index) external view override returns (ForensicLog memory);
```

### getRecordCount


```solidity
function getRecordCount() external view override returns (uint256);
```

### isMonitoringActive


```solidity
function isMonitoringActive() external view override returns (bool);
```

### _authorizeUpgrade

Required by UUPSUpgradeable


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### MonitoringStatusChanged

```solidity
event MonitoringStatusChanged(bool active);
```

