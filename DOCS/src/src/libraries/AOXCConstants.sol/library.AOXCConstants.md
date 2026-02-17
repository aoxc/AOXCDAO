# AOXCConstants
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/libraries/AOXCConstants.sol)

**Title:**
AOXCConstants

**Author:**
AOXC Core Engineering

Centralized library for system-wide constants, roles, and financial parameters.

Optimized for Solidity 0.8.33. All constants are evaluated at compile-time to save gas.


## State Variables
### ADMIN_ROLE
Root access for governance, DAO, and Multi-sig controllers.


```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE")
```


### SENTINEL_ROLE
Role for emergency response, circuit breakers, and automated sentinels.


```solidity
bytes32 public constant SENTINEL_ROLE = keccak256("SENTINEL_ROLE")
```


### UPGRADER_ROLE
Role for protocol upgrades and technical maintenance authorized by governance.


```solidity
bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")
```


### ORACLE_OPERATOR_ROLE
Role for Oracle management, price feed updates, and data validation.


```solidity
bytes32 public constant ORACLE_OPERATOR_ROLE = keccak256("ORACLE_OPERATOR_ROLE")
```


### AUDITOR_ROLE
This role provides the secondary approval for victim compensations.

Role for management oversight and compensation approval (Auditors).


```solidity
bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE")
```


### MAX_BPS
Basis points denominator representing 100.00% precision.

Used in Proof of Reserves and Invariant Checkers. 100 BPS = 1.00%.


```solidity
uint256 public constant MAX_BPS = 10_000
```


### BPS_DENOMINATOR
Alias for MAX_BPS to maintain semantic clarity in denominator contexts.


```solidity
uint256 public constant BPS_DENOMINATOR = 10_000
```


### HEARTBEAT_INTERVAL
Standard heartbeat interval for oracles and pulse monitoring (24 hours).


```solidity
uint256 public constant HEARTBEAT_INTERVAL = 1 days
```


### MIN_RESERVE_RATIO
Minimum safety margin for reserve ratios.

11000 BPS = 110.00% collateralization ratio.


```solidity
uint256 public constant MIN_RESERVE_RATIO = 11_000
```


