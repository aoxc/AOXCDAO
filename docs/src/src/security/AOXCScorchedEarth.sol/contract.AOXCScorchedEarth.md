# AOXCScorchedEarth
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/security/AOXCScorchedEarth.sol)

**Inherits:**
ReentrancyGuard

**Title:**
AOXCScorchedEarth

Protocol Isolation & Audit-Controlled Compensation Module.


## State Variables
### COORDINATOR

```solidity
IAOXCAccessCoordinator public immutable COORDINATOR
```


### SAFEGUARD

```solidity
IAOXCSafeguardVault public immutable SAFEGUARD
```


### TREASURY

```solidity
ITreasury public immutable TREASURY
```


### SOVEREIGN

```solidity
address public immutable SOVEREIGN = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84
```


### proposals

```solidity
mapping(uint256 => CompensationProposal) public proposals
```


### proposalCount

```solidity
uint256 public proposalCount
```


## Functions
### constructor


```solidity
constructor(address _coord, address _safe, address _treasury) ;
```

### proposeCompensation


```solidity
function proposeCompensation(address _victim, uint256 _amount) external;
```

### approveCompensation


```solidity
function approveCompensation(uint256 _id) external;
```

### executeCompensation


```solidity
function executeCompensation(uint256 _id) external nonReentrant;
```

### _logToHub


```solidity
function _logToHub(
    IMonitoringHub.Severity severity,
    string memory category,
    string memory details
) internal;
```

## Events
### ProposalCreated

```solidity
event ProposalCreated(uint256 indexed id, address indexed victim, uint256 amount);
```

### ProposalAudited

```solidity
event ProposalAudited(uint256 indexed id, address indexed auditor);
```

### CompensationFinalized

```solidity
event CompensationFinalized(uint256 indexed id, address indexed victim);
```

## Structs
### CompensationProposal

```solidity
struct CompensationProposal {
    address victim;
    uint256 amount;
    bool approved;
    bool executed;
}
```

