/**
 * @file dim00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Dimensions
 * @description Universal Spacial Geometry & Multiverse Coordinates.
 */

export enum PLANE_TYPE {
    MATERIAL   = 0x01, // Physical 3D Space
    HYPERSPACE = 0x02, // FTL Travel Corridors
    QUANTUM    = 0x03, // Sub-atomic Reality
    VIRTUAL    = 0x04  // Pure Neural/Data Existence
}

export interface IUniversalCoord {
    readonly dimensionId: number;
    readonly sector_x: bigint;
    readonly sector_y: bigint;
    readonly sector_z: bigint;
    readonly realmHash: string; // Unique identifier for a specific Universe/Galaxy
}
