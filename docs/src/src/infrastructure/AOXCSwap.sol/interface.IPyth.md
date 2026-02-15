# IPyth
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/infrastructure/AOXCSwap.sol)


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

