# ICircuitBreaker
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/interfaces/ICircuitBreaker.sol)

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

