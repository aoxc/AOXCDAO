# AOXCIdentityRegistry
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/compliance/IdentityRegistry.sol)

**Inherits:**
[IIdentityRegistry](/src/interfaces/IIdentityRegistry.sol/interface.IIdentityRegistry.md), Initializable, AccessControlUpgradeable, PausableUpgradeable, UUPSUpgradeable

**Title:**
AOXCIdentityRegistry

**Author:**
AOXC Core Engineering

Central identity and verification registry for the AOXC Ecosystem.

Fully implements IIdentityRegistry with 26-channel forensic monitoring support.
This contract acts as the primary source of truth for verified on-chain identities.


## State Variables
### ADMIN_ROLE
Role for system administration and high-level configuration.


```solidity
bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE")
```


### VERIFIER_ROLE
Role for authorized entities (KYC providers, etc.) to verify identities.


```solidity
bytes32 public constant VERIFIER_ROLE = keccak256("AOXC_VERIFIER_ROLE")
```


### UPGRADER_ROLE
Role authorized to execute proxy implementation upgrades.


```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE")
```


### monitoringHub
Reference to the central forensic logging and security monitoring hub.


```solidity
IMonitoringHub public monitoringHub
```


### reputationManager
Reference to the manager handling reputation rewards for verifiers.


```solidity
IReputationManager public reputationManager
```


### _registeredAccounts
Enumerable array containing all registered account addresses.


```solidity
address[] private _registeredAccounts
```


### _identities
Mapping from account address to its unique identity string (e.g., hash of DID).


```solidity
mapping(address => string) private _identities
```


### _registeredIndex
Internal index mapping to allow O(1) removal from the _registeredAccounts array.


```solidity
mapping(address => uint256) private _registeredIndex
```


### _gap
Storage gap for future upgradeability expansion.


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

Initializes the Identity Registry with administrative and dependency addresses.


```solidity
function initialize(address admin, address _monitoringHub, address _reputationManager)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|The address to be granted all initial roles.|
|`_monitoringHub`|`address`|The address of the pre-deployed MonitoringHub.|
|`_reputationManager`|`address`|The address of the pre-deployed ReputationManager.|


### register

Registers a new user identity in the system.

Only callable by accounts with VERIFIER_ROLE.


```solidity
function register(address account, string calldata id)
    external
    override
    onlyRole(VERIFIER_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The wallet address to register.|
|`id`|`string`|The unique identity string/hash.|


### deregister

Removes a user identity from the system.

Uses the swap-and-pop pattern to maintain array continuity.


```solidity
function deregister(address account) external override onlyRole(VERIFIER_ROLE) whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The wallet address to deregister.|


### getRegisteredCount

Returns the total number of registered users.


```solidity
function getRegisteredCount() external view override returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 Total count.|


### isRegistered

Checks if an address has a registered identity.


```solidity
function isRegistered(address account) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if registered.|


### getIdentity

Retrieves the identity identifier for a specific address.


```solidity
function getIdentity(address account) external view override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to query.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|string The identity string.|


### getRegisteredAccounts

Returns a list of all registered account addresses.


```solidity
function getRegisteredAccounts() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|address[] Memory array of addresses.|


### batchRegister

Registers multiple identities in a single batch transaction.


```solidity
function batchRegister(address[] calldata accounts, string[] calldata ids)
    external
    onlyRole(VERIFIER_ROLE)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`accounts`|`address[]`|Array of addresses.|
|`ids`|`string[]`|Array of corresponding identity strings.|


### _register

Internal helper to process identity registration storage.


```solidity
function _register(address account, string memory id) internal;
```

### _rewardVerifier

Internal helper to trigger reputation rewards for verifiers.


```solidity
function _rewardVerifier(address verifier, bytes32 actionKey) internal;
```

### _logToHub

High-fidelity 26-channel forensic logging.
Security: msg.sender is used as origin to comply with Solhint standards.


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory action,
    string memory details
) internal;
```

### _authorizeUpgrade

Internal authorization for UUPS contract upgrades.


```solidity
function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE);
```

## Events
### IdentityRegistered
Emitted when a new identity is successfully verified and registered.


```solidity
event IdentityRegistered(address indexed account, string id, address indexed verifier);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address of the verified user.|
|`id`|`string`|The unique identity identifier string.|
|`verifier`|`address`|The address of the entity that performed the verification.|

### IdentityRemoved
Emitted when an identity is removed from the registry.


```solidity
event IdentityRemoved(address indexed account, address indexed verifier);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address of the user being deregistered.|
|`verifier`|`address`|The address of the entity that performed the removal.|

### IdentityUpdated
Emitted when an existing identity's metadata is updated.


```solidity
event IdentityUpdated(
    address indexed account, string oldId, string newId, address indexed verifier
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address of the user.|
|`oldId`|`string`|The previous identity identifier.|
|`newId`|`string`|The new identity identifier.|
|`verifier`|`address`|The address of the entity that performed the update.|

