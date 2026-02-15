# ANDROMEDA_CORE
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/core/ANDROMEDA_CORE.sol)

**Inherits:**
[IAOXCAndromedaCore](/src/interfaces/IAOXCAndromedaCore.sol/interface.IAOXCAndromedaCore.md), Initializable, AccessControlUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
ANDROMEDA_CORE Institutional Guard

**Author:**
AOXCDAO Institutional Engineering

Central Sector and Policy Layer for the AOXC v2 Prime Ecosystem.

Optimized for OpenZeppelin 5.5.x.
🎓 LEVEL: Pro Ultimate Academic (Full Functional Security)


## State Variables
### VETO_ROLE

```solidity
bytes32 public constant VETO_ROLE = keccak256("VETO_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")
```


### GOVERNANCE_ROLE

```solidity
bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE")
```


### MAX_KINETIC_MULTIPLIER

```solidity
uint256 public constant MAX_KINETIC_MULTIPLIER = 600
```


### BASE_SCALAR

```solidity
uint256 public constant BASE_SCALAR = 100
```


### _protocolState

```solidity
ProtocolState private _protocolState
```


### rigorousMonetaryPolicyActive

```solidity
bool public rigorousMonetaryPolicyActive
```


### globalEfficiencyMultiplier

```solidity
uint256 public globalEfficiencyMultiplier
```


### _hangars

```solidity
mapping(bytes32 => HangarManifest) private _hangars
```


### sectorRegistry

```solidity
mapping(uint256 => address) public sectorRegistry
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initializeAndromeda

Institutional Initialization


```solidity
function initializeAndromeda(address _admin) public initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_admin`|`address`|Primary administrator.|


### registerSector

Registers a sector-specific logic contract.


```solidity
function registerSector(uint256 _sectorId, address _sectorAddress)
    external
    onlyRole(GOVERNANCE_ROLE);
```

### removeSector

Removes a sector from the registry.


```solidity
function removeSector(uint256 _sectorId) external onlyRole(GOVERNANCE_ROLE);
```

### getHangarManifest


```solidity
function getHangarManifest(bytes32 moduleId) external view returns (HangarManifest memory);
```

### isAuthorizedModule


```solidity
function isAuthorizedModule(address caller, bytes32 targetModule) external view returns (bool);
```

### getProtocolState


```solidity
function getProtocolState() external view returns (ProtocolState);
```

### transitionProtocolState


```solidity
function transitionProtocolState(ProtocolState newState) external onlyRole(VETO_ROLE);
```

### anchorHangar


```solidity
function anchorHangar(bytes32 moduleId, address hangarAddress, uint256 version)
    external
    onlyRole(GOVERNANCE_ROLE);
```

### setHangarStatus


```solidity
function setHangarStatus(bytes32 moduleId, bool status) external onlyRole(GOVERNANCE_ROLE);
```

### calibrateGlobalKinetic


```solidity
function calibrateGlobalKinetic(uint256 _newMultiplier) external onlyRole(GOVERNANCE_ROLE);
```

### toggleMonetaryGuard


```solidity
function toggleMonetaryGuard(bool _active) external onlyRole(VETO_ROLE);
```

### calculateKineticVotes


```solidity
function calculateKineticVotes(uint256 _baseVotes) external view returns (uint256);
```

### _authorizeUpgrade

Function mutability restricted to 'view' to satisfy Solc 0.8.33 linting.

Restricts proxy upgrades to the UPGRADER_ROLE.


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    view
    override
    onlyRole(UPGRADER_ROLE);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    override(AccessControlUpgradeable)
    returns (bool);
```

## Events
### SectorLinked

```solidity
event SectorLinked(uint256 indexed sectorId, address indexed sectorAddress);
```

### SectorRemoved

```solidity
event SectorRemoved(uint256 indexed sectorId);
```

### StabilityPolicyShifted

```solidity
event StabilityPolicyShifted(bool indexed isStrict, uint256 timestamp);
```

### KineticCalibrated

```solidity
event KineticCalibrated(uint256 newMultiplier);
```

## Errors
### InvalidSectorRange

```solidity
error InvalidSectorRange();
```

### SectorNotRegistered

```solidity
error SectorNotRegistered();
```

### MultiplierExceedsLimit

```solidity
error MultiplierExceedsLimit();
```

