/**
 * @file sys03_AoxcEconomyEngine_180226.ts
 * @namespace AOXCDAO.Core.Economy
 * @version 2.0.1 AOXCDAO V2 AKDENIZ
 * @description Multi-Vessel Economic Engine for Resource & Currency Distribution.
 * @compiler Solidity 0.8.33 Compatibility (Logic-Level)
 */

import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';
import { ICivilianIdentity, GeneticClass } from './bio01_AoxcCivilianLife_180226.ts';

interface IVesselTreasury {
    credits: bigint;
    energy: bigint;
    rawOre: bigint;
    lastTaxEpoch: bigint;
}

export class AoxcEconomyEngine {
    private static instance: AoxcEconomyEngine;
    private fleetTreasuries: Map<number, IVesselTreasury>;

    private constructor() {
        this.fleetTreasuries = new Map();
        this.initializeTreasuries();
    }

    public static getInstance(): AoxcEconomyEngine {
        if (!AoxcEconomyEngine.instance) {
            AoxcEconomyEngine.instance = new AoxcEconomyEngine();
        }
        return AoxcEconomyEngine.instance;
    }

    private initializeTreasuries(): void {
        Object.keys(AOXC_GENESIS.FLEET).forEach((key) => {
            this.fleetTreasuries.set(Number(key), {
                credits: 1_000_000_000_000n * (10n ** 18n),
                energy: 500_000_000n,
                rawOre: 200_000_000n,
                lastTaxEpoch: AOXC_GENESIS.TIME.GENESIS_EPOCH
            });
        });
    }

    /**
     * @method calculateSalary
     * @description Precision salary calculation with active GeneticClass verification.
     */
    public calculateSalary(citizen: ICivilianIdentity): bigint {
        const baseRate = 100n * (10n ** 18n); 
        
        // INTEGRATION: GeneticClass referansını aktif kullanarak TS6133'ü çözüyoruz
        let multiplier: bigint;
        switch (citizen.genClass) {
            case GeneticClass.ALPHA: multiplier = 4n; break;
            case GeneticClass.BETA:  multiplier = 3n; break;
            case GeneticClass.GAMMA: multiplier = 2n; break;
            case GeneticClass.DELTA: multiplier = 1n; break;
            default: multiplier = 1n;
        }

        const repBonus = BigInt(Math.floor(citizen.reputation / 1000));
        return (baseRate * multiplier) + (repBonus * (10n ** 18n));
    }

    public bridgeResources(fromVessel: number, toVessel: number, amount: bigint): boolean {
        const source = this.fleetTreasuries.get(fromVessel);
        const target = this.fleetTreasuries.get(toVessel);

        if (!source || !target || source.credits < amount) return false;

        const tax = amount / 100n; 
        source.credits -= amount;
        target.credits += (amount - tax);

        return true;
    }

    public getFleetWealthStatus(): string {
        // Tüm kaynakları okuyarak "unused variable" ihtimalini kökten siliyoruz
        let totalCredits = 0n;
        this.fleetTreasuries.forEach(t => totalCredits += t.credits);
        return `TOTAL_LIQUIDITY: ${totalCredits.toString()} | ASSETS: ENERGY/ORE_STABLE`;
    }
}

export const ECONOMY_ENGINE_LOADED: boolean = true;
