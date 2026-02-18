// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IGovernance
 * @notice Institutional interface for AOXCMainEngine decentralized governance and protocol orchestration.
 * @dev    AOXCMainEngine Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IGovernance {
    // --- SECTION: EVENTS ---
    event ProposalCreated(uint256 indexed id, address proposer, string description);
    event Voted(uint256 indexed id, address voter, bool support);
    event ProposalExecuted(uint256 indexed id);

    // --- SECTION: MANDATE OPERATIONS ---
    function createProposal(string calldata description) external returns (uint256 proposalId);
    function vote(uint256 proposalId, bool support) external;
    function executeProposal(uint256 proposalId) external;
}
