#!/usr/bin/env python3
import subprocess
import time

MAPPING_FILE   = "/etc/hysteria/port_mapping.txt"
INTERVAL       = 20   
THRESHOLD_DROP = 0.5  

def get_bytes(chain: str) -> int:
    """
    Returns the byte-count for the given iptables chain in the mangle table.
    If the chain doesn't exist or has no counters yet, returns 0.
    """
    try:
        out = subprocess.check_output(
            ["iptables", "-t", "mangle", "-L", chain, "-vxn"],
            stderr=subprocess.DEVNULL
        ).decode()
    except subprocess.CalledProcessError:

        return 0

    lines = out.splitlines()
    if len(lines) < 3:

        return 0


    parts = lines[2].split()
    try:
        return int(parts[1])
    except (IndexError, ValueError):
        return 0

def main():

    old = {}
    with open(MAPPING_FILE) as f:
        for ln in f:
            ln = ln.strip()
            if not ln or ln.startswith("#"):
                continue
            parts = ln.split("|")
            if len(parts) != 3:
                continue
            cfg, service, ports = parts
            idx = cfg.split("config")[-1].split(".")[0]
            old[idx] = get_bytes(f"HYST{idx}")


    while True:
        time.sleep(INTERVAL)
        with open(MAPPING_FILE) as f:
            for ln in f:
                ln = ln.strip()
                if not ln or ln.startswith("#"):
                    continue
                parts = ln.split("|")
                if len(parts) != 3:
                    continue
                cfg, service, ports = parts
                idx   = cfg.split("config")[-1].split(".")[0]
                chain = f"HYST{idx}"

                new = get_bytes(chain)
                prev = old.get(idx, new)
                drop = (prev - new) / prev if prev else 0

                if drop > THRESHOLD_DROP:
                    subprocess.call(["systemctl", "restart", service])

                old[idx] = new

if __name__ == "__main__":
    main()
