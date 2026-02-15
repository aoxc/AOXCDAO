# AOXC
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/core/AOXC.sol)

**Inherits:**
Initializable, ERC20Upgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, PausableUpgradeable, ReentrancyGuard


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### MINT_ROLE

```solidity
bytes32 public constant MINT_ROLE = keccak256("AOXC_MINT_ROLE")
```


### BURN_ROLE

```solidity
bytes32 public constant BURN_ROLE = keccak256("AOXC_BURN_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### supplyCap

```solidity
uint256 public supplyCap
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


```solidity
function initialize(
    string memory name_,
    string memory symbol_,
    address admin,
    address policyEngine,
    address authorizer,
    IMonitoringHub _monitoringHub,
    uint256 _supplyCap
) external initializer;
```

### mint


```solidity
function mint(address to, uint256 amount)
    external
    onlyRole(MINT_ROLE)
    whenNotPaused
    nonReentrant;
```

### burn


```solidity
function burn(address from, uint256 amount) external whenNotPaused nonReentrant;
```

### toggleEmergencyHalt


```solidity
function toggleEmergencyHalt(bool status) external onlyRole(ADMIN_ROLE);
```

### _update


```solidity
function _update(address from, address to, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImpl) internal override onlyRole(UPGRADER_ROLE);
```

### nonces


```solidity
function nonces(address owner)
    public
    view
    override(ERC20PermitUpgradeable, NoncesUpgradeable)
    returns (uint256);
```

### clock


```solidity
function clock() public view override returns (uint48);
```

### CLOCK_MODE


```solidity
function CLOCK_MODE() public pure override returns (string memory);
```

### _internalMint


```solidity
function _internalMint(address to, uint256 amount) internal;
```

### _internalBurn


```solidity
function _internalBurn(address from, uint256 amount) internal;
```

### _logToHub


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory category,
    string memory details
) internal;
```

## Errors
### AOXC__PolicyViolation

```solidity
error AOXC__PolicyViolation();
```

### AOXC__UpgradeNotAuthorized

```solidity
error AOXC__UpgradeNotAuthorized();
```

### AOXC__EmergencyHaltActive

```solidity
error AOXC__EmergencyHaltActive();
```

### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

### AOXC__SupplyCapExceeded

```solidity
error AOXC__SupplyCapExceeded(uint256 requested, uint256 cap);
```

### AOXC__InvalidSupplyCap

```solidity
error AOXC__InvalidSupplyCap();
```

