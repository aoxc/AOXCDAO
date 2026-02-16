# ForensicPulse
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/monitoring/ForensicPulse.sol)

**Title:**
ForensicPulse

**Author:**
AOXC Core Engineering

Ensures telemetry integrity across all forensic channels.

Reverts transactions if forensic logging fails, preventing "silent" attacks.
Compliant with 2026 strict linting rules.


## State Variables
### MONITORING_HUB
The central hub for forensic data collection.

Marked as immutable for gas efficiency and naming convention compliance.


```solidity
IMonitoringHub public immutable MONITORING_HUB
```


## Functions
### constructor


```solidity
constructor(address _hub) ;
```

### requirePulse

Verification gate for high-stakes operations.

This should be called inside critical functions like 'bridgeAsset' or 'updatePolicy'.


```solidity
function requirePulse(IMonitoringHub.ForensicLog calldata log) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`log`|`IMonitoringHub.ForensicLog`|The forensic log data to be transmitted to the hub.|


## Errors
### AOXC__Pulse_TelemetryOffline

```solidity
error AOXC__Pulse_TelemetryOffline();
```

