# AOXCSwap
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/infrastructure/AOXCSwap.sol)

**Inherits:**
ReentrancyGuard, Pausable, AccessControl

**Title:**
AOXCSwap

**Author:**
AOXC Core Engineering

Ultimate swap infrastructure with 26-channel DAO Risk Engine and Forensic Hub.

Fully compliant with forge-lint standards and Akdeniz V2 security protocols.


## State Variables
### SWAP_ADMIN_ROLE

```solidity
bytes32 public constant SWAP_ADMIN_ROLE = keccak256("SWAP_ADMIN_ROLE")
```


### RISK_MANAGER_ROLE

```solidity
bytes32 public constant RISK_MANAGER_ROLE = keccak256("RISK_MANAGER_ROLE")
```


### TREASURY

```solidity
ITreasury public immutable TREASURY
```


### AOXC_TOKEN

```solidity
IERC20 public immutable AOXC_TOKEN
```


### PYTH

```solidity
IPyth public immutable PYTH
```


### MONITORING_HUB

```solidity
IMonitoringHub public immutable MONITORING_HUB
```


### OKB_PRICE_ID

```solidity
bytes32 public constant OKB_PRICE_ID =
    0x39d15024467d16374971485675e2f782c5f94d9b4b0a48b8b091f86c2d499317
```


### highValueThreshold

```solidity
uint256 public highValueThreshold = 1000 ether
```


### MAX_SLIPPAGE_DEVIATION

```solidity
uint256 public constant MAX_SLIPPAGE_DEVIATION = 500
```


### isAutomatedRate

```solidity
bool public isAutomatedRate = true
```


### manualRate

```solidity
uint256 public manualRate
```


## Functions
### constructor


```solidity
constructor(
    address _treasury,
    address _aoxc,
    address _pyth,
    address _monitoringHub,
    address _admin
) ;
```

### swapOkBtoAoxc

Primary Swap Entrypoint.


```solidity
function swapOkBtoAoxc(uint256 minAoxcOut) external payable nonReentrant whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`minAoxcOut`|`uint256`|Minimum amount of AOXC expected (Lint: mixedCase compliant).|


### _fetchValidatedRate


```solidity
function _fetchValidatedRate() internal view returns (uint256 normalized, uint256 raw);
```

### _calculateRiskScore


```solidity
function _calculateRiskScore(uint256 _in, uint256 _out, uint256 _min)
    internal
    view
    returns (uint8);
```

### _reportToHub


```solidity
function _reportToHub(
    IMonitoringHub.Severity severity,
    string memory category,
    string memory details,
    uint8 riskScore
) internal;
```

### updateRiskThreshold


```solidity
function updateRiskThreshold(uint256 _newThreshold) external onlyRole(RISK_MANAGER_ROLE);
```

### emergencyPause


```solidity
function emergencyPause() external onlyRole(SWAP_ADMIN_ROLE);
```

### _uint2str

Converts uint to string with lint-safe typecasting.


```solidity
function _uint2str(uint256 _i) internal pure returns (string memory);
```

## Errors
### Swap__ZeroValue

```solidity
error Swap__ZeroValue();
```

### Swap__SlippageViolation

```solidity
error Swap__SlippageViolation(uint256 received, uint256 expected);
```

### Swap__OracleFailure

```solidity
error Swap__OracleFailure();
```

### Swap__TreasuryFailure

```solidity
error Swap__TreasuryFailure();
```

### Swap__UnauthorizedAction

```solidity
error Swap__UnauthorizedAction();
```

