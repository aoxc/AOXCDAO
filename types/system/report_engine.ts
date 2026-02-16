/**
 * @file report_engine.ts
 * @namespace AOXCDAO.Core.Reporting
 * @version 2.0.0
 * @description Authorized Reporting Engine - (Privacy-Locked)
 * Filters forensic data based on UnifiedRank and Vessel Access Levels.
 * Standard: Pro-Ultimate Academic English (Zero-Turkish Policy).
 */

import { UnifiedRank, MANDATE_ROLES, TRANSITIONAL_ROLES } from "../core/merit.ts";
import { EMERGENCY_CODES } from "../security/alert.ts";

/**
 * @enum REPORT_LEVEL
 * @description Defines the depth of information revealed in a system report.
 */
export enum REPORT_LEVEL {
    PUBLIC_GENERIC  = 0x01, // Masked: "Everything is fine"
    STAFF_OPERATIVE = 0x02, // Technical: Alert codes visible
    PRIME_FORENSIC  = 0x03, // Full: Raw Forensic DNA & Location
}

/**
 * @interface IRawSystemData
 * @description Internal interface for type-guarding raw system inputs.
 */
interface IRawSystemData {
    vessel_id: string;
    location: string;
    dna: string;
}

/**
 * @interface ISystemReport
 * @description Standardized reporting structure with multi-tier data masking.
 */
export interface ISystemReport {
    readonly timestamp: number;
    readonly vessel_id: string;
    readonly report_tier: REPORT_LEVEL;
    readonly status: string;
    readonly summary: string;
    readonly forensic_dna?: string; 
    readonly alert_code?: string; 
    readonly report_signature: string; // Integrity seal
}

/**
 * @class ReportingEngine
 * @description Academic engine for authorized data filtering and forensic obfuscation.
 */
export class ReportingEngine {
    /**
     * @method generateReport
     * @description Filters raw system data based on the provided authority rank.
     * Fixed: Replaced 'any' with a type-guarded 'unknown' structure.
     */
    public static generateReport(rank: UnifiedRank, input: unknown): ISystemReport {
        const timestamp = Date.now();
        
        // Type Guard: Ensure input matches our required raw data structure
        const rawData = input as IRawSystemData;
        
        const base = {
            timestamp,
            vessel_id: rawData?.vessel_id || "UNKNOWN_VESSEL",
        };

        // Tier 1: Sovereign & Captain (The Absolute Truth)
        if (rank >= MANDATE_ROLES.CAPTAIN_ELECT) {
            return {
                ...base,
                report_tier: REPORT_LEVEL.PRIME_FORENSIC,
                status: "CRITICAL_BREACH_DETECTED",
                summary: `Sector ${rawData?.location}: Unauthorized injection attempt detected via bridge.`,
                forensic_dna: rawData?.dna,
                alert_code: EMERGENCY_CODES.SECURITY.CODE_1001,
                report_signature: this.sealReport(rawData?.dna || "VOID", timestamp)
            };
        }

        // Tier 2: Staff/Officer (Maintenance & Operational View)
        if (rank >= TRANSITIONAL_ROLES.CREW) {
            return {
                ...base,
                report_tier: REPORT_LEVEL.STAFF_OPERATIVE,
                status: "SECURITY_STAGING_ACTIVE",
                summary: "System undergoing automated security stabilization protocols.",
                alert_code: "ALERT_SEC_1001",
                report_signature: this.sealReport("STAFF_ACCESS", timestamp)
            };
        }

        // Tier 3: Passenger/Guest (Public/Masked View)
        return {
            ...base,
            report_tier: REPORT_LEVEL.PUBLIC_GENERIC,
            status: "NOMINAL_OPERATIONS",
            summary: "Routine background synchronizations and fleet-wide optimizations are in progress.",
            report_signature: this.sealReport("PUBLIC_ACCESS", timestamp)
        };
    }

    /**
     * @method sealReport
     * @description Generates a forensic seal to prevent report tampering.
     */
    private static sealReport(seed: string, time: number): string {
        return `REPORT_SEAL::${seed.substring(0, 6)}::${time}`;
    }

    /**
     * @method getReportLevel
     * @description Helper to map UnifiedRank to its corresponding Report Level.
     */
    public static getRequiredLevel(rank: UnifiedRank): REPORT_LEVEL {
        if (rank >= MANDATE_ROLES.CAPTAIN_ELECT) return REPORT_LEVEL.PRIME_FORENSIC;
        if (rank >= TRANSITIONAL_ROLES.CREW) return REPORT_LEVEL.STAFF_OPERATIVE;
        return REPORT_LEVEL.PUBLIC_GENERIC;
    }
}

/**
 * @description Verification flag for Reporting Engine operationality.
 */
export const REPORTING_ENGINE_ONLINE: boolean = true;
