#!/usr/bin/env python3
import subprocess
import time
from collections import deque

MAPPING_FILE = "/etc/hysteria/port_mapping.txt"
INTERVAL = 60
WINDOW_SIZE = 5      
THRESHOLD_DROP = 0.5   

def get_bytes(chain):
    out = subprocess.check_output(
        ["iptables", "-t", "mangle", "-L", chain, "-vxn"]
    ).decode()
    line = out.splitlines()[2]
    fields = line.split()
    return int(fields[1])

def main():

    history = {}

    with open(MAPPING_FILE) as f:
        for ln in f:
            cfg, _ = ln.strip().split(":", 1)
            idx = cfg.split("config")[1]
            chain = f"HYST{idx}"
            initial = get_bytes(chain)
            history[idx] = deque([initial], maxlen=WINDOW_SIZE)

    while True:
        time.sleep(INTERVAL)
        with open(MAPPING_FILE) as f:
            for ln in f:
                cfg, _ = ln.strip().split(":", 1)
                idx = cfg.split("config")[1]
                chain = f"HYST{idx}"

                new = get_bytes(chain)
                q = history[idx]
                avg_old = sum(q) / len(q) if q else new

                drop = (avg_old - new) / avg_old if avg_old else 0
                if drop > THRESHOLD_DROP:
                    subprocess.call(["systemctl", "restart", f"hysteria{idx}"])
                q.append(new)

if __name__ == "__main__":
    main()
