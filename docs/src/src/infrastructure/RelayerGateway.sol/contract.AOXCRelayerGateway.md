# AOXCRelayerGateway
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/infrastructure/RelayerGateway.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuard

**Title:**
AOXCRelayerGateway

**Author:**
AOXC Core Engineering

Multi-signature gateway for relayers with Akdeniz V2 Forensic standard.

Optimized with inline assembly hashing and wrapped modifier logic for lint compliance.


## State Variables
### RELAYER_ROLE

```solidity
bytes32 public constant RELAYER_ROLE = keccak256("AOXC_RELAYER_ROLE")
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


### timelock

```solidity
address public timelock
```


### requiredConfirmations

```solidity
uint256 public requiredConfirmations
```


### transactions

```solidity
mapping(bytes32 => MultiSigTx) public transactions
```


### isConfirmed

```solidity
mapping(bytes32 => mapping(address => bool)) public isConfirmed
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
    address admin,
    address _monitoringHub,
    address _timelock,
    uint256 _required,
    address _reputationManager
) external initializer;
```

### relayCall

Relays a call after consensus is reached.

Uses assembly for gas-efficient hashing to satisfy forge-lint [asm-keccak256].


```solidity
function relayCall(address target, bytes calldata data, uint256 txNonce)
    external
    onlyRole(RELAYER_ROLE)
    nonReentrant
    whenNotPaused;
```

### _executeTransaction


```solidity
function _executeTransaction(bytes32 txHash) internal;
```

### onlyTimelock

Wrapped modifier logic to reduce bytecode and satisfy forge-lint.


```solidity
modifier onlyTimelock() ;
```

### _checkTimelock


```solidity
function _checkTimelock() internal view;
```

### setThreshold


```solidity
function setThreshold(uint256 _new) external onlyTimelock;
```

### _logToHub

26-Channel Forensic Logging Implementation.


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
### CallRelayed

```solidity
event CallRelayed(
    address indexed relayer, address indexed target, bool success, uint256 timestamp
);
```

### TransactionConfirmed

```solidity
event TransactionConfirmed(
    bytes32 indexed txHash, address indexed relayer, uint256 confirmations
);
```

### ThresholdUpdated

```solidity
event ThresholdUpdated(uint256 newThreshold);
```

## Errors
### AOXC__ThresholdZero

```solidity
error AOXC__ThresholdZero();
```

### AOXC__AlreadyExecuted

```solidity
error AOXC__AlreadyExecuted();
```

### AOXC__AlreadyConfirmed

```solidity
error AOXC__AlreadyConfirmed();
```

### AOXC__RelayExecutionFailed

```solidity
error AOXC__RelayExecutionFailed();
```

### AOXC__Unauthorized

```solidity
error AOXC__Unauthorized();
```

### AOXC__ZeroAddress

```solidity
error AOXC__ZeroAddress();
```

## Structs
### MultiSigTx

```solidity
struct MultiSigTx {
    address target;
    bytes data;
    uint256 confirmations;
    bool executed;
    uint256 nonce;
}
```

