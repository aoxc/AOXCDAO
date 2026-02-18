// SPDX-License-Identifier: Proprietary
// Academic Grade - AOXCMainEngine Independent Safeguard & Compensation Vault
pragma solidity 0.8.33;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {IAOXCAccessCoordinator} from "@interfaces/api03_IAoxcAccessCoordinator_170226.sol";
import {AOXCErrors} from "@libraries/core08_AoxcErrorDefinitions_170226.sol";

/**
 * @title AOXCSafeguardVault
 * @author AOXCMainEngine Core Engineering
 * @notice Segregated reserve for autonomous victim compensation and emergency relief.
 * @dev Fully integrated with the MonitoringHub for forensic accountability.
 */
contract AOXCSafeguardVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Sovereign Authority (Multisig: 0x20c0...CA84)
    address public immutable SOVEREIGN = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84;

    /// @notice Fleet Coordinator
    IAOXCAccessCoordinator public immutable COORDINATOR;

    /// @notice Authorized Commander Module
    address public commander;

    // --- Events ---
    event SafeguardRefilled(uint256 amount);
    event CompensationExecuted(address indexed victim, uint256 amount);
    event CommanderUpdated(address indexed newCommander);

    constructor(address _coordinator) {
        if (_coordinator == address(0)) revert AOXCErrors.ZeroAddressDetected();
        COORDINATOR = IAOXCAccessCoordinator(_coordinator);
    }

    /**
     * @notice Links the SovereignCommander to this vault for automated aid.
     */
    function setCommander(address _commander) external {
        if (msg.sender != SOVEREIGN) revert AOXCErrors.Unauthorized(msg.sender);
        if (_commander == address(0)) revert AOXCErrors.ZeroAddressDetected();

        commander = _commander;
        _logToHub(IMonitoringHub.Severity.WARNING, "VAULT_CONFIG", "Commander Link Established");
        emit CommanderUpdated(_commander);
    }

    /**
     * @notice Transfers aid/compensation to impacted users.
     * @dev Strictly restricted to Sovereign or Authorized Commander.
     */
    function releaseCompensation(address _victim, uint256 _amount) external nonReentrant {
        if (msg.sender != commander && msg.sender != SOVEREIGN) {
            revert AOXCErrors.Unauthorized(msg.sender);
        }
        if (_victim == address(0)) revert AOXCErrors.InvalidRecipient();
        if (address(this).balance < _amount) {
            revert AOXCErrors.InsufficientReserves(address(this).balance, _amount);
        }

        (bool success,) = payable(_victim).call{value: _amount}("");
        if (!success) revert AOXCErrors.TransferFailed();

        _logToHub(IMonitoringHub.Severity.INFO, "COMPENSATION_PAID", "Aid disbursed successfully");
        emit CompensationExecuted(_victim, _amount);
    }

    /**
     * @dev Internal forensic logging via MonitoringHub.
     */
    function _logToHub(IMonitoringHub.Severity severity, string memory category, string memory details) internal {
        IMonitoringHub hub = COORDINATOR.monitoringHub();
        if (address(hub) != address(0)) {
            hub.logForensic(
                IMonitoringHub.ForensicLog({
                    source: address(this),
                    actor: msg.sender,
                    origin: tx.origin,
                    related: address(0),
                    severity: severity,
                    category: category,
                    details: details,
                    riskScore: 10,
                    nonce: 0,
                    chainId: block.chainid,
                    blockNumber: block.number,
                    timestamp: block.timestamp,
                    gasUsed: gasleft(),
                    value: msg.value,
                    stateRoot: bytes32(0),
                    txHash: bytes32(0),
                    selector: msg.sig,
                    version: 1,
                    actionReq: false,
                    isUpgraded: false,
                    environment: 1,
                    correlationId: bytes32(0),
                    policyHash: bytes32(0),
                    sequenceId: 0,
                    metadata: "",
                    proof: ""
                })
            );
        }
    }

    receive() external payable {
        _logToHub(IMonitoringHub.Severity.INFO, "VAULT_REFILL", "Safeguard liquidity increased");
        emit SafeguardRefilled(msg.value);
    }
}
