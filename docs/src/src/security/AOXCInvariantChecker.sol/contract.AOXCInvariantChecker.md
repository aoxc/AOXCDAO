# AOXCInvariantChecker
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/security/AOXCInvariantChecker.sol)

**Title:**
AOXCInvariantChecker

**Author:**
AOXC Core Engineering

Enforces the mathematical "Red Lines" of the protocol.

If an invariant is violated, it triggers the AccessCoordinator to pause the system.
Compliant with strict Forge linting rules and 2026 enterprise security standards.


## State Variables
### AOXP
The AOXP Token interface for supply tracking.


```solidity
IAOXP public immutable AOXP
```


### LEDGER
The Ledger interface for collateral valuation.


```solidity
IAssetBackingLedger public immutable LEDGER
```


### ORACLE
The Oracle Adapter for price verification.


```solidity
PriceOracleAdapter public immutable ORACLE
```


### COORDINATOR
The central Access Coordinator for emergency control.


```solidity
AOXCAccessCoordinator public immutable COORDINATOR
```


## Functions
### constructor


```solidity
constructor(address _aoxp, address _ledger, address _oracle, address _coordinator) ;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_aoxp`|`address`|Address of the AOXP contract.|
|`_ledger`|`address`|Address of the Asset Backing Ledger.|
|`_oracle`|`address`|Address of the Price Oracle Adapter.|
|`_coordinator`|`address`|Address of the Access Coordinator.|


### checkSolvency

Validates that the total supply is always backed by collateral value.

Pro Ultimate: Ensures 1:1 backing check using oracle-normalized data.


```solidity
function checkSolvency() external;
```

### checkSupplyIntegrity

Ensures that minting events match the ledger's record.


```solidity
function checkSupplyIntegrity(uint256 expectedSupply) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`expectedSupply`|`uint256`|The supply value that should be reflected in the token contract.|


### _handleViolation

Automatically triggers emergency pause via Coordinator if a mathematical invariant is broken.


```solidity
function _handleViolation(string memory reason) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reason`|`string`|The descriptive reason for the violation.|


## Errors
### AOXC__Invariant_SolvencyViolation

```solidity
error AOXC__Invariant_SolvencyViolation();
```

### AOXC__Invariant_SupplyMismatch

```solidity
error AOXC__Invariant_SupplyMismatch();
```

