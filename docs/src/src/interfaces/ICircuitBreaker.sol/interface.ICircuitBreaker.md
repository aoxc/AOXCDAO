# ICircuitBreaker
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/ICircuitBreaker.sol)

**Title:**
ICircuitBreaker

Interface for the global emergency shutdown and volatility protection.


## Functions
### isProtocolPaused


```solidity
function isProtocolPaused() external view returns (bool);
```

### checkVolatility


```solidity
function checkVolatility(address asset) external view returns (bool);
```

### triggerGlobalLock


```solidity
function triggerGlobalLock() external;
```

