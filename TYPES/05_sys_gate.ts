/**
 * @file sys05_ImperialGateway_180218.ts
 * @version 1.0.1
 * @package AOXCDAO.CORE.GATEWAY
 * @status OPERATIONAL_UI_LAYER
 * @description 
 * Central Projection Engine. Aggregates real-time telemetry from sharded DB 
 * and generates the Imperial Command Bridge (HTML5) for high-level oversight.
 */

import * as fs from 'fs';
import { AoxcRegistry } from './sys01_AoxcRegistry_180226';
import { AOXC_GENESIS } from './00_sys_master';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class ImperialGateway {
    private static instance: ImperialGateway;
    private registry = AoxcRegistry.getInstance();

    private constructor() {}

    public static getInstance(): ImperialGateway {
        if (!ImperialGateway.instance) {
            ImperialGateway.instance = new ImperialGateway();
        }
        return ImperialGateway.instance;
    }

    /**
     * @method aggregateSystemState
     * @description Fetches sharded population metrics and Strait statuses via Prisma.
     */
    public async aggregateSystemState() {
        const totalCitizens = await prisma.citizen.count();
        const activeVessels = await prisma.vessel.count({
            where: { straitStatus: AOXC_GENESIS.STRAIT_PROTOCOL.STATUS_SECURE }
        });

        return {
            protocol: 'AOXCDAO_AKDENIZ_V2',
            epoch: AOXC_GENESIS.TIME.GENESIS_EPOCH.toString(),
            population: `${totalCitizens} / ${AOXC_GENESIS.SCALE.TOTAL_POPULATION_TARGET}`,
            fleetStatus: `${activeVessels} / 8 VESSELS SECURE`,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * @method generateCommandInterface
     * @description Generates the Imperial Dashboard HTML file for visual monitoring.
     */
    public async generateCommandInterface(): Promise<void> {
        const data = await this.aggregateSystemState();
        
        const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AOXC | IMPERIAL BRIDGE</title>
    <style>
        body { background: #020202; color: #00ffcc; font-family: 'Courier New', monospace; margin: 0; padding: 40px; }
        .bridge { border: 1px solid #00ffcc; padding: 30px; box-shadow: 0 0 30px #004433; }
        .status-on { color: #00ffcc; text-shadow: 0 0 10px #00ffcc; }
        .metric { border-bottom: 1px solid #004433; padding: 10px 0; display: flex; justify-content: space-between; }
        .glitch { animation: scan 4s linear infinite; }
        @keyframes scan { 0% { opacity: 1; } 50% { opacity: 0.7; } 100% { opacity: 1; } }
        h1 { letter-spacing: 5px; text-align: center; border-bottom: 2px solid #00ffcc; }
    </style>
</head>
<body>
    <div class="bridge">
        <h1 class="glitch">IMPERIAL COMMAND BRIDGE</h1>
        <div class="metric"><span>PROTOCOL:</span> <span class="status-on">${data.protocol}</span></div>
        <div class="metric"><span>POPULATION:</span> <span>${data.population}</span></div>
        <div class="metric"><span>FLEET INTEGRITY:</span> <span>${data.fleetStatus}</span></div>
        <div class="metric"><span>GENESIS EPOCH:</span> <span>${data.epoch}</span></div>
        <br>
        <div style="font-size: 0.7em; color: #004433; text-align: right;">SYSTEM_TIME: ${data.timestamp}</div>
    </div>
</body>
</html>`;

        // Ensure the reporting directory exists
        if (!fs.existsSync('./REPORTS/ACTIVE')) {
            fs.mkdirSync('./REPORTS/ACTIVE', { recursive: true });
        }

        fs.writeFileSync('./REPORTS/ACTIVE/IMPERIAL_DASHBOARD.html', htmlContent);
        console.log('[GATEWAY] >>> IMPERIAL COMMAND BRIDGE PROJECTED SUCCESSFULLY.');
    }
}
