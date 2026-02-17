/**
 * @file karujan_authority.ts
 * @namespace AOXCDAO.Core.Security
 * @version 2.0.0
 * @description Sovereign Root Authority & Access Control Specifications.
 * Standard: Pro-Ultimate Academic English.
 * Constraint: Zero-Turkish Policy (ZTP) - Strict Enforcement.
 */

/**
 * @interface IKarujanSpecifications
 * @description Defines the immutable parameters of the Sovereign Root Authority.
 */
export interface IKarujanSpecifications {
    readonly DESIGNATION: string;
    readonly CLEARANCE_LEVEL: number;
    readonly ROOT_SIGNATURE_ID: string;
    readonly OPERATIONAL_MODE: "SOVEREIGN" | "MAINTENANCE" | "EMERGENCY";
}

/**
 * @constant KARUJAN_SPECIFICATIONS
 * @description Master singleton containing the Root Authority's configuration.
 */
export const KARUJAN_SPECIFICATIONS: IKarujanSpecifications = {
    DESIGNATION: "KARUJAN_PRIME_CORE",
    CLEARANCE_LEVEL: 0xff, // 255
    ROOT_SIGNATURE_ID: "0xK01_GENESIS_SOVEREIGN_SIG",
    OPERATIONAL_MODE: "SOVEREIGN",
} as const;

/**
 * @enum KARUJAN_DIRECTIVES
 * @description Executive commands reserved exclusively for the Karujan Authority.
 * Hex Series: 0x0X - Denotes Root-Level Directives.
 */
export enum KARUJAN_DIRECTIVES {
    INITIATE_GENESIS    = 0x01, // Full system reset to Zero-Point
    MANDATE_UPGRADE     = 0x02, // Enforce updated fleet-wide protocols
    EMERGENCY_ISOLATION = 0x03, // Immediate isolation of all vessel dynamics
    PURGE_INCONSISTENT  = 0x04, // Automated removal of non-compliant logic
    SOVEREIGN_VETO      = 0x05, // Absolute override of any sub-vessel vote
}

/**
 * @class SovereignEngine
 * @description Active enforcement of the Root Authority's directives and clearance.
 */
export class SovereignEngine {
    /**
     * @method validateSovereignClearance
     * @description Absolute verification for high-level protocol access.
     */
    public static validateSovereignClearance(level: number): boolean {
        return level === KARUJAN_SPECIFICATIONS.CLEARANCE_LEVEL;
    }

    /**
     * @method isDirectiveAuthorized
     * @description Ensures a specific directive belongs to the Root-Level set.
     */
    public static isDirectiveAuthorized(directive: number): boolean {
        return Object.values(KARUJAN_DIRECTIVES).includes(directive);
    }

    /**
     * @method getSovereignIdentity
     * @description Retrieves the secure identity string for auditing.
     */
    public static getSovereignIdentity(): string {
        return `[AOXC_ROOT_AUTHORITY]::${KARUJAN_SPECIFICATIONS.DESIGNATION}`;
    }

    /**
     * @method executeSovereignOverride
     * @description Formalizes the override protocol for the Interface Bridge.
     */
    public static generateOverrideSignature(targetVessel: string): string {
        return `SIG_OVERRIDE_${KARUJAN_SPECIFICATIONS.ROOT_SIGNATURE_ID}_${targetVessel.toUpperCase()}`;
    }

    /**
     * @method getOperationalStatus
     * @description Returns the current global state of the Karujan Core.
     */
    public static getOperationalStatus(): string {
        return `MODE:${KARUJAN_SPECIFICATIONS.OPERATIONAL_MODE}::CLEARANCE:0x${KARUJAN_SPECIFICATIONS.CLEARANCE_LEVEL.toString(16).toUpperCase()}`;
    }
}

/**
 * @description Legacy functional exports for backward compatibility with v1.x.
 */
export const validateSovereignClearance = (level: number): boolean => SovereignEngine.validateSovereignClearance(level);
export const getSovereignIdentity = (): string => SovereignEngine.getSovereignIdentity();

export type SOVEREIGN_IDENTITY = typeof KARUJAN_SPECIFICATIONS;
export const SOVEREIGN_CORE_ACTIVE: boolean = true;
