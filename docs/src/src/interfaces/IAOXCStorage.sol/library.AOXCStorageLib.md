# AOXCStorageLib
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IAOXCStorage.sol)

**Title:**
AOXCStorageLib

"aoxc.v2.storage.main" üzerinden üretilen güvenli slot erişimcisi.


## State Variables
### AKDENIZ_MAIN_STORAGE_SLOT
Akdeniz V2 Ana Depolama Yuvası (Slot)

cast keccak "aoxc.v2.storage.main" komutu ile doğrulanmıştır.
Değer: 0xedbb9b1d1af287a7eef677d0c66220cce633d61fbed8f49ada54d6f8461e74bf


```solidity
bytes32 internal constant AKDENIZ_MAIN_STORAGE_SLOT =
    0xedbb9b1d1af287a7eef677d0c66220cce633d61fbed8f49ada54d6f8461e74bf
```


## Functions
### akdenizStorage

Akdeniz V2 isimli depolama alanına pointer döner.

Bu fonksiyon assembly kullanarak veriyi 'AKDENIZ_MAIN_STORAGE_SLOT' adresinden okur.


```solidity
function akdenizStorage() internal pure returns (IAOXCStorage.MainStorage storage $);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`$`|`IAOXCStorage.MainStorage`|Ana depolama referansı (MainStorage).|


