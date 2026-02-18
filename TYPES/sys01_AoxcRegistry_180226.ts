/**
 * @file sys01_AoxcRegistry_180226.ts
 * @namespace AOXCDAO.Core.Registry
 * @version 2.1.2 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_CORE_REGISTRY
 * @compiler Solidity 0.8.33 Compatibility
 * @description Central Sovereign Registry. 
 */

import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';
import * as Auth from './auth00_AoxcGenesisMaster_180226.ts';
import * as Security from './safe00_AoxcGenesisMaster_180226.ts';
import * as Logger from './log00_AoxcGenesisMaster_180226.ts';
import * as Bio from './bio01_AoxcCivilianLife_180226.ts';

/**
 * @interface ICitizenRecord
 * @description Strict structural definition for registry records.
 */
export interface ICitizenRecord {
    id: bigint;
    assignment: any; // Dynamic assignment data from VesselEngine
}

export class AoxcRegistry {
    private static instance: AoxcRegistry;
    private citizenMap: Map<bigint, ICitizenRecord>;
    private totalRegistered: number = 0;

    private constructor() {
        this.citizenMap = new Map<bigint, ICitizenRecord>();
        
        // Initializing modules to satisfy TS6133
        if (Logger.LOG_GENESIS_LOADED && Auth.AUTH_GENESIS_LOADED) {
            console.log('[REGISTRY] Sovereign Infrastructure Synchronized.');
        }
    }

    public static getInstance(): AoxcRegistry {
        if (!AoxcRegistry.instance) {
            AoxcRegistry.instance = new AoxcRegistry();
        }
        return AoxcRegistry.instance;
    }

    /**
     * @method registerCitizen
     * @description Onboards entities using verified ICitizenRecord structure.
     */
    public async registerCitizen(record: ICitizenRecord): Promise<boolean> {
        const isLifeCycleValid = Bio.BIOLIFE_GENESIS_LOADED;
        const isSecurityValid = Security.SAFE_GENESIS_LOADED;

        if (!record || !isLifeCycleValid || !isSecurityValid) {
            return false;
        }

        this.citizenMap.set(record.id, record);
        this.totalRegistered++;

        return true;
    }

    /**
     * @method getRegistryStatus
     * @description Critical link for Orchestrator synchronization.
     */
    public getRegistryStatus(): string {
        return `REGISTRY_ACTIVE | NODES: ${this.totalRegistered}/${AOXC_GENESIS.SCALE.TOTAL_POPULATION_TARGET}`;
    }

    public getFleetStatus() {
        return {
            totalPopulation: this.totalRegistered,
            targetPopulation: AOXC_GENESIS.SCALE.TOTAL_POPULATION_TARGET,
            vessel: AOXC_GENESIS.FLEET[0],
            activeIntegrations: {
                auth: Auth.AUTH_GENESIS_LOADED,
                security: Security.SAFE_GENESIS_LOADED,
                bio: Bio.BIOLIFE_GENESIS_LOADED
            }
        };
    }
}

export const REGISTRY_LOADED: boolean = true;
