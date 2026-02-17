/**
 * @file audit_control.ts
 * @namespace AOXCDAO.Security
 * @version 1.0.1
 * @description System-Wide Integrity & Security Audit Engine.
 * Fixed hexadecimal naming conventions for Pro-Ultimate compliance.
 */

import { KARUJAN_SPECIFICATIONS } from "../core/karujan_authority.ts";

/**
 * @enum AUDIT_SEVERITY
 * @description Classification of found issues during the audit.
 */
export enum AUDIT_SEVERITY {
    LINT_WARNING  = 0xa01, // Formatting or doc issues
    LOGIC_ERROR   = 0xe02, // Potential functional failure
    SECURITY_GAP  = 0xb03, // Authority or access violation
    CRITICAL_HALT = 0xf04, // System must stop immediately
}

/**
 * @interface IAuditReport
 * @description The structure of the security report sent to the Karujan.
 */
export interface IAuditReport {
    readonly file_name: string;
    readonly issue_count: number;
    readonly severity: AUDIT_SEVERITY;
    readonly timestamp: number;
    readonly suggestions: string[];
    readonly is_fixed: boolean;
}

/**
 * @constant AUDIT_CONSTRAINTS
 * @description Strict rules for the Karujan Pro-Ultimate Standard.
 */
export const AUDIT_CONSTRAINTS = {
    STRICT_TYPES: true,
    ALLOW_ANY: false,
    REQUIRE_TSDOC: true,
    MAX_FILE_SIZE_KB: 100,
    SIGNATURE_REQUIRED: true,
} as const;

/**
 * @class AuditManager
 * @description Operational logic for enforcement of Karujan compliance.
 */
export class AuditManager {
    /**
     * @method isCompliant
     * @description Checks if a specific report meets the minimum security threshold.
     */
    public static isCompliant(report: IAuditReport): boolean {
        // High severity issues must be fixed to be compliant
        if (report.severity >= AUDIT_SEVERITY.SECURITY_GAP && !report.is_fixed) {
            return false;
        }
        return report.issue_count < 10;
    }

    /**
     * @method calculateRiskIndex
     * @description Generates a risk score based on audit findings.
     * Scale: 0.0 (Safe) to 1.0 (Critical)
     */
    public static calculateRiskIndex(reports: IAuditReport[]): number {
        if (reports.length === 0) return 0;
        
        const fatalCount = reports.filter(r => r.severity === AUDIT_SEVERITY.CRITICAL_HALT).length;
        if (fatalCount > 0) return 1.0;

        const totalIssues = reports.reduce((acc, curr) => acc + curr.issue_count, 0);
        return Math.min(totalIssues / 100, 0.9);
    }

    /**
     * @method getAuditStatus
     * @description Returns a status message for the Karujan command interface.
     */
    public static getAuditStatus(fileCount: number): string {
        // Updated logic: 50 is the minimum for v1.0.1 compliance
        if (fileCount < 50) {
            return `INCOMPLETE_FLEET_DETECTION: ${fileCount}/52_NODES_ACTIVE`;
        }
        return `AUDIT_PASSED_VERSION_${KARUJAN_SPECIFICATIONS.CLEARANCE_LEVEL}`;
    }
}

/**
 * @function runSystemAudit
 * @description Functional wrapper for legacy support (Standardized).
 * @param {number} fileCount - Total number of detected configuration files.
 * @returns {string} Status message.
 */
export const runSystemAudit = (fileCount: number): string => {
    return AuditManager.getAuditStatus(fileCount);
};

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const AUDIT_CONTROL_LOADED: boolean = true;
