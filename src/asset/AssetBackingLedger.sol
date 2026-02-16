// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { IMonitoringHub } from "./interfaces/IMonitoringHub.sol";
import { IReputationManager } from "./interfaces/IReputationManager.sol";

/**
 * @title AssetBackingLedger
 * @author AOXCDAO
 * @notice RWA (Real World Asset) varlıklarının muhasebesini ve sistem limitlerini yöneten ana kontrat.
 * @dev UUPS (EIP-1822) standardında yükseltilebilir, rol tabanlı erişim kontrolü ve duraklatma özelliklerine sahiptir.
 */
contract AssetBackingLedger is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    // --- Roles ---

    /// @notice Sistem yönetici rolü (Admin yetkileri için)
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    /// @notice Varlık giriş/çıkış işlemlerini yöneten rol
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("AOXC_ASSET_MANAGER_ROLE");
    /// @notice Dış AI ajanları için tanımlanan özel rol
    bytes32 public constant EXTERNAL_AI_AGENT_ROLE = keccak256("EXTERNAL_AI_AGENT_ROLE");

    // --- State Variables ---

    /// @notice İşlemlerin raporlandığı izleme merkezi kontratı
    IMonitoringHub public monitoringHub;
    /// @notice Kullanıcı veya ajan itibarlarını yöneten kontrat
    IReputationManager public reputationManager;

    /// @notice Sistemdeki tüm varlıkların toplam miktarı
    uint256 public totalAssets;
    /// @notice Sistemin kabul edebileceği maksimum toplam varlık miktarı
    uint256 public systemLimit;

    /// @dev Kayıtlı varlık ID'lerinin listesi
    bytes32[] private _assetIds;
    /// @dev Varlık ID'sine göre güncel bakiye tutan mapping
    mapping(bytes32 => uint256) private _assetBalances;
    /// @dev Varlığın sistemde tanımlı olup olmadığını kontrol eden mapping
    mapping(bytes32 => bool) private _isAssetKnown;

    // --- Custom Errors ---

    error AOXC__ZeroAddress();
    error AOXC__ZeroAmount();
    error AOXC__InsufficientBalance();
    error AOXC__InvalidAssetId();
    error AOXC__SystemCapReached(uint256 currentTotal, uint256 limit);

    // --- Events ---

    /**
     * @notice Varlık sisteme yatırıldığında tetiklenir.
     * @param caller İşlemi başlatan adres.
     * @param assetId Yatırılan varlığın benzersiz ID'si.
     * @param amount Yatırılan miktar.
     * @param timestamp İşlemin gerçekleştiği zaman damgası.
     */
    event AssetDeposited(address indexed caller, bytes32 indexed assetId, uint256 indexed amount, uint256 timestamp);

    /**
     * @notice Varlık sistemden çekildiğinde tetiklenir.
     * @param caller İşlemi başlatan adres.
     * @param assetId Çekilen varlığın benzersiz ID'si.
     * @param amount Çekilen miktar.
     * @param timestamp İşlemin gerçekleştiği zaman damgası.
     */
    event AssetWithdrawn(address indexed caller, bytes32 indexed assetId, uint256 indexed amount, uint256 timestamp);

    /**
     * @notice Toplam varlık miktarı güncellendiğinde tetiklenir.
     * @param oldTotal Güncelleme öncesi toplam miktar.
     * @param newTotal Güncelleme sonrası yeni toplam miktar.
     * @param timestamp İşlem zamanı.
     */
    event TotalAssetsUpdated(uint256 indexed oldTotal, uint256 indexed newTotal, uint256 timestamp);

    /**
     * @notice Sistem üst limiti değiştirildiğinde tetiklenir.
     * @param oldLimit Eski limit değeri.
     * @param newLimit Yeni limit değeri.
     */
    event SystemLimitUpdated(uint256 indexed oldLimit, uint256 indexed newLimit);

    /**
     * @notice Yeni bir AI ajanı sisteme kaydedildiğinde tetiklenir.
     * @param agent Ajanın cüzdan adresi.
     * @param contractHash Ajanın sözleşme doğrulama hash'i.
     */
    event AIAgentRegistered(address indexed agent, bytes32 indexed contractHash);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Kontratın ilk kurulumunu yapar.
     * @param admin Başlangıç yöneticisi adresi.
     * @param _monitoringHub İzleme merkezi adresi.
     * @param _reputationManager İtibar yönetimi adresi.
     */
    function initialize(
        address admin, 
        address _monitoringHub, 
        address _reputationManager
    ) external initializer {
        if (admin == address(0) || _monitoringHub == address(0) || _reputationManager == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(ASSET_MANAGER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);
        
        systemLimit = type(uint256).max;
    }

    // --- Core Functions ---

    /**
     * @notice Belirli bir varlığı ledger'a kaydeder ve bakiyeyi artırır.
     * @param assetId İşlem yapılacak varlığın ID'si.
     * @param amount Eklenecek miktar.
     */
    function depositAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        if (assetId == bytes32(0)) revert AOXC__InvalidAssetId();
        if (amount == 0) revert AOXC__ZeroAmount();

        uint256 currentTotal = totalAssets;
        if (currentTotal + amount > systemLimit) {
            revert AOXC__SystemCapReached(currentTotal, systemLimit);
        }

        if (!_isAssetKnown[assetId]) {
            _assetIds.push(assetId);
            _isAssetKnown[assetId] = true;
        }

        uint256 oldTotal = currentTotal;
        unchecked {
            _assetBalances[assetId] += amount;
            totalAssets = oldTotal + amount;
        }

        emit TotalAssetsUpdated(oldTotal, totalAssets, block.timestamp);
        emit AssetDeposited(msg.sender, assetId, amount, block.timestamp);

        _logToHub("DEPOSIT", "Asset added to ledger.");
    }

    /**
     * @notice Belirli bir varlığı ledger'dan düşer ve bakiyeyi azaltır.
     * @param assetId İşlem yapılacak varlığın ID'si.
     * @param amount Çıkarılacak miktar.
     */
    function withdrawAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        uint256 currentBal = _assetBalances[assetId];
        if (currentBal < amount) revert AOXC__InsufficientBalance();

        uint256 oldTotal = totalAssets;
        unchecked {
            _assetBalances[assetId] = currentBal - amount;
            totalAssets = oldTotal - amount;
        }

        emit TotalAssetsUpdated(oldTotal, totalAssets, block.timestamp);
        emit AssetWithdrawn(msg.sender, assetId, amount, block.timestamp);

        _logToHub("WITHDRAW", "Asset removed from ledger.");
    }

    // --- Admin Functions ---

    /**
     * @notice Sistemin toplam varlık kapasite limitini günceller.
     * @param newLimit Yeni limit değeri.
     */
    function setSystemLimit(uint256 newLimit) external onlyRole(ADMIN_ROLE) {
        emit SystemLimitUpdated(systemLimit, newLimit);
        systemLimit = newLimit;
    }

    /**
     * @notice Sisteme yeni bir AI ajanı yetkilendirir.
     * @param agent Yetki verilecek ajanın adresi.
     */
    function registerAIAgent(address agent) external onlyRole(ADMIN_ROLE) {
        if (agent == address(0)) revert AOXC__ZeroAddress();
        _grantRole(EXTERNAL_AI_AGENT_ROLE, agent);
        emit AIAgentRegistered(agent, keccak256("AOXC_AGENT_V1"));
    }

    /** @notice Kontrat üzerindeki işlemleri acil durum için duraklatır. */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /** @notice Duraklatılmış işlemleri tekrar başlatır. */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // --- View Functions ---

    /**
     * @notice Bir varlığın güncel bakiyesini döner.
     * @param assetId Sorgulanacak varlık ID'si.
     * @return Varlığın bakiyesi.
     */
    function getAssetBalance(bytes32 assetId) external view returns (uint256) {
        return _assetBalances[assetId];
    }

    /**
     * @notice Varlığın sistem tarafından tanınıp tanınmadığını döner.
     * @param assetId Sorgulanacak varlık ID'si.
     * @return Tanınıyorsa true.
     */
    function isAssetSupported(bytes32 assetId) external view returns (bool) {
        return _isAssetKnown[assetId];
    }

    /**
     * @notice Sistemde kayıtlı olan tüm varlık ID'lerini listeler.
     * @return Varlık ID dizisi.
     */
    function getAllAssetIds() external view returns (bytes32[] memory) {
        return _assetIds;
    }

    // --- Internal Helpers ---

    /**
     * @dev MonitoringHub'a log gönderen iç yardımcı fonksiyon.
     */
    function _logToHub(string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            try monitoringHub.quickLog(msg.sender, msg.sender, action, details) {} catch {}
        }
    }

    /**
     * @dev Kontrat yükseltmelerini yetkilendiren fonksiyon. Sadece Admin yapabilir.
     * @param newImplementation Yeni uygulanacak kontrat adresi.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {
        // Parametre UUPS standardı gereği gereklidir ancak gövdede ek işlem gerekmez.
    }
}
