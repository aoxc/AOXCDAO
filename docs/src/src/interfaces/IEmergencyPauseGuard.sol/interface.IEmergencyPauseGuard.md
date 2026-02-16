# IEmergencyPauseGuard
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/interfaces/IEmergencyPauseGuard.sol)

**Title:**
IEmergencyPauseGuard

Institutional interface for Guardian-initiated circuit breaker mechanisms and global state suspension.

AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.


## Functions
### pause


```solidity
function pause() external;
```

### resume


```solidity
function resume() external;
```

### isPaused


```solidity
function isPaused() external view returns (bool status);
```

## Events
### EmergencyPaused

```solidity
event EmergencyPaused(address indexed guardian, uint256 timestamp);
```

### EmergencyResumed

```solidity
event EmergencyResumed(address indexed guardian, uint256 timestamp);
```

