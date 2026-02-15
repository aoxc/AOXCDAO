"""
---------------------------------------------------------------------------------
PROJECT   : AOXC-V2-AKDENIZ - ABSOLUTE NOTARY (MUTLAK NOTER)
OWNER     : AOXC DAO (Akdeniz Division)
RESOURCES : https://github.com/aoxc/AOXCDAO
CONTACT   : aoxcdao@gmail.com
VERSION   : 8.4.0 "SUPREME STABLE"
LICENSE   : Proprietary / AOXC Internal
---------------------------------------------------------------------------------
Description:
High-precision blockchain event notary for X Layer. 
Implements atomic sealing via SHA-256 and IPFS persistence.
---------------------------------------------------------------------------------
"""

import json
import time
import os
import subprocess
import sys
import hashlib
import random
from datetime import datetime
from web3 import Web3

# --- [ IDENTITY & PARTNER CONFIGURATION ] ---
IDENTITY = {
    "TAG": "AOXC-V2-AKDENIZ-SUPREME-NOTARY",
    "ORG": "AOXC DAO",
    "CONTACT": "aoxcdao@gmail.com",
    "GITHUB": "https://github.com/aoxc/AOXCDAO",
    "X": "https://x.com/AOXC_AKDENIZ",
    "MUSEUM_TAG": "AOXC-PRIME-ARTIFACT"
}

# --- [ NETWORK PARAMETERS ] ---
RPC_NODES     = ["https://xlayer.drpc.org", "https://rpc.xlayer.okx.com"]
GENESIS_BLOCK = 52084000
BLOCK_STEP    = 70       # Optimized for low-latency & low-impact scanning
THROTTLE_TIME = 0.12     # Industrial cooling period between calls

# --- [ TARGET ASSETS ] ---
TARGETS = [
    "0xeb9580c3946bb47d73aae1d4f7a94148b554b2f4",
    "0x97Bdd1fD1CAF756e00eFD42eBa9406821465B365",
    "0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84"
]

# --- [ FILESYSTEM PERSISTENCE ] ---
BASE_DIR      = os.path.dirname(os.path.abspath(__file__))
PATHS = {
    "CURSOR": os.path.join(BASE_DIR, "LAST_SCANNED_BLOCK"),
    "SNAPSHOTS": os.path.join(BASE_DIR, "snapshots"),
    "LOGS": os.path.join(BASE_DIR, "logs"),
    "IPFS_BIN": "/mnt/xdbx/ipfs/aoxc-prime"
}

def initialize_industrial_structure():
    """
    Sets up the mandatory AOXC directory hierarchy with failsafe checks.
    """
    for folder in [PATHS["SNAPSHOTS"], PATHS["LOGS"]]:
        os.makedirs(folder, exist_ok=True)
    
    if not os.path.exists(PATHS["CURSOR"]):
        with open(PATHS["CURSOR"], "w") as f:
            f.write(str(GENESIS_BLOCK))

def get_supreme_provider():
    """
    Establishes a transparent, identified connection with the RPC gateway.
    Declares AOXC Partner identity via HTTP headers.
    """
    identity_header = {
        'User-Agent': f"{IDENTITY['TAG']}/{IDENTITY['ORG']} Partner-Integrator ({IDENTITY['X']})",
        'Content-Type': 'application/json'
    }
    
    for url in RPC_NODES:
        try:
            w3 = Web3(Web3.HTTPProvider(url, request_kwargs={'headers': identity_header, 'timeout': 30}))
            if w3.is_connected():
                return w3
        except Exception:
            continue
    sys.exit(f"\n[!] CRITICAL: All gateway nodes are unreachable for {IDENTITY['ORG']}.")

def seal_artifact(payload, start_block, end_block):
    """
    Performs atomic SHA-256 sealing and metadata embedding for IPFS distribution.
    """
    manifest_str = json.dumps(payload, sort_keys=True)
    atomic_hash = hashlib.sha256(manifest_str.encode()).hexdigest().upper()
    
    certificate = {
        "attestation": {
            "fingerprint": atomic_hash,
            "notary_seal": IDENTITY["TAG"],
            "authority": IDENTITY["ORG"],
            "repository": IDENTITY["GITHUB"],
            "contact": IDENTITY["CONTACT"],
            "timestamp": datetime.utcnow().isoformat(),
            "range": f"{start_block}-{end_block}"
        },
        "payload": payload
    }
    
    return certificate, atomic_hash

def run_notary_cycle():
    """
    Core execution loop for the AOXC Supreme Notary.
    Ensures data integrity with minimal network footprint.
    """
    initialize_industrial_structure()
    w3 = get_supreme_provider()
    
    with open(PATHS["CURSOR"], "r") as f:
        cursor = int(f.read().strip())
    
    current_head = w3.eth.block_number
    checksum_targets = [w3.to_checksum_address(t) for t in TARGETS]

    print(f"\n{'#'*80}")
    print(f" AOXC SUPREME NOTARY | ACTIVE SESSION")
    print(f" NODE ADDRESS   : {w3.provider.endpoint_uri}")
    print(f" TARGET SCOPE   : {len(TARGETS)} Contracts")
    print(f" SYNC RANGE     : {cursor} -> {current_head}")
    print(f"{'#'*80}\n")

    vault = []
    pointer = cursor

    try:
        while pointer < current_head:
            limit = min(pointer + BLOCK_STEP, current_head)
            
            # High-efficiency log retrieval
            logs = w3.eth.get_logs({'fromBlock': pointer, 'toBlock': limit, 'address': checksum_targets})
            
            for log in logs:
                vault.append(json.loads(Web3.to_json(log)))

            # Progress Tracking
            print(f"[PROGRESS] {pointer} -> {limit} | Artifacts Secured: {len(vault)}", flush=True)
            
            # Atomic state save
            pointer = limit + 1
            with open(PATHS["CURSOR"], "w") as f:
                f.write(str(pointer))
            
            # Industrial Throttling (Partner Compliance)
            time.sleep(THROTTLE_TIME + random.uniform(0, 0.05))

        if not vault:
            print("[*] No new data identified. Standing by for next block cycle.")
            return

        # Execution of the Sealing Ritual
        certificate, final_hash = seal_artifact(vault, cursor, current_head)
        
        # Save to Artifact Vault
        file_name = f"AOXC_CERT_{int(time.time())}_{final_hash[:8]}.json"
        full_path = os.path.join(PATHS["SNAPSHOTS"], file_name)
        
        with open(full_path, 'w', encoding='utf-8') as f:
            json.dump(certificate, f, indent=4)

        print(f"\n[+] SEALING COMPLETE: {final_hash}")
        print(f"[+] ARTIFACT SAVED : {file_name}")

    except Exception as e:
        print(f"\n[ERROR] System Integrity Breach: {str(e)}")

if __name__ == "__main__":
    run_notary_cycle()
