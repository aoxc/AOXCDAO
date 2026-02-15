# AOXCGovernor
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/control/governance/AOXCGovernor.sol)

**Inherits:**
Initializable, GovernorUpgradeable, GovernorCountingSimpleUpgradeable, GovernorVotesUpgradeable, GovernorTimelockControlUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
AOXCGovernor Hardened Framework

**Author:**
AOXCDAO Institutional Engineering

Central Governance Engine with Multi-Layered Security.

Optimized for OpenZeppelin 5.5.x. Features:
- Anti-Initialization Hijacking
- Strict Zero-Address Validation
- Emergency State Awareness
- Access-Controlled Infrastructure Migration
🎓 LEVEL: Pro Ultimate Academic (Security Hardened)


## State Variables
### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")
```


### BPS_DENOMINATOR

```solidity
uint256 private constant BPS_DENOMINATOR = 10_000
```


### reputationManager

```solidity
IReputationManager public reputationManager
```


### andromedaCore

```solidity
IAOXCAndromedaCore public andromedaCore
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Hardened initialization process.

Ensures all core components are valid upon deployment.


```solidity
function initialize(
    IVotes _token,
    TimelockControllerUpgradeable _timelock,
    address _admin,
    address _repManager,
    address _andromeda
) public initializer;
```

### _getVotes


```solidity
function _getVotes(address account, uint256 timepoint, bytes memory params)
    internal
    view
    override(GovernorUpgradeable, GovernorVotesUpgradeable)
    returns (uint256);
```

### votingDelay


```solidity
function votingDelay() public pure override returns (uint256);
```

### votingPeriod


```solidity
function votingPeriod() public pure override returns (uint256);
```

### proposalThreshold


```solidity
function proposalThreshold() public pure override returns (uint256);
```

### quorum


```solidity
function quorum(uint256 timepoint) public view override returns (uint256);
```

### updateInfrastructure


```solidity
function updateInfrastructure(address _repManager, address _andromeda)
    external
    onlyRole(DEFAULT_ADMIN_ROLE);
```

### state


```solidity
function state(uint256 pId)
    public
    view
    override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    returns (ProposalState);
```

### proposalNeedsQueuing


```solidity
function proposalNeedsQueuing(uint256 pId)
    public
    view
    override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    returns (bool);
```

### _executor


```solidity
function _executor()
    internal
    view
    override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    returns (address);
```

### _executeOperations


```solidity
function _executeOperations(
    uint256 pId,
    address[] memory t,
    uint256[] memory v,
    bytes[] memory c,
    bytes32 d
) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) nonReentrant;
```

### _queueOperations


```solidity
function _queueOperations(
    uint256 pId,
    address[] memory t,
    uint256[] memory v,
    bytes[] memory c,
    bytes32 d
) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint48);
```

### _cancel


```solidity
function _cancel(address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 d)
    internal
    override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    returns (uint256);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 iId)
    public
    view
    override(GovernorUpgradeable, AccessControlUpgradeable)
    returns (bool);
```

### _authorizeUpgrade

Mutability restricted to 'view' to suppress Solc 0.8.33 warnings.

Critical Security Gate for Logic Upgrades.


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    view
    override
    onlyRole(UPGRADER_ROLE);
```

## Events
### InfrastructureUpdated

```solidity
event InfrastructureUpdated(address indexed reputationManager, address indexed andromedaCore);
```

## Errors
### AOXC_ZeroAddressForbidden

```solidity
error AOXC_ZeroAddressForbidden();
```

### AOXC_ProtocolEmergencyLocked

```solidity
error AOXC_ProtocolEmergencyLocked();
```

### AOXC_InconsistentConfiguration

```solidity
error AOXC_InconsistentConfiguration();
```

