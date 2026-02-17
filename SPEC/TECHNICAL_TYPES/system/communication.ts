/**
 * @file communication.ts
 * @namespace AOXCDAO.Core.Communication
 * @version 2.0.0
 * @description Social Stability & Announcement Protocol - (Anti-Panic-Locked)
 * Translates internal forensic truths into public safety announcements.
 */

/**
 * @constant PUBLIC_MASKING_MESSAGES
 * @description Pre-approved messages for public broadcast to maintain fleet stability.
 */
export const PUBLIC_MASKING_MESSAGES = {
    MSG_GREEN:  "SYSTEM_OPTIMIZED: Enjoy your interstellar journey.",
    MSG_YELLOW: "MAINTENANCE_LOG: Minor sub-routine updates in progress.",
    MSG_RED:    "SAFETY_DRILL: All residents please remain in your sectors.",
} as const;

/**
 * @constant FORENSIC_TO_PUBLIC_MAP
 * @description Mapping of critical forensic events to public-safe messages.
 */
export const FORENSIC_TO_PUBLIC_MAP = {
    FB01: "MSG_RED",    // Internal Breach -> Public "Safety Drill"
    EC01: "MSG_YELLOW", // Economic Drain -> Public "Maintenance"
    STBL: "MSG_GREEN",  // Stable State -> Public "Optimized"
} as const;

/**
 * @enum BROADCAST_PRIORITY
 * @description Defines the urgency of the announcement across the vessels.
 */
export enum BROADCAST_PRIORITY {
    LOW      = 0x10, // Routine updates
    MEDIUM   = 0x20, // Maintenance warnings
    URGENT   = 0x30, // Security drills (Masked Alerts)
    PROTOCOL = 0xff, // Absolute Sovereign overrides
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type ForensicEventCode = keyof typeof FORENSIC_TO_PUBLIC_MAP;
export type MaskedMessageKey = (typeof FORENSIC_TO_PUBLIC_MAP)[ForensicEventCode];

/**
 * @interface IPublicAnnouncement
 * @description The structure of a message as seen by the general population.
 */
export interface IPublicAnnouncement {
    readonly message: string;
    readonly priority: BROADCAST_PRIORITY;
    readonly vessel_scope: string[]; 
    readonly timestamp: number;
    readonly checksum: string; 
}

/**
 * @class StabilityController
 * @description Logic for masking forensic anomalies and managing public perception.
 */
export class StabilityController {
    /**
     * @method maskForensicEvent
     * @description Translates a raw forensic code into a socially-stable announcement.
     */
    public static maskForensicEvent(code: ForensicEventCode): string {
        const messageKey = FORENSIC_TO_PUBLIC_MAP[code];
        return PUBLIC_MASKING_MESSAGES[messageKey] || PUBLIC_MASKING_MESSAGES.MSG_YELLOW;
    }

    /**
     * @method getPriorityFromCode
     * @description Automatically determines broadcast priority based on forensic severity.
     */
    public static getPriorityFromCode(code: ForensicEventCode): BROADCAST_PRIORITY {
        if (code === "FB01") return BROADCAST_PRIORITY.URGENT;
        if (code === "EC01") return BROADCAST_PRIORITY.MEDIUM;
        return BROADCAST_PRIORITY.LOW;
    }

    /**
     * @method generateAnnouncement
     * @description Creates a complete signed announcement manifest for the MonitoringHub.
     */
    public static generateAnnouncement(
        code: ForensicEventCode, 
        vessels: string[]
    ): IPublicAnnouncement {
        const message = this.maskForensicEvent(code);
        const priority = this.getPriorityFromCode(code);
        const timestamp = Date.now();

        return {
            message,
            priority,
            vessel_scope: vessels,
            timestamp,
            checksum: `AOX_STBL_${timestamp}_${code}` // Forensic origin proof
        };
    }

    /**
     * @method isProtocolOverride
     * @description Checks if a message is a sovereign override that bypasses masking.
     */
    public static isProtocolOverride(priority: BROADCAST_PRIORITY): boolean {
        return priority === BROADCAST_PRIORITY.PROTOCOL;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const COMMUNICATION_SYSTEM_LOADED: boolean = true;
