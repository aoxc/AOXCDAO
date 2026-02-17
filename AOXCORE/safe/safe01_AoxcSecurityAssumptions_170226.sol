// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {AOXCErrors} from "@libraries/AOXCErrors.sol";
import {AOXCBaseReporter} from "../monitoring/AOXCBaseReporter.sol";
import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title AOXCSecurityAssumptions
 * @dev Inheritance conflict resolved by overriding the root ContextUpgradeable functions.
 */
contract AOXCSecurityAssumptions is Initializable, AOXCBaseReporter, OwnableUpgradeable {
    uint256 public maxWithdrawalPercent;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address _monitoringHub) external initializer {
        __Ownable_init(admin);
        _setMonitoringHub(_monitoringHub);
        maxWithdrawalPercent = 5;
    }

    // --- Diamond Problem Fix: Root Context Overrides ---
    // Her iki kontrat da ContextUpgradeable'dan türediği için override listesine sadece onu yazıyoruz.

    function _msgSender() internal view override(ContextUpgradeable) returns (address) {
        return super._msgSender();
    }

    function _msgData() internal view override(ContextUpgradeable) returns (bytes calldata) {
        return super._msgData();
    }

    function _contextSuffixLength() internal view override(ContextUpgradeable) returns (uint256) {
        return super._contextSuffixLength();
    }

    /**
     * @notice Güvenlik varsayımı doğrulaması.
     */
    function validateAssumption(uint256 amount, uint256 totalPool) external {
        if (totalPool > 0 && amount > (totalPool * maxWithdrawalPercent) / 100) {
            _performForensicLog(
                IMonitoringHub.Severity.CRITICAL,
                "SECURITY_ASSUMPTION_VIOLATION",
                "Max withdrawal limit exceeded",
                _msgSender(),
                90,
                abi.encode(amount)
            );
            revert AOXCErrors.SecurityAssumptionViolated();
        }
    }
}
