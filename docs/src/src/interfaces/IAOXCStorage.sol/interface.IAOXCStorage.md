# IAOXCStorage
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IAOXCStorage.sol)

**Title:**
IAOXCStorage

**Author:**
AOXC Core Engineering

Akdeniz V2 Forensic Storage Interface.

Defnes the data structure for namespaced storage.


## Structs
### MainStorage
Akdeniz V2 Ana Depolama Yapısı.
Upgradeable sistemlerde veri çakışmasını önlemek için bu struct kullanılır.


```solidity
struct MainStorage {
    uint256 protocolFee; // Protokol komisyon oranı (BPS)
    address feeCollector; // Komisyonların aktarıldığı adres
    uint256 lastForensicBlock; // Son güvenlik taraması bloğu
    bool isEmergencyActive; // Acil durum kilidi durumu
    uint256 reserveThreshold; // Minimum rezerv eşiği
}
```

