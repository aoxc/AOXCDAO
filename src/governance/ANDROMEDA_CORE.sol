// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {
    AOXCGovernor,
    IVotes,
    TimelockControllerUpgradeable,
    IReputationManager,
    IMonitoringHub
} from "./AOXCGovernor.sol";

/**
 * @title ANDROMEDA_CORE
 * @notice AOXC Yönetişim Sisteminin Sektör ve Politika Katmanı
 */
contract ANDROMEDA_CORE is AOXCGovernor {
    uint256 public constant MAX_KINETIC_MULTIPLIER = 600;
    uint256 public constant BASE_SCALAR = 100;

    mapping(uint256 => address) public sectorRegistry;
    bool public rigorousMonetaryPolicyActive;
    uint256 public globalEfficiencyMultiplier;

    event SectorLinked(uint256 indexed sectorId, address indexed sectorAddress);
    event StabilityPolicyShifted(bool indexed isStrict, uint256 timestamp);
    event KineticCalibrated(uint256 newMultiplier);

    error InvalidSectorRange();
    error SectorNotRegistered();
    error MultiplierExceedsLimit();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // AOXCGovernor() çağrısını sildik, yerine güvenli kilit ekledik
        _disableInitializers();
    }

    /**
     * @dev Initialize fonksiyonu. AOXCGovernor'ın initialize'ını da çağırır.
     */
    function initializeAndromeda(
        IVotes _token,
        TimelockControllerUpgradeable _timelock,
        address _admin,
        IReputationManager _rep,
        IMonitoringHub _mon
    ) public initializer {
        // Ebeveyn sınıfın initialize fonksiyonunu manuel çağırıyoruz
        super.initialize(_token, _timelock, _admin, _rep, _mon);

        rigorousMonetaryPolicyActive = true;
        globalEfficiencyMultiplier = BASE_SCALAR;
    }

    // --- Sektör Yönetimi ---
    function registerSector(uint256 _sectorId, address _sectorAddress)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (_sectorId == 0 || _sectorId > 7) revert InvalidSectorRange();
        sectorRegistry[_sectorId] = _sectorAddress;
        emit SectorLinked(_sectorId, _sectorAddress);
    }

    function calibrateGlobalKinetic(uint256 _newMultiplier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_newMultiplier > MAX_KINETIC_MULTIPLIER) revert MultiplierExceedsLimit();
        globalEfficiencyMultiplier = _newMultiplier;
        emit KineticCalibrated(_newMultiplier);
    }

    function removeSector(uint256 _sectorId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (sectorRegistry[_sectorId] == address(0)) revert SectorNotRegistered();
        delete sectorRegistry[_sectorId];
    }

    function _getVotes(address account, uint256 timepoint, bytes memory params)
        internal
        view
        override
        returns (uint256)
    {
        uint256 reputationWeightedVotes = super._getVotes(account, timepoint, params);
        return (reputationWeightedVotes * globalEfficiencyMultiplier) / 100;
    }

    function toggleMonetaryGuard(bool _active) external onlyRole(VETO_ROLE) {
        rigorousMonetaryPolicyActive = _active;
        emit StabilityPolicyShifted(_active, block.timestamp);
    }
}
