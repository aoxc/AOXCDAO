/**
 * @file ent00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Entities
 * @description Definitions for all forms of existence (Biological, Synthetic, Ethereal).
 */

export enum ENTITY_CLASSIFICATION {
    CARBON_BASED   = 0x01,
    SYNTHETIC      = 0x02,
    PLASMA_BASED   = 0x03, // Star-beings
    SINGULARITY    = 0x04, // Ascended Minds
    UNKNOWN_XENO   = 0xFF
}

export interface IEntitySignature {
    readonly class: ENTITY_CLASSIFICATION;
    readonly metabolicSource: string; // Energy, Oxygen, Radiation, or Data
    readonly cognitiveLevel: number;  // From 0 (Drone) to 1000 (God-mind)
    readonly isSovereign: boolean;    // Does it have legal rights in AOXC?
}
