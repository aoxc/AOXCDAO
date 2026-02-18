/**
 * @file bio01_AoxcCivilianLife_180226.ts
 * @namespace AOXCDAO.Core.BioLife
 * @version 2.5.1 AOXCDAO V2 AKDENIZ
 * @description Advanced Genetic Identity and Reputation Engine.
 * @compiler Solidity 0.8.33 Compatibility (Logic-Level)
 */

import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';

export enum GeneticClass {
    ALPHA = 0x01,
    BETA  = 0x02,
    GAMMA = 0x03,
    DELTA = 0x04
}

export interface ICivilianIdentity {
    uid: string;
    dnaHash: string;
    genClass: GeneticClass;
    reputation: number;
    lastSync: bigint;
}

export class AoxcCivilianLife {
    private static instance: AoxcCivilianLife;
    private vesselAccessRules: Map<number, GeneticClass>;

    private constructor() {
        this.vesselAccessRules = new Map();
        this.initializeAccessRules();
    }

    public static getInstance(): AoxcCivilianLife {
        if (!AoxcCivilianLife.instance) {
            AoxcCivilianLife.instance = new AoxcCivilianLife();
        }
        return AoxcCivilianLife.instance;
    }

    /**
     * @method initializeAccessRules
     * @description Dynamically links access rules using the AOXC_GENESIS Fleet definitions.
     */
    private initializeAccessRules(): void {
        // Link to AOXC_GENESIS to satisfy TS6133 and establish logic hierarchy
        const fleetKeys = Object.keys(AOXC_GENESIS.FLEET).map(Number);
        
        // Critical Rule: Vessel 0 (ARMAGEDDON) always requires ALPHA class.
        if (fleetKeys.includes(0)) {
            this.vesselAccessRules.set(0, GeneticClass.ALPHA);
        }
        
        // Vessel 1 (ANDROMEDA) requires at least BETA class.
        if (fleetKeys.includes(1)) {
            this.vesselAccessRules.set(1, GeneticClass.BETA);
        }
    }

    public validateVesselAccess(identity: ICivilianIdentity, targetVesselId: number): boolean {
        const requiredClass = this.vesselAccessRules.get(targetVesselId);
        if (!requiredClass) return true;
        return identity.genClass <= requiredClass;
    }

    public generateDnaHash(input: string): string {
        return `ZKP-DNA-${Buffer.from(input).toString('hex').slice(0, 32)}`;
    }
}

export const BIOLIFE_GENESIS_LOADED: boolean = true;
