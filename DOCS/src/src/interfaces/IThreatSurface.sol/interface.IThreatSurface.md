# IThreatSurface
[Git Source](https://github.com/aoxc/AOXCDAO/blob/2a934811b2291dd4f15fb2ad8d8398e1deb3833b/src/interfaces/IThreatSurface.sol)

**Title:**
IThreatSurface

Interface for formalizing attack vectors and proactive defense telemetry.

AOXC Ultimate Protocol Standard.


## Functions
### isThreatDetected


```solidity
function isThreatDetected(bytes32 patternId) external view returns (bool detected);
```

### getRegisteredPatterns


```solidity
function getRegisteredPatterns() external view returns (bytes32[] memory patterns);
```

### getPatternCount


```solidity
function getPatternCount() external view returns (uint256 count);
```

### registerThreatPattern


```solidity
function registerThreatPattern(bytes32 patternId) external;
```

### removeThreatPattern


```solidity
function removeThreatPattern(bytes32 patternId) external;
```

## Events
### ThreatPatternRegistered

```solidity
event ThreatPatternRegistered(bytes32 indexed patternId, uint256 timestamp);
```

### ThreatPatternRemoved

```solidity
event ThreatPatternRemoved(bytes32 indexed patternId, uint256 timestamp);
```

### ThreatDetected

```solidity
event ThreatDetected(bytes32 indexed patternId, address indexed evaluator, uint256 timestamp);
```

## Enums
### RiskLevel
Severity levels for detected anomalies.

Moved inside interface to resolve Identifier Not Found error in implementation.


```solidity
enum RiskLevel {
    LOW,
    MEDIUM,
    HIGH,
    CRITICAL
}
```

