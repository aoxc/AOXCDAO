# AOXCComplianceRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/compliance/ComplianceRegistry.sol)

**Inherits:**
[IComplianceRegistry](/src/interfaces/IComplianceRegistry.sol/interface.IComplianceRegistry.md), Initializable, AccessControlUpgradeable, UUPSUpgradeable, PausableUpgradeable

**Title:**
AOXCComplianceRegistry

**Author:**
AOXC Core Engineering

Centralized compliance and blacklist management for the AOXC ecosystem.

Fully implements IComplianceRegistry with 26-channel forensic monitoring.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### COMPLIANCE_OFFICER_ROLE

```solidity
bytes32 public constant COMPLIANCE_OFFICER_ROLE = keccak256("AOXC_COMPLIANCE_OFFICER_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### reputationManager

```solidity
IReputationManager public reputationManager
```


### _blacklistedAccounts

```solidity
address[] private _blacklistedAccounts
```


### _blacklisted

```solidity
mapping(address => bool) private _blacklisted
```


### _blacklistReasons

```solidity
mapping(address => string) private _blacklistReasons
```


### _blacklistIndex

```solidity
mapping(address => uint256) private _blacklistIndex
```


### _gap

```solidity
uint256[43] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the Compliance Registry contract.


```solidity
function initialize(address admin, address _monitoringHub, address _reputationManager)
    external
    initializer;
```

### addToBlacklist


```solidity
function addToBlacklist(address account, string calldata reason)
    external
    override
    onlyRole(COMPLIANCE_OFFICER_ROLE)
    whenNotPaused;
```

### removeFromBlacklist


```solidity
function removeFromBlacklist(address account)
    external
    override
    onlyRole(COMPLIANCE_OFFICER_ROLE)
    whenNotPaused;
```

### getBlacklistCount


```solidity
function getBlacklistCount() external view override returns (uint256);
```

### isBlacklisted


```solidity
function isBlacklisted(address account) external view override returns (bool);
```

### getBlacklistReason


```solidity
function getBlacklistReason(address account) external view override returns (string memory);
```

### batchAddToBlacklist


```solidity
function batchAddToBlacklist(address[] calldata accounts, string[] calldata reasons)
    external
    onlyRole(COMPLIANCE_OFFICER_ROLE)
    whenNotPaused;
```

### _addToBlacklist


```solidity
function _addToBlacklist(address account, string memory reason) internal;
```

### _removeFromBlacklist


```solidity
function _removeFromBlacklist(address account) internal;
```

### _rewardOfficer


```solidity
function _rewardOfficer(address officer, bytes32 actionKey) internal;
```

### _logToHub

Implementation of high-fidelity 26-channel forensic logging.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### getBlacklistedAccounts


```solidity
function getBlacklistedAccounts() external view returns (address[] memory);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### Blacklisted

```solidity
event Blacklisted(address indexed account, string reason, address indexed officer);
```

### Unblacklisted

```solidity
event Unblacklisted(address indexed account, address indexed officer);
```

