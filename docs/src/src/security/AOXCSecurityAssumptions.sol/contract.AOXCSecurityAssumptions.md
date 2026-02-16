# AOXCSecurityAssumptions
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/security/AOXCSecurityAssumptions.sol)

**Inherits:**
Initializable, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md), OwnableUpgradeable

**Title:**
AOXCSecurityAssumptions

Inheritance conflict resolved by overriding the root ContextUpgradeable functions.


## State Variables
### maxWithdrawalPercent

```solidity
uint256 public maxWithdrawalPercent
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
function initialize(address admin, address _monitoringHub) external initializer;
```

### _msgSender


```solidity
function _msgSender() internal view override(ContextUpgradeable) returns (address);
```

### _msgData


```solidity
function _msgData() internal view override(ContextUpgradeable) returns (bytes calldata);
```

### _contextSuffixLength


```solidity
function _contextSuffixLength() internal view override(ContextUpgradeable) returns (uint256);
```

### validateAssumption

Güvenlik varsayımı doğrulaması.


```solidity
function validateAssumption(uint256 amount, uint256 totalPool) external;
```

