# AOXCHonorSBT
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/core/token/AOXCHonorSBT.sol)

**Inherits:**
Initializable, ERC721Upgradeable, AccessControlUpgradeable, UUPSUpgradeable

**Title:**
AOXCHonorSBT

**Author:**
AOXC Core Engineering

Soulbound Reputation NFT (SBT) for the AOXC Meritocracy.

Levels: 1: Member, 2: Contributor, 3: Expert, 4: Legend.
High-fidelity forensic logging integrated for merit changes.


## State Variables
### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("NFT_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### _nextTokenId

```solidity
uint256 private _nextTokenId
```


### tokenLevel

```solidity
mapping(uint256 => uint8) public tokenLevel
```


### hasHonor

```solidity
mapping(address => bool) public hasHonor
```


### _userTokenId

```solidity
mapping(address => uint256) private _userTokenId
```


### _gap

```solidity
uint256[46] private _gap
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the Honor SBT contract.


```solidity
function initialize(address admin, IMonitoringHub _monitoringHub) external initializer;
```

### mintHonor

Mints a unique Soulbound Honor NFT to a user.


```solidity
function mintHonor(address to, uint8 level) external onlyRole(MINTER_ROLE);
```

### upgradeLevel

Upgrades the merit level of an existing Honor NFT.


```solidity
function upgradeLevel(uint256 tokenId, uint8 newLevel) external onlyRole(MINTER_ROLE);
```

### _update

Modern OpenZeppelin v5.x _update hook.
Reverts if from != 0 and to != 0 (Transfer between wallets).


```solidity
function _update(address to, uint256 tokenId, address auth)
    internal
    override
    returns (address);
```

### getLevel


```solidity
function getLevel(address user) external view returns (uint8);
```

### _logToHub


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

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721Upgradeable, AccessControlUpgradeable)
    returns (bool);
```

## Events
### HonorMinted

```solidity
event HonorMinted(address indexed to, uint256 indexed tokenId, uint8 level);
```

### LevelUpgraded

```solidity
event LevelUpgraded(uint256 indexed tokenId, uint8 oldLevel, uint8 newLevel);
```

