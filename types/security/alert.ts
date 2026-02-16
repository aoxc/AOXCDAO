/**
 * @file alert.ts
 * @namespace AOXCDAO.Security.Response
 * @version 2.0.0
 * @description AOXC Internal Emergency Short Codes - (Alert-Locked)
 */

import { ACTION_REGISTRY } from "../system/action.ts";

/**
 * @constant EMERGENCY_CODES
 * @description High-priority alert codes for rapid response.
 */
export const EMERGENCY_CODES = {
    // 1000 Series: Critical Security Violations
    SECURITY: {
        CODE_1001: "MASSIVE_HACK_DETECTED",
        CODE_1002: "UNAUTHORIZED_ACCESS",
    },

    // 2000 Series: Resource & Economic Anomalies
    RESOURCE: {
        CODE_2001: "TREASURY_ANOMALY",
        CODE_2002: "RESERVE_FLUCTUATION",
    },

    // 3000 Series: Governance & Integrity Risks
    GOVERNANCE: {
        CODE_3001: "MUTINY_RISK_DETECTED",
    },
} as const;

/**
 * @enum EMERGENCY_SEVERITY
 * @description Operational severity levels for the AOXC MonitoringHub.
 */
export enum EMERGENCY_SEVERITY {
    STABLE   = 0x00,
    WARNING  = 0x01,
    CRITICAL = 0x02,
    FATAL    = 0x03, // Links to ACTION_REGISTRY.AUDIT.EMERGENCY_HALT
}

// -----------------------------------------------------------------------------
// ACADEMIC VALIDATION LOGIC (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type SecurityAlert = (typeof EMERGENCY_CODES.SECURITY)[keyof typeof EMERGENCY_CODES.SECURITY];
export type ResourceAlert = (typeof EMERGENCY_CODES.RESOURCE)[keyof typeof EMERGENCY_CODES.RESOURCE];
export type GovernanceAlert = (typeof EMERGENCY_CODES.GOVERNANCE)[keyof typeof EMERGENCY_CODES.GOVERNANCE];

/**
 * @interface IAOXPulseSignal
 * @description Standardized structure for forensic signal transmission.
 */
export interface IAOXPulseSignal {
    readonly alert_code: string; 
    readonly message: string; 
    readonly severity: EMERGENCY_SEVERITY;
    readonly origin_vessel: number; // Changed to number for Registry alignment
    readonly timestamp: number;
}

/**
 * @class AlertSentinel
 * @description Active monitoring logic to interpret and escalate system alerts.
 */
export class AlertSentinel {
    /**
     * @method shouldTriggerHalt
     * @description Checks if the alert severity necessitates a global system shutdown.
     */
    public static shouldTriggerHalt(signal: IAOXPulseSignal): boolean {
        return signal.severity === EMERGENCY_SEVERITY.FATAL;
    }

    /**
     * @method getEscalationAction
     * @description Maps an alert signal to its required system action.
     */
    public static getEscalationAction(signal: IAOXPulseSignal): number {
        if (this.shouldTriggerHalt(signal)) {
            return ACTION_REGISTRY.AUDIT.EMERGENCY_HALT;
        }

        switch (signal.severity) {
            case EMERGENCY_SEVERITY.CRITICAL:
                return ACTION_REGISTRY.AUDIT.TRACE; // Trigger deep scan
            case EMERGENCY_SEVERITY.WARNING:
                return ACTION_REGISTRY.GOVERNANCE.VOTE; // Request consensus on risk
            default:
                return 0x00; // Normal operations
        }
    }

    /**
     * @method formatForensicLog
     * @description Formats the alert for the Forensic DNA logger.
     */
    public static formatForensicLog(signal: IAOXPulseSignal): string {
        return `[FORENSIC_SIG] [${signal.severity}] CODE: ${signal.alert_code} | ORIGIN: VESSEL_${signal.origin_vessel}`;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const ALERT_SYSTEM_LOADED: boolean = true;
