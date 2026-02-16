# AOXCIdentityRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/compliance/IdentityRegistry.sol)

**Inherits:**
[IIdentityRegistry](/src/interfaces/IIdentityRegistry.sol/interface.IIdentityRegistry.md), Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable

**Title:**
AOXCIdentityRegistry

**Author:**
AOXC Core Engineering

Central identity and verification registry for the AOXC Ecosystem.

Fully implements IIdentityRegistry with 26-channel forensic monitoring support.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### VERIFIER_ROLE

```solidity
bytes32 public constant VERIFIER_ROLE = keccak256("AOXC_VERIFIER_ROLE")
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


### _registeredAccounts

```solidity
address[] private _registeredAccounts
```


### _identities

```solidity
mapping(address => string) private _identities
```


### _registeredIndex

```solidity
mapping(address => uint256) private _registeredIndex
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

Initializes the Identity Registry.


```solidity
function initialize(address admin, address _monitoringHub, address _reputationManager)
    external
    initializer;
```

### register


```solidity
function register(address account, string calldata id)
    external
    override
    onlyRole(VERIFIER_ROLE)
    whenNotPaused;
```

### deregister


```solidity
function deregister(address account) external override onlyRole(VERIFIER_ROLE) whenNotPaused;
```

### getRegisteredCount


```solidity
function getRegisteredCount() external view override returns (uint256);
```

### isRegistered


```solidity
function isRegistered(address account) external view override returns (bool);
```

### getIdentity


```solidity
function getIdentity(address account) external view override returns (string memory);
```

### getRegisteredAccounts


```solidity
function getRegisteredAccounts() external view returns (address[] memory);
```

### batchRegister


```solidity
function batchRegister(address[] calldata accounts, string[] calldata ids)
    external
    onlyRole(VERIFIER_ROLE)
    whenNotPaused;
```

### _register


```solidity
function _register(address account, string memory id) internal;
```

### _rewardVerifier


```solidity
function _rewardVerifier(address verifier, bytes32 actionKey) internal;
```

### _logToHub

High-fidelity 26-channel forensic logging.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### IdentityRegistered

```solidity
event IdentityRegistered(address indexed account, string id, address indexed verifier);
```

### IdentityRemoved

```solidity
event IdentityRemoved(address indexed account, address indexed verifier);
```

### IdentityUpdated

```solidity
event IdentityUpdated(
    address indexed account, string oldId, string newId, address indexed verifier
);
```

