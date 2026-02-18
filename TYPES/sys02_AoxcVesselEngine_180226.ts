/**
 * @file sys02_AoxcVesselEngine_180226.ts
 * @namespace AOXCDAO.Core.VesselEngine
 * @version 2.1.0 AOXCDAO V2 AKDENIZ
 * @description Spatial distribution with Meritocratic Filtering (DNA-Check).
 * @compiler Solidity 0.8.33 Compatibility (Logic-Level)
 */

import { AOXC_GENESIS, GlobalIdentityUID } from './sys00_AoxcGenesisMaster_180226.ts';
import { AoxcRegistry } from './sys01_AoxcRegistry_180226.ts';
import { AoxcCivilianLife, ICivilianIdentity } from './bio01_AoxcCivilianLife_180226.ts';

interface IVesselAssignment {
    vesselId: number;
    shardId: number;
    entryTimestamp: bigint;
    identityHash: GlobalIdentityUID;
}

export class AoxcVesselEngine {
    private registry: AoxcRegistry;
    private bioEngine: AoxcCivilianLife;
    private vesselOccupancy: Map<number, number>;

    constructor() {
        this.registry = AoxcRegistry.getInstance();
        this.bioEngine = AoxcCivilianLife.getInstance();
        this.vesselOccupancy = new Map<number, number>();
        this.initializeVesselMetrics();
    }

    private initializeVesselMetrics(): void {
        Object.keys(AOXC_GENESIS.FLEET).forEach((key) => {
            this.vesselOccupancy.set(Number(key), 0);
        });
    }

    public calculateOptimalShard(citizenId: bigint): number {
        return Number(citizenId % BigInt(AOXC_GENESIS.SCALE.TOTAL_SHARDS));
    }

    /**
     * @method deployToVessel
     * @description Assigns citizen after validating Genetic Class requirements.
     * @throws Error if biological requirements are not met.
     */
    public async deployToVessel(citizen: ICivilianIdentity): Promise<IVesselAssignment> {
        const citizenId = BigInt(citizen.uid.split('-').pop() || '0');
        const shardId = this.calculateOptimalShard(citizenId);
        const vesselId = Math.floor(shardId / (AOXC_GENESIS.SCALE.TOTAL_SHARDS / 8));

        // CRITICAL: Meritocratic Filter (The Hard Test)
        const hasAccess = this.bioEngine.validateVesselAccess(citizen, vesselId);
        
        if (!hasAccess) {
            throw new Error(`SECURITY_BREACH: Citizen DNA Class [${citizen.genClass}] insufficient for Vessel [${vesselId}]`);
        }

        const assignment: IVesselAssignment = {
            vesselId: vesselId,
            shardId: shardId,
            entryTimestamp: AOXC_GENESIS.TIME.GENESIS_EPOCH,
            identityHash: citizen.dnaHash // DNA Hash now becomes the primary identity seal
        };

        // Sync with Registry
        await this.registry.registerCitizen({ id: citizenId, assignment });

        const currentPop = this.vesselOccupancy.get(vesselId) || 0;
        this.vesselOccupancy.set(vesselId, currentPop + 1);

        return assignment;
    }

    public getStatus(): string {
        return `ENGINE:ONLINE | REGISTRY_SYNC:OK | BIO_FILTER:ACTIVE`;
    }
}

export const VESSEL_ENGINE_LOADED: boolean = true;
