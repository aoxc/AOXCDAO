/**
 * @file gatekeeper.types.ts
 * @namespace AOXCDAO.Core.Security
 * @version 2.0.0
 * @description Gatekeeper Protocols & Perimeter Access Rules - (Border-Locked)
 * Defines the formal access portals and security enforcement levels.
 */

/**
 * @enum ACCESS_PORTALS
 * @description Physical and digital entry points into the Sovereign System.
 */
export enum ACCESS_PORTALS {
    TERMINAL  = 0x01, // Direct Hardware/Console Access
    NETWORK   = 0x02, // Remote Web3/Blockchain/Bridge Access
    EMERGENCY = 0x03, // High-Priority Override (Sovereign Only)
}

/**
 * @constant GATE_SECURITY_LEVELS
 * @description Severity of the security check required at each entry portal.
 */
export const GATE_SECURITY_LEVELS = {
    STRICT: 0xaa, // Requires Multi-Signature + Cryptographic Visa
    NORMAL: 0xbb, // Requires Standard Functional Visa
    GUEST:  0xcc, // Minimum validation (Read-only / Public)
} as const;

/**
 * @constant BORDER_ENFORCEMENT
 * @description Automated countermeasures for unauthorized perimeter breach.
 */
export const BORDER_ENFORCEMENT = {
    VIOLATION_SIGNAL: 0xfb01, // Links to SECURITY_ERRORS.ERR_SIG_BREACH
    FAIL_ACTION: "REJECT_AND_LOCK", 
    MAX_ATTEMPTS: 3, 
    COOLDOWN_PERIOD: 3600, // Seconds (1 hour) after lockout
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IGateAccessRequest
 * @description Formal structure for an entity requesting entry to a specific portal.
 */
export interface IGateAccessRequest {
    readonly request_id: string; 
    readonly portal: ACCESS_PORTALS;
    readonly required_level: number; 
    readonly applicant_address: string; 
    readonly geo_origin?: string; 
    readonly timestamp: number;
}

/**
 * @class GatekeeperController
 * @description Operational logic for perimeter defense and access validation.
 */
export class GatekeeperController {
    /**
     * @method validateAccess
     * @description Verifies if the applicant meets the security level for the portal.
     * @param request The active access request
     * @param entityLevel The security level provided by the entity's visa
     */
    public static validateAccess(request: IGateAccessRequest, entityLevel: number): boolean {
        // Lower numerical value in GATE_SECURITY_LEVELS means higher security requirement
        // STRICT (0xAA) < NORMAL (0xBB) < GUEST (0xCC)
        return entityLevel <= request.required_level;
    }

    /**
     * @method isEmergencyAuthorized
     * @description Exclusive check for the EMERGENCY portal.
     */
    public static isEmergencyAuthorized(request: IGateAccessRequest, isSovereign: boolean): boolean {
        if (request.portal === ACCESS_PORTALS.EMERGENCY) {
            return isSovereign;
        }
        return true;
    }

    /**
     * @method shouldLockout
     * @description Determines if an entity should be blacklisted based on failed attempts.
     */
    public static shouldLockout(failCount: number): boolean {
        return failCount >= BORDER_ENFORCEMENT.MAX_ATTEMPTS;
    }

    /**
     * @method generateViolationTrace
     * @description Creates a forensic trace for unauthorized entry attempts.
     */
    public static generateViolationTrace(request: IGateAccessRequest): string {
        return `PERIMETER_BREACH_ATTEMPT:${request.portal}:${request.applicant_address}`;
    }

    /**
     * @method getPortalRequirement
     * @description Returns the default security level for a specific portal.
     */
    public static getPortalRequirement(portal: ACCESS_PORTALS): number {
        switch (portal) {
            case ACCESS_PORTALS.EMERGENCY: return GATE_SECURITY_LEVELS.STRICT;
            case ACCESS_PORTALS.TERMINAL:  return GATE_SECURITY_LEVELS.NORMAL;
            case ACCESS_PORTALS.NETWORK:   return GATE_SECURITY_LEVELS.GUEST;
            default: return GATE_SECURITY_LEVELS.STRICT;
        }
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const GATEKEEPER_SYSTEM_LOADED: boolean = true;
