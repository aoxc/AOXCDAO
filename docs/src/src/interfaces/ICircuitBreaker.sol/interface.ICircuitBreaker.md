# ICircuitBreaker
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/ICircuitBreaker.sol)

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

