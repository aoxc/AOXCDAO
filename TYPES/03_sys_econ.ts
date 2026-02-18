/**
 * @file 03_sys_econ.ts
 * @version 2.0.4 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.ECONOMY
 * @status IMMUTABLE_ECONOMY_LOGIC
 * @description 
 * Sovereign Resource & Currency Distribution Engine. 
 * Fixed: Implemented Optional Catch Binding to resolve linter 'unused-vars' error.
 * NO TURKISH CHARACTERS IN CODE - ACADEMIC LEVEL LOGIC.
 */

import { AOXC_GENESIS, GlobalIdentityUID } from './00_sys_master';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @interface ICivilianIdentity
 * @description Local interface to decouple from bio01 for performance.
 */
export interface ICivilianIdentity {
    uid: GlobalIdentityUID;
    genClass: number;
    reputation: number;
}

/**
 * @class AoxcEconomyEngine
 * @description Orchestrates financial stability and resource bridging across sharded vessels.
 */
export class AoxcEconomyEngine {
    private static instance: AoxcEconomyEngine;

    private constructor() {}

    public static getInstance(): AoxcEconomyEngine {
        if (!AoxcEconomyEngine.instance) {
            AoxcEconomyEngine.instance = new AoxcEconomyEngine();
        }
        return AoxcEconomyEngine.instance;
    }

    /**
     * @method calculateSalary
     * @description Calculates salary based on Genetic Class and Reputation using 18-decimal precision.
     */
    public calculateSalary(citizen: ICivilianIdentity): bigint {
        const baseRate: bigint = 100n * (10n ** 18n); 
        let multiplier: bigint;

        switch (citizen.genClass) {
            case 0xFF: multiplier = 10n; break; // ADMIRAL
            case 0x80: multiplier = 4n;  break; // ALPHA
            case 0x40: multiplier = 3n;  break; // BETA
            case 0x20: multiplier = 2n;  break; // GAMMA
            default:   multiplier = 1n;          // DELTA
        }

        const reputationBonus = BigInt(Math.floor(citizen.reputation / 1000)) * (10n ** 18n);
        return (baseRate * multiplier) + reputationBonus;
    }

    /**
     * @method bridgeResources
     * @description Transfers credits between vessels with atomic tax enforcement.
     * FIXED: Catch block updated to Optional Catch Binding.
     */
    public async bridgeResources(fromVessel: number, toVessel: number, amount: bigint): Promise<boolean> {
        const isSourceSecure = await this.validateVesselStrait(fromVessel);
        const isTargetSecure = await this.validateVesselStrait(toVessel);

        if (!isSourceSecure || !isTargetSecure) {
            throw new Error('BRIDGE_CRITICAL_FAILURE: STRAIT_SEVERED_OR_UNSTABLE');
        }

        const tax = amount / 100n; // 1% Fleet Tax
        const finalAmount = amount - tax;

        try {
            // Atomic processing via Prisma Transaction
            await prisma.$transaction([
                // 1. Log the movement of net resources
                prisma.auditLog.create({
                    data: {
                        subjectUid: BigInt(fromVessel),
                        targetGateId: `BRIDGE:${toVessel}`,
                        actionStatus: Number(finalAmount / (10n ** 18n)) 
                    }
                }),
                // 2. Update Vessel Load balances
                prisma.vessel.update({
                    where: { id: fromVessel },
                    data: { currentLoad: { decrement: Number(amount) } }
                }),
                prisma.vessel.update({
                    where: { id: toVessel },
                    data: { currentLoad: { increment: Number(finalAmount) } }
                })
            ]);

            console.info(`[ECONOMY] Bridge Successful: ${finalAmount} units (Tax: ${tax})`);
            return true;
        } catch {
            // ACADEMIC FIX: Optional Catch Binding satisfies @typescript-eslint/no-unused-vars
            return false;
        }
    }

    private async validateVesselStrait(vesselId: number): Promise<boolean> {
        const vessel = await prisma.vessel.findUnique({
            where: { id: vesselId }
        });
        return vessel?.straitStatus === AOXC_GENESIS.STRAIT_PROTOCOL.STATUS_SECURE;
    }

    /**
     * @method getFleetWealthStatus
     * @description Real-time aggregate load metrics for the Admiral Dashboard.
     */
    public async getFleetWealthStatus(): Promise<string> {
        const totalLoad = await prisma.vessel.aggregate({
            _sum: { currentLoad: true }
        });
        return `ECONOMY_ONLINE | AGGREGATE_LOAD: ${totalLoad._sum.currentLoad || 0}`;
    }
}

export const ECONOMY_ENGINE_LOADED: boolean = true;
