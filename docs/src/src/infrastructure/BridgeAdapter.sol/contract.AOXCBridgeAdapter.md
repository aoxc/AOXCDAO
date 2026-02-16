# AOXCBridgeAdapter
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/infrastructure/BridgeAdapter.sol)

**Inherits:**
[IBridgeAdapter](/src/interfaces/IBridgeAdapter.sol/interface.IBridgeAdapter.md), Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard, [AOXCBaseReporter](/src/monitoring/AOXCBaseReporter.sol/abstract.AOXCBaseReporter.md)

**Title:**
AOXCBridgeAdapter

**Author:**
AOXC Core Engineering

Enterprise-grade cross-chain liquidity gateway with 26-channel forensic telemetry.

Optimized for Akdeniz V2. Features: Yul-based hashing, wrapped modifiers, and zero-lint compliance.


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### UPGRADER_ROLE

```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### identityRegistry

```solidity
IIdentityRegistry public identityRegistry
```


### timelock

```solidity
address public timelock
```


### requests

```solidity
mapping(bytes32 => BridgeRequest) public requests
```


### _finalizedTransactions

```solidity
mapping(bytes32 => bool) private _finalizedTransactions
```


### _gap
Gap reserved for future state extensions (total 50 slots).
identityRegistry (1), timelock (1), requests (1), _finalizedTransactions (1).
Reporter base uses slots from its own scope.


```solidity
uint256[46] private _gap
```


## Functions
### onlyTimelock


```solidity
modifier onlyTimelock() ;
```

### _validateTimelock

Internalizing logic to satisfy forge-lint [unwrapped-modifier-logic]


```solidity
function _validateTimelock() internal view;
```

### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor() ;
```

### initialize

Initializes the sentinel bridge with identity and forensic links.


```solidity
function initialize(address admin, address _monitoringHub, address _identity, address _timelock)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|System overseer.|
|`_monitoringHub`|`address`|Forensic data aggregator.|
|`_identity`|`address`|Compliance verification registry.|
|`_timelock`|`address`|Multi-sig or governance execution delay address.|


### bridgeAsset

Initiates a cross-chain asset transfer.

Implementation uses Yul-optimized hashing to circumvent forge-lint [asm-keccak256].


```solidity
function bridgeAsset(uint256 targetChainId, address token, uint256 amount, address recipient)
    external
    payable
    override
    nonReentrant
    whenNotPaused
    returns (bytes32 txHash);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`targetChainId`|`uint256`|The destination chain identifier.|
|`token`|`address`|The address of the token to bridge (use address(0) for native gas tokens).|
|`amount`|`uint256`|The quantity of assets to transfer.|
|`recipient`|`address`|The destination address on the target chain.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`txHash`|`bytes32`|The unique transaction identifier for tracking.|


### finalizeBridge

Confirms the cross-chain settlement after external validation.


```solidity
function finalizeBridge(address, uint256, address, uint256, bytes32 txHash)
    external
    onlyTimelock
    nonReentrant;
```

### cancelAndRefund

Rollback mechanism for rejected or timed-out bridge attempts.


```solidity
function cancelAndRefund(bytes32 txHash, address token, uint256 amount)
    external
    onlyTimelock
    nonReentrant;
```

### getAdapterName


```solidity
function getAdapterName() external pure override returns (string memory);
```

### getSupportedChains


```solidity
function getSupportedChains() external pure override returns (uint256[] memory);
```

### isTransactionFinalized


```solidity
function isTransactionFinalized(bytes32 txHash) external view override returns (bool);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE);
```

## Errors
### AOXC__ComplianceViolation

```solidity
error AOXC__ComplianceViolation();
```

### AOXC__AlreadyFinalized

```solidity
error AOXC__AlreadyFinalized();
```

### AOXC__Unauthorized

```solidity
error AOXC__Unauthorized();
```

### AOXC__RequestNotFound

```solidity
error AOXC__RequestNotFound();
```

### AOXC__EthAmountMismatch

```solidity
error AOXC__EthAmountMismatch();
```

### AOXC__EthRefundFailed

```solidity
error AOXC__EthRefundFailed();
```

### AOXC__ZeroAddressDetected

```solidity
error AOXC__ZeroAddressDetected();
```

## Structs
### BridgeRequest

```solidity
struct BridgeRequest {
    address owner;
    address token;
    uint256 amount;
    address recipient;
    uint256 targetChainId;
    bool finalized;
}
```

