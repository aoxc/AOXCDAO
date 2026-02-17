graph TD
    subgraph Governance
        G[AOXCGovernor] --> T[AOXCTimelock]
    end

    subgraph Core_Layer
        AC[ANDROMEDACORE] --> HUB[AOXCHub]
        HUB --> AA[AOXCAccessCoordinator]
    end

    subgraph Asset_Layer
        MC[MintController] --> ABL[AssetBackingLedger]
        RC[RedeemController] --> ABL
    end

    subgraph Security_Monitoring
        MH[MonitoringHub] --- FP[ForensicPulse]
        QS[QUASAR_SENTRY] --> MH
    end

    AC --- HUB
    HUB --- MC
    HUB --- MH
