/**
 * @file 02_sys_vessel.ts
 * @version 2.1.0 AOXCDAO V2 AKDENIZ
 * @status OPERATIONAL_VESSEL_CONTROL
 * @description 
 * Sovereign Vessel Engine. Manages physical entity location and transit.
 * Fixed: Unused variable errors and enhanced audit-ready transfer logic.
 */

import { AOXC_GENESIS, GlobalIdentityUID } from './00_sys_master';
import { PrismaClient } from '@prisma/client';
import { AquilaVault } from './20_bank_vault';

const prisma = new PrismaClient();

/**
 * @class AoxcVesselEngine
 * @description Controls vessel-level movements and gate access integrity.
 */
export class AoxcVesselEngine {
    private vault: AquilaVault;

    constructor() {
        this.vault = new AquilaVault();
    }

    /**
     * @method deployToVessel
     * @description Assigns a civilian entity to a physical vessel sector.
     */
    public async deployToVessel(identity: { uid: GlobalIdentityUID; currentVesselId: number }): Promise<void> {
        await prisma.citizen.update({
            where: { uid: identity.uid },
            data: { currentVesselId: identity.currentVesselId }
        });
        console.log(`[VESSEL_ENGINE] UID ${identity.uid} deployed to Vessel ${identity.currentVesselId}.`);
    }

    /**
     * @method requestTransit
     * @description Handles inter-vessel resource or entity transit.
     * FIXED: Parameters are now utilized in the logic or marked with '_' for the linter.
     */
    public async requestTransit(
        fromVessel: number, 
        toVessel: number, 
        _entityUid: GlobalIdentityUID, 
        transitTax: bigint
    ): Promise<boolean> {
        
        // 1. Validate Strait Status for both origin and destination
        const originVessel = await prisma.vessel.findUnique({ where: { id: fromVessel } });
        const destVessel = await prisma.vessel.findUnique({ where: { id: toVessel } });

        if (originVessel?.straitStatus !== AOXC_GENESIS.STRAIT_PROTOCOL.STATUS_SECURE ||
            destVessel?.straitStatus !== AOXC_GENESIS.STRAIT_PROTOCOL.STATUS_SECURE) {
            console.warn('[VESSEL_TRANSIT] Blocked: Secure link cannot be established.');
            return false;
        }

        // 2. Process Transit Tax (Utilizing the Vault)
        // Note: Using the system's root UID for tax collection
        const systemRootUid = BigInt(0); 
        return await this.vault.executeTransfer(_entityUid, systemRootUid, transitTax);
    }
}

export const VESSEL_ENGINE_ACTIVE: boolean = true;
