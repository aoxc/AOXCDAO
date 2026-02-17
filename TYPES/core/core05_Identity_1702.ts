/**
 * @file identity.types.ts
 * @namespace AOXCDAO.Core.Identity
 * @version 2.0.0
 * @description Vessel Identity Constants - (Identity-Locked)
 * Defines unique contractual personalities and behavioral modifiers for each vessel.
 */

/**
 * @enum IDENTITY_MODIFIERS
 * @description Behavioral logic modifiers that dictate how a vessel responds to contract events.
 */
export enum IDENTITY_MODIFIERS {
    DEFENSIVE  = 0xb1, // High penalty/lockdown intensity (Security focused)
    COMMERCIAL = 0xb2, // High flexibility/low friction (Economy focused)
    AGILE      = 0xb3, // High-speed validation/short TTL (Data focused)
}

/**
 * @constant VESSEL_SIGNATURE_HEADERS
 * @description Unique identifiers used in the header of every contract proposal.
 */
export const VESSEL_SIGNATURE_HEADERS = {
    VIRGO:   "VIRGO_SHIELD_STANCE",
    AQUILA:  "AQUILA_TRADE_FLOW",
    PEGASUS: "PEGASUS_INTELLIGENCE_STREAM",
    QUASAR:  "QUASAR_SENTINEL_PULSE",
} as const;

/**
 * @constant IDENTITY_MAP
 * @description Maps Vessel IDs to their specific behavioral modifiers and metadata.
 */
export const IDENTITY_MAP = {
    VIRGO:   { mod: IDENTITY_MODIFIERS.DEFENSIVE,  penalty: 0.95, override: false },
    AQUILA:  { mod: IDENTITY_MODIFIERS.COMMERCIAL, penalty: 0.20, override: true  },
    PEGASUS: { mod: IDENTITY_MODIFIERS.AGILE,      penalty: 0.40, override: true  },
    QUASAR:  { mod: IDENTITY_MODIFIERS.DEFENSIVE,  penalty: 1.00, override: false },
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IVesselPersonality
 * @description Defines the core behavioral characteristics of a vessel's contract engine.
 */
export interface IVesselPersonality {
    readonly vessel_name: string;
    readonly modifier: IDENTITY_MODIFIERS;
    readonly signature_header: string;
    readonly penalty_weight: number; 
    readonly is_override_allowed: boolean;
}

/**
 * @class PersonalityEngine
 * @description Operational logic to interpret vessel behavior based on their identity.
 */
export class PersonalityEngine {
    /**
     * @method getPersonality
     * @description Constructs the full personality profile for a vessel.
     */
    public static getPersonality(vesselKey: keyof typeof IDENTITY_MAP): IVesselPersonality {
        const config = IDENTITY_MAP[vesselKey];
        return {
            vessel_name: vesselKey,
            modifier: config.mod,
            signature_header: VESSEL_SIGNATURE_HEADERS[vesselKey],
            penalty_weight: config.penalty,
            is_override_allowed: config.override
        };
    }

    /**
     * @method calculateFinalPenalty
     * @description Adjusts a base penalty amount based on the vessel's defensive stance.
     * DEFENSIVE vessels amplify penalties; COMMERCIAL vessels minimize them.
     */
    public static calculateFinalPenalty(baseAmount: bigint, modifier: IDENTITY_MODIFIERS): bigint {
        switch (modifier) {
            case IDENTITY_MODIFIERS.DEFENSIVE:
                return (baseAmount * 150n) / 100n; // +50% Penalty
            case IDENTITY_MODIFIERS.COMMERCIAL:
                return (baseAmount * 80n) / 100n;  // -20% Penalty (Efficiency)
            case IDENTITY_MODIFIERS.AGILE:
                return baseAmount; // Standard
            default:
                return baseAmount;
        }
    }

    /**
     * @method validateHeader
     * @description Verifies if a signature header matches the claimed vessel identity.
     */
    public static validateHeader(vesselKey: keyof typeof IDENTITY_MAP, header: string): boolean {
        return VESSEL_SIGNATURE_HEADERS[vesselKey] === header;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const IDENTITY_SYSTEM_LOADED: boolean = true;
