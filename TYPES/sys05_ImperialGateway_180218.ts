/**
 * @file sys05_ImperialGateway_180218.ts
 * @version 1.0.0 AOXCDAO PRO ULTIMATE
 * @description Central interface for data aggregation and visual state projection.
 */

import * as fs from 'fs';
import { AoxcRegistry } from './sys01_AoxcRegistry_180226.ts';
import { AoxcSecurityCore } from './sec01_AoxcSecurityCore_180226.ts';
import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';

export class ImperialGateway {
    private static instance: ImperialGateway;
    private registry = AoxcRegistry.getInstance();
    private security = AoxcSecurityCore.getInstance();

    private constructor() {}

    public static getInstance(): ImperialGateway {
        if (!ImperialGateway.instance) {
            ImperialGateway.instance = new ImperialGateway();
        }
        return ImperialGateway.instance;
    }

    /**
     * @method aggregateSystemState
     * @description Compiles core metrics into a structured JSON for external UI consumption.
     */
    public aggregateSystemState() {
        return {
            protocol: "AOXCDAO_AKDENIZ",
            epoch: AOXC_GENESIS.TIME.GENESIS_EPOCH.toString(),
            integrity: "0-BYTE_TSC_SILENCE",
            fleetMetrics: {
                status: this.registry.getRegistryStatus(),
                securityLevel: this.security.reportStatus()
            },
            timestamp: new Date().toISOString()
        };
    }

    /**
     * @method generateCommandInterface
     * @description Produces the primary HTML5 Command Dashboard.
     */
    public generateCommandInterface(): void {
        const data = this.aggregateSystemState();
        
        const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AOXCDAO | COMMAND BRIDGE</title>
    <style>
        body { background: #050505; color: #00ffcc; font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; padding: 20px; }
        .dashboard { border: 2px solid #004433; padding: 20px; border-radius: 10px; box-shadow: 0 0 20px #002211; }
        .metric-card { background: #0a0a0a; border-left: 5px solid #00ffcc; margin: 10px 0; padding: 15px; }
        .glitch { animation: pulse 2s infinite; color: #00ffcc; text-transform: uppercase; font-weight: bold; }
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
        h1 { border-bottom: 1px solid #004433; padding-bottom: 10px; }
    </style>
</head>
<body>
    <div class="dashboard">
        <h1>[AOXCDAO IMPERIAL COMMAND BRIDGE]</h1>
        <div class="metric-card">
            <div class="glitch">SYSTEM STATUS: OPERATIONAL</div>
            <p>CORE INTEGRITY: <strong>${data.integrity}</strong></p>
            <p>CURRENT EPOCH: ${data.epoch}</p>
        </div>
        <div class="metric-card">
            <h3>FLEET INTELLIGENCE</h3>
            <p>${data.fleetMetrics.status}</p>
            <p>SECURITY LAYER: ${data.fleetMetrics.securityLevel}</p>
        </div>
        <div style="font-size: 0.8em; color: #006655;">LAST_SYNC: ${data.timestamp}</div>
    </div>
</body>
</html>`;

        fs.writeFileSync('./REPORTS/ACTIVE/IMPERIAL_DASHBOARD.html', htmlContent);
        console.log("!!! [GATEWAY] COMMAND BRIDGE INTERFACE GENERATED SUCCESSFULLY !!!");
    }
}

// Global Seal
export const GATEWAY_INITIALIZED = true;
