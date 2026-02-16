# IAOXCUpgradeAuthorizer
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IAOXCUpgradeAuthorizer.sol)

**Title:**
IAOXCUpgradeAuthorizer

Institutional interface for the AOXC upgrade authorization logic and logic mutations.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### validateUpgrade


```solidity
function validateUpgrade(address initiator, address implementation) external;
```

### isUpgradeAuthorized


```solidity
function isUpgradeAuthorized(address implementation) external view returns (bool authorized);
```

### getAuthorizerVersion


```solidity
function getAuthorizerVersion() external pure returns (uint256 version);
```

## Events
### UpgradeValidated

```solidity
event UpgradeValidated(
    address indexed initiator, address indexed implementation, uint256 timestamp
);
```

