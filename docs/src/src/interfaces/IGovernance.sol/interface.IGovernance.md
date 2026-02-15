# IGovernance
[Git Source](https://github.com/aoxc/AOXCDAO/blob/4906edc2cee9ebf2ba59629225d505313f10268f/src/interfaces/IGovernance.sol)

**Title:**
IGovernance

Institutional interface for AOXC decentralized governance and protocol orchestration.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### createProposal


```solidity
function createProposal(string calldata description) external returns (uint256 proposalId);
```

### vote


```solidity
function vote(uint256 proposalId, bool support) external;
```

### executeProposal


```solidity
function executeProposal(uint256 proposalId) external;
```

## Events
### ProposalCreated

```solidity
event ProposalCreated(uint256 indexed id, address proposer, string description);
```

### Voted

```solidity
event Voted(uint256 indexed id, address voter, bool support);
```

### ProposalExecuted

```solidity
event ProposalExecuted(uint256 indexed id);
```

