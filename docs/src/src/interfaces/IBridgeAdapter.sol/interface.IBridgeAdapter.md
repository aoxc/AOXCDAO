# IBridgeAdapter
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IBridgeAdapter.sol)

**Title:**
IBridgeAdapter

Institutional-grade interface for cross-chain liquidity synchronization and bridge orchestration.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### bridgeAsset

Initiates a cross-chain asset transfer.

V5 FIX: Added 'payable' to support native gas token bridging and protocol fees.


```solidity
function bridgeAsset(uint256 targetChainId, address token, uint256 amount, address recipient)
    external
    payable
    returns (bytes32 txHash);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`targetChainId`|`uint256`|The destination chain identifier.|
|`token`|`address`|The address of the token to bridge (use address(0) for native gas tokens).|
|`amount`|`uint256`|The quantity of assets to transfer.|
|`recipient`|`address`|The destination address on the target chain.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`txHash`|`bytes32`|The unique transaction identifier for tracking.|


### isTransactionFinalized

Verifies if a specific bridge transaction has reached finality.


```solidity
function isTransactionFinalized(bytes32 txHash) external view returns (bool finalized);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`txHash`|`bytes32`|The transaction identifier to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`finalized`|`bool`|Boolean indicating completion status.|


### getAdapterName

Returns the human-readable identifier of the bridge adapter.


```solidity
function getAdapterName() external pure returns (string memory name);
```

### getSupportedChains

Retrieves the list of destination chains currently supported by this adapter.


```solidity
function getSupportedChains() external view returns (uint256[] memory chains);
```

## Events
### AssetBridged

```solidity
event AssetBridged(
    uint256 indexed targetChainId,
    address indexed token,
    address indexed recipient,
    uint256 amount,
    bytes32 txHash,
    uint256 timestamp
);
```

### BridgeFinalized

```solidity
event BridgeFinalized(bytes32 indexed txHash, uint256 timestamp);
```

