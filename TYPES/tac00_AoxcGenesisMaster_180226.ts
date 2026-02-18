/**
 * @file tac00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Tactics
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_TACTICAL_ROOT
 * @compiler Solidity 0.8.33 Compatibility
 * @description Universal Tactical Equilibrium, Arsenal Manifest, and Entropy Mitigation.
 */


/**
 * @enum ARSENAL_CATEGORY
 * @description Infinite-scale classification for all offensive and defensive assets.
 */
export enum ARSENAL_CATEGORY {
    /** @description Physical/Energy-based mitigation (Shields, Plate, Hulls). */
    MITIGATION_ARMOR     = 0x10, 
    
    /** @description Matter-displacing or energy-projecting offense. */
    KINETIC_ENERGY_STRIKE = 0x20, 
    
    /** @description Disrupts neural or artificial intelligence logic paths. */
    COGNITIVE_WARFARE     = 0x30, 
    
    /** @description Tools that alter Spacial Geometry or Dimensional Flow. */
    SPATIAL_DISTORTION    = 0x40, 
    
    /** @description Manipulation of time-flow or entropy-decay at a local level. */
    TEMPORAL_MODULATION   = 0x50, 
    
    /** @description Undefined/Ascended technology beyond current classification. */
    TRANSCENDENT_GEAR     = 0xFF  
}

/**
 * @interface IUniversalEquipment
 * @description The mathematical DNA of any item, from a nano-blade to a Dyson-Ray.
 */
export interface IUniversalEquipment {
    readonly assetId: string;
    readonly category: ARSENAL_CATEGORY;
    
    /** @description Power Output or Protection Rating (18-decimal precision). */
    readonly entropyMagnitude: bigint; 
    
    /** @description Reliability of the equipment (0 to 100). */
    readonly integrityScore: number; 
    
    /** @description Is the item bound to a specific Entity Class (from ent00)? */
    readonly requirementMask: number; 
    
    /** @description The dimensional plane (from dim00) where this asset functions. */
    readonly functionalPlane: number; 
}

export const TACTICAL_CONFIG = {
    MAX_ARSENAL_LOADOUT: 12, // Maximum synchronized assets per Entity
    MIN_INTEGRITY_FOR_DEPLOYMENT: 15, // Equipment below 15% fails
    GLOBAL_COOLDOWN_NS: 500_000_000, // 0.5s tactical reset
    ENTROPY_DAMPING_FACTOR: 0.05 // Natural resistance of the universe to extreme power
} as const;

export const TACTICAL_GENESIS_LOADED: boolean = true;
