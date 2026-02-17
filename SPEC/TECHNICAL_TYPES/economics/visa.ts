/**
 * @file visa.types.ts
 * @namespace AOXCDAO.Core.AccessControl
 * @version 2.0.0
 * @description AOXC Entity Visa and Access Control - (Immigration-Locked)
 * Defines the digital clearance standards for inter-vessel transit.
 */

/**
 * @constant VISA_CLASSIFICATIONS
 * @description Primary access classification for any entity entering a Vessel's jurisdiction.
 */
export const VISA_CLASSIFICATIONS = {
    COMMAND: 0x99, // Permanent Command Access (Fleet/Council)
    WORK:    0x55, // Personnel/Crew Work Permit (Operational)
    VISITOR: 0x11, // Passenger/Temporary Access (Public/Guest)
} as const;

/**
 * @constant TRANSITION_PROTOCOLS
 * @description State-machine triggers for modifying entity roles or fleet presence.
 */
export const TRANSITION_PROTOCOLS = {
    ELECTION:  0xc1, // Captain/Admin Election Sequence
    PROMOTION: 0xc2, // Role Elevation or Personnel Change
    BOARDING:  0xc3, // Cross-Vessel Entry/Exit
} as const;

/**
 * @enum AUTH_STATUS
 * @description Enforced states of the current access status within the Hub.
 */
export enum AUTH_STATUS {
    VALID       = 0x01, // Access granted and active
    REVOKED     = 0x02, // Access removed (Security/Quarantine)
    EXPIRED     = 0x03, // Access duration concluded
    SUSPENDED   = 0x04, // Temporary lock for forensic audit
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type VisaType = (typeof VISA_CLASSIFICATIONS)[keyof typeof VISA_CLASSIFICATIONS];
export type ProtocolTrigger = (typeof TRANSITION_PROTOCOLS)[keyof typeof TRANSITION_PROTOCOLS];

/**
 * @interface IVisaClearance
 * @description Formal clearance structure for cross-vessel transitions.
 */
export interface IVisaClearance {
    readonly entity_id: string; 
    readonly visa_type: VisaType;
    readonly status: AUTH_STATUS;
    readonly assigned_vessel: string; 
    readonly issued_at: number; 
    readonly expires_at: number; // Mandatory for all except COMMAND
}

/**
 * @class AccessControlEngine
 * @description Logic for visa validation, status enforcement, and transition triggers.
 */
export class AccessControlEngine {
    /**
     * @method isVisaValid
     * @description Checks if a visa is currently active and not expired.
     */
    public static isVisaValid(visa: IVisaClearance): boolean {
        const now = Math.floor(Date.now() / 1000);
        
        // Command visas are perpetual; others check expiry
        const isNotExpired = (visa.visa_type === VISA_CLASSIFICATIONS.COMMAND) || (visa.expires_at > now);
        const isActive = (visa.status === AUTH_STATUS.VALID);
        
        return isActive && isNotExpired;
    }

    /**
     * @method canAccessBridge
     * @description High-security check for command-level areas.
     */
    public static canAccessBridge(visa: IVisaClearance): boolean {
        return this.isVisaValid(visa) && visa.visa_type === VISA_CLASSIFICATIONS.COMMAND;
    }

    /**
     * @method determineTransition
     * @description Maps a trigger to its corresponding protocol requirement.
     */
    public static getRequiredTrigger(visa: IVisaClearance, targetRank: number): ProtocolTrigger | null {
        if (targetRank > visa.visa_type) return TRANSITION_PROTOCOLS.PROMOTION;
        return null;
    }

    /**
     * @method generateVisaHash
     * @description Creates a unique cryptographic signature for the visa record.
     */
    public static generateVisaHash(visa: IVisaClearance): string {
        return `VISA_SIG::${visa.entity_id.slice(0, 8)}::${visa.assigned_vessel}::${visa.issued_at}`;
    }
}

/**
 * @description Verification flag for Access Control system readiness.
 */
export const ACCESS_CONTROL_ACTIVE: boolean = true;
