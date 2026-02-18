/**
 * @file auth00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Auth
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_AUTH_ROOT
 * @compiler Solidity 0.8.33 Compatibility
 * @description Identity, Passport, and Rank Constants for 1B+ Passengers.
 */


export enum AUTH_ROLE_FLAGS {
    VOID            = 0,
    PASSENGER       = 1 << 0,
    STAKEHOLDER     = 1 << 1,
    OPERATOR        = 1 << 2,
    WARDEN          = 1 << 3,
    COMMODORE       = 1 << 4,
    ADMIRAL_ROOT    = 1 << 7
}

export const AUTH_CONFIG = {
    VESSEL_ID: 0x01,
    VERSION: '2.0.0',
    ENCRYPTION: 'DILITHIUM_5_PQ',
    SESSION_TTL_NS: 3600_000_000_000,
    MAX_AUTH_RETRIES: 3,
    MFA_REQUIRED: true
} as const;

export interface ICitizenPassport {
    readonly uid: string;
    readonly meritScore: bigint;
    readonly roleFlags: number;
    readonly homeShardId: number;
    readonly issuingVessel: number;
}

export const AUTH_GENESIS_LOADED: boolean = true;
