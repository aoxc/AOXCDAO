# AOXP
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/core/token/AOXP.sol)

**Inherits:**
Initializable, ERC1155Upgradeable, AccessControlUpgradeable, UUPSUpgradeable

**Title:**
AOXP (AOXC Experience & Power)

**Author:**
AOXC Core Engineering

Soulbound (SBT) reputation token for the Akdeniz V2 Ecosystem.

High-security ERC1155 implementation for non-transferable governance power.
Fully compliant with OpenZeppelin 5.x UUPS patterns.


## State Variables
### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("AOXC_MINTER_ROLE")
```


### REVOKER_ROLE

```solidity
bytes32 public constant REVOKER_ROLE = keccak256("AOXC_REVOKER_ROLE")
```


### AOXP_ID

```solidity
uint256 public constant AOXP_ID = 0
```


### NAME

```solidity
string public constant NAME = "AOXC Experience Points"
```


### SYMBOL

```solidity
string public constant SYMBOL = "AOXP"
```


### monitoringHub

```solidity
IMonitoringHub public monitoringHub
```


### _gap
Gap for future storage variables to prevent collision in upgradeable contracts.


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

Initializes the AOXP contract with administrative and monitoring parameters.

__UUPSUpgradeable_init() is omitted as it does not exist in OpenZeppelin 5.x.


```solidity
function initialize(address admin, address _monitoringHub) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|Primary administrator address.|
|`_monitoringHub`|`address`|Address of the ecosystem's 26-channel Monitoring Hub.|


### syncPower

Synchronizes a user's total AOXP Power to a specific value.

Used by ReputationManager to match lock weights exactly.


```solidity
function syncPower(address user, uint256 newTotalPower) external onlyRole(MINTER_ROLE);
```

### awardXp

Individually awards XP for specific ecosystem achievements.


```solidity
function awardXp(address to, uint256 amount, string calldata reason)
    external
    onlyRole(MINTER_ROLE);
```

### revokeXp

Revokes XP due to lock expiration or security sanctions.


```solidity
function revokeXp(address from, uint256 amount, string calldata reason)
    external
    onlyRole(REVOKER_ROLE);
```

### _update

Hook that ensures tokens are non-transferable (Soulbound).
Only minting (from == 0) and burning (to == 0) are permitted.


```solidity
function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
    internal
    override;
```

### getPower


```solidity
function getPower(address user) external view returns (uint256);
```

### _logToHub


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details,
    uint8 riskScore
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
    override(ERC1155Upgradeable, AccessControlUpgradeable)
    returns (bool);
```

## Events
### AOXPAwarded

```solidity
event AOXPAwarded(address indexed to, uint256 amount, string reason);
```

### AOXPRevoked

```solidity
event AOXPRevoked(address indexed from, uint256 amount, string reason);
```

### PowerSynchronized

```solidity
event PowerSynchronized(address indexed user, uint256 newPower);
```

