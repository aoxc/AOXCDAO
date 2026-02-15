# AOXCReentrancyGuard
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/security/AOXCReentrancyGuard.sol)

**Inherits:**
AccessControl

**Title:**
AOXCReentrancyGuard

**Author:**
AOXC Core Engineering

Global singleton guard to prevent cross-contract reentrancy attacks.

This contract acts as a central lock for the entire AOXC ecosystem.


## State Variables
### _NOT_ENTERED

```solidity
uint256 private constant _NOT_ENTERED = 1
```


### _ENTERED

```solidity
uint256 private constant _ENTERED = 2
```


### _status

```solidity
uint256 private _status
```


## Functions
### constructor

Initializes the guard in a 'NOT_ENTERED' state.


```solidity
constructor(address admin) ;
```

### enter

Enters the global lock.

Should be called by AOXC contracts via a dedicated modifier.


```solidity
function enter() external;
```

### exit

Exits the global lock.


```solidity
function exit() external;
```

### loadStatus

Returns the current reentrancy status.


```solidity
function loadStatus() external view returns (uint256);
```

## Errors
### AOXC__GlobalReentrancyDetected

```solidity
error AOXC__GlobalReentrancyDetected();
```

### AOXC__CallerNotAuthorized

```solidity
error AOXC__CallerNotAuthorized();
```

