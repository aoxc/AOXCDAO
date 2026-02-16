# IAOXCSwap
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IAOXCSwap.sol)

**Title:**
IAOXCSwap

**Author:**
AOXC Core Engineering

Interface for the protocol-wide liquidity exchange engine.


## Functions
### executeSwap

Performs a swap between two supported assets.


```solidity
function executeSwap(SwapRoute calldata route, uint256 amountIn)
    external
    payable
    returns (uint256 amountOut);
```

### getAmountOut

Returns price quote for a given amount.


```solidity
function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn)
    external
    view
    returns (uint256);
```

## Events
### SwapExecuted

```solidity
event SwapExecuted(
    address indexed user,
    address indexed tokenIn,
    address indexed tokenOut,
    uint256 amountIn,
    uint256 amountOut,
    uint8 riskScore
);
```

## Structs
### SwapRoute

```solidity
struct SwapRoute {
    address tokenIn;
    address tokenOut;
    uint24 poolFee;
    uint256 minAmountOut;
}
```

