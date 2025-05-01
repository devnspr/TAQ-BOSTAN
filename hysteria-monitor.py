#!/usr/bin/env python3
import subprocess
import time

MAPPING_FILE = "/etc/hysteria/port_mapping.txt"
INTERVAL = 40  
THRESHOLD_DROP = 0.5 

def get_bytes(chain):
    out = subprocess.check_output(
        ["iptables", "-t", "mangle", "-L", chain, "-vxn"]
    ).decode()
    line = out.splitlines()[2]
    fields = line.split()
    return int(fields[1])

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
            idx = cfg.split("config")[-1]
            try:
                old[idx] = get_bytes(f"HYST{idx}")
            except subprocess.CalledProcessError:
                old[idx] = 0

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
                idx = cfg.split("config")[-1]
                chain = f"HYST{idx}"
                try:
                    new = get_bytes(chain)
                except subprocess.CalledProcessError:
                    continue
                prev = old.get(idx, new)
                drop = (prev - new) / prev if prev else 0
                if drop > THRESHOLD_DROP:
                    subprocess.call(["systemctl", "restart", service])
                old[idx] = new

if __name__ == "__main__":
    main()
