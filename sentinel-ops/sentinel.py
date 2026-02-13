"""
---------------------------------------------------------------------------------
PROJECT  : AOXC-V2-AKDENIZ - ABSOLUTE NOTARY (MUTLAK NOTER)
VERSION  : 8.3.5 "ULTIMATE STABLE"
---------------------------------------------------------------------------------
"""

import json, time, os, subprocess, sys, hashlib
from web3 import Web3
from web3.datastructures import AttributeDict

# --- [ CONFIG & IDENTITY ] ---
IDENTITY_TAG = "AOXC-V2-AKDENIZ-SUPREME-NOTARY"
OFFICIAL_X   = "https://x.com/AOXC_AKDENIZ"

TARGETS = [
    "0xeb9580c3946bb47d73aae1d4f7a94148b554b2f4",
    "0x97Bdd1fD1CAF756e00eFD42eBa9406821465B365",
    "0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84"
]

RPC_NODES     = ["https://xlayer.drpc.org", "https://rpc.xlayer.okx.com"]
IPFS_PATH     = "/mnt/xdbx/ipfs/aoxc-prime"
BLOCK_STEP    = 85 # RPC Limiti (100) için güvenli bölge
GENESIS_BLOCK = 52084000 # Dosya yoksa başlama noktası

BASE_DIR     = os.path.dirname(os.path.abspath(__file__))
CURSOR_FILE  = os.path.join(BASE_DIR, "LAST_SCANNED_BLOCK")
SNAPSHOT_DIR = os.path.join(BASE_DIR, "snapshots")
LOG_DIR      = os.path.join(BASE_DIR, "logs")

def initialize_system():
    """Gerekli klasör yapısını kurar."""
    for folder in [SNAPSHOT_DIR, LOG_DIR]:
        if not os.path.exists(folder):
            os.makedirs(folder)
    if not os.path.exists(CURSOR_FILE):
        with open(CURSOR_FILE, "w") as f:
            f.write(str(GENESIS_BLOCK))

def setup_ghost_rpc():
    """Bağlantı koparsa yedek RPC'ye geçer."""
    headers = {'User-Agent': f'AOXC-Sentinel-V8 ({OFFICIAL_X})'}
    for url in RPC_NODES:
        try:
            w3 = Web3(Web3.HTTPProvider(url, request_kwargs={'headers': headers, 'timeout': 30}))
            if w3.is_connected(): return w3
        except: continue
    sys.exit("\n[!] FATAL: Tüm RPC kapıları kapalı.")

def run_supreme_notary():
    initialize_system()
    w3 = setup_ghost_rpc()
    
    # Nerede kaldığımızı oku
    with open(CURSOR_FILE, "r") as f:
        last_block = int(f.read().strip())
        
    current_block = w3.eth.block_number

    print(f"\n{'='*70}")
    print(f"[SYSTEM] AOXC-V2-AKDENIZ SUPREME NOTARY V8.3.5 ACTIVATED")
    print(f"[MEMORY] Resuming from block: {last_block}")
    print(f"[TARGET] Scanning until: {current_block}")
    print(f"{'='*70}\n", flush=True)

    raw_vault = []
    pointer = last_block
    checksum_targets = [w3.to_checksum_address(t) for t in TARGETS]

    try:
        while pointer < current_block:
            end = min(pointer + BLOCK_STEP, current_block)
            
            # Veri çekme
            logs = w3.eth.get_logs({'fromBlock': pointer, 'toBlock': end, 'address': checksum_targets})
            
            for log in logs:
                raw_item = json.loads(Web3.to_json(log))
                raw_vault.append(raw_item)
            
            # Anlık log basma (Journalctl için)
            print(f"[>] Syncing: {pointer} -> {end} | Proofs: {len(raw_vault)}", flush=True)
            
            # --- [ KRİTİK: HER ADIMDA KAYDET ] ---
            pointer = end + 1
            with open(CURSOR_FILE, "w") as f:
                f.write(str(pointer))
            
            time.sleep(0.05) # RPC throttle koruması

        if not raw_vault:
            print(f"\n[*] Yeni veri bulunamadı. Beklemede: {current_block}", flush=True)
            return

        # --- [ ATOMİK MÜHÜRLEME VE SERTİFİKA ] ---
        print(f"\n[*] MÜHÜRLEME BAŞLADI (Atomic Sealing)...", flush=True)
        
        raw_manifest = json.dumps(raw_vault, sort_keys=True)
        atomic_hash = hashlib.sha256(raw_manifest.encode()).hexdigest().upper()

        final_bundle = {
            "attestation": {
                "fingerprint_sha256": atomic_hash,
                "notary_seal": IDENTITY_TAG,
                "author": OFFICIAL_X,
                "range": f"{last_block}-{current_block}",
                "unix_ts": int(time.time()),
                "motto": "In Code We Trust - AOXC Akdeniz"
            },
            "raw_payload": raw_vault
        }

        # Sertifika Dosyasını Kaydet
        f_name = f"Supreme_Sealed_{int(time.time())}.json"
        f_path = os.path.join(SNAPSHOT_DIR, f_name)
        with open(f_path, 'w', encoding='utf-8') as f:
            json.dump(final_bundle, f, indent=4)

        # IPFS'e Mühürle
        env = os.environ.copy()
        env["IPFS_PATH"] = IPFS_PATH
        proc = subprocess.run(['ipfs', 'add', '-Q', f_path], capture_output=True, text=True, env=env)

        if proc.returncode == 0:
            cid = proc.stdout.strip()
            print(f"\n[+] MÜHÜR TAMAMLANDI: {atomic_hash}")
            print(f"[+] IPFS SERTİFİKA CID: {cid}\n", flush=True)
        else:
            print(f"\n[!] IPFS Hatası: {proc.stderr}")

    except Exception as e:
        print(f"\n[CRITICAL] Error: {str(e)}", flush=True)

if __name__ == "__main__":
    run_supreme_notary()
