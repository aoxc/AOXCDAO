# IPyth
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/infrastructure/AOXCSwap.sol)


## Functions
### getPriceNoOlderThan


```solidity
function getPriceNoOlderThan(bytes32 id, uint256 age) external view returns (Price memory);
```

## Structs
### Price

```solidity
struct Price {
    int64 price;
    uint64 conf;
    int32 expo;
    uint256 publishTime;
}
```

