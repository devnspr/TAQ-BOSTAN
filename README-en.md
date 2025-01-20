[فارسی](https://github.com/ParsaKSH/TAQ-BOSTAN/blob/main/README.md)
---
# TAQ-BOSTAN Project: Creating a Local IPv6 over IPv4 Using WireGuard

Welcome to **TAQ-BOSTAN Script, the first script for creating a local IP via WireGuard**This script helps you obtain a local (private) IPv6 address on servers that do not allow you to create a local IP through methods such as SIT, GRE, VXLAN, etc.
---
This script works in blocked servers!
---
Note: If your server does not restrict creating a local IP using SIT, GRE, VXLAN, etc., it’s better not to use this project and instead go for approaches like SIT. That’s because WireGuard, due to its encryption overhead, increases CPU load and can reduce the server’s bandwidth. The number of CPU cores isn’t relevant here — only the CPU frequency matters, since WireGuard uses only a single core for its connection. Moreover, WireGuard sends data over UDP, so if there’s any disruption in UDP, the WireGuard-style tunnel may also run into issues.
My SIT-based script for creating a local IPv6: https://github.com/ParsaKSH/Create-Private-IPv6-with-Sit
---

## **Features**
- Supports **connecting multiple foreign servers to a single Iranian server**  
- **Customizable** options for setting port, MTU, IPv6 addresses, etc.
- **Persistent** after a server reboot (the service starts automatically)
- **Ready-to-use documentation* and script for convenient installation and configuration

---

## *Installation & Setup*
**
1. **Obtain the script**  
  Run this command to directly fetch and run the script:
   ```bash
   bash <(curl -Ls https://raw.githubusercontent.com/ParsaKSH/TAQ-BOSTAN/main/script.sh)
2. **Choose the server**  
   At the beginning, you’ll be asked whether you’re running the script on the Iranian or a foreign server (IRAN/FOREIGN)?
   - If you choose IRAN, you can define multiple FOREIGN servers.  
   - If you choose FOREIGN, you only enter the details of that foreign server so it can sync with the Iranian server.
3. **Enter the details**  
   - **Public IP of the Iranian or foreign server**  
   - **WireGuard port** (default is 51820)
   - **Number of foreign servers** (in IRAN mode)
   - **Public key** of the other server
   - **Foreign server index** (for assigning a unique IPv6)  
   - **MTU** (default 1380)  
4. **Final execution**  
   - After all questions, a config file is created in `/etc/wireguard/`.
   - The **wg-quick** service is enabled and will start on boot.
   - For each **foreign server**, a `[Peer]` section is added to the Iranian server’s config.

---

## **Simple Example**
- **Iranian Server**  
  1. Choose IRAN 
  2. Enter the server’s public IP (e.g., `1.2.3.4`)  
  3. Set the number of foreign servers (e.g., `2`)
  4. You’ll be asked for the public IP and public key of each foreign server 
  5. Specify the MTU (or press Enter to accept 1380) 
- **Foreign Server**  
  1. Choose FOREIGN  
  2. Enter the foreign server’s public IP (e.g., `5.6.7.8`)  
  3.Enter the Iranian server’s public IP (`1.2.3.4`) and its public key 
  4. Specify which foreign server number this is (1 for the first, 2 for the second, etc.)
  5. Enter the MTU  
  6. A file at `/etc/wireguard/wg86.conf` is generated and ready for use.

---

## **Support & Contact**
- **My Telegram ID**: [@ParsaA_KSH](https://t.me/ParsaA_KSH)  
- **OPIran Group Link**: [OPIranClub@](https://t.me/OPIranClub)

If you encounter any issues or have questions, please tag me in the OPIran group.
I hope this script and documentation will be useful for you! If you like it, please star the project so more people can discover it. Wishing you success!

---

## **Donations**
If you’d like to support financially, you can use the following wallet addresses:

- **Tron**: `TD3vY9Drpo3eLi8z2LtGT9Vp4ESuF2AEgo`  
- **USDT**: `UQAm3obHuD5kWf4eE4JmAO_5rkQdZPhaEpmRWs6Rk8vGQJog`  
- **TON**: `bc1qaquv5vg35ua7qnd3wlueytw0fugpn8qkkuq9r2`  
- **BTC**: `0x800680F566A394935547578bc5599D98B139Ea22`

Any contribution helps improve and continue the development of this project. Thank you for your support ❤️

---

## **License**
This project is released under the Apache license. You’re free to use or modify it. Please mention my name (Parsa) and include a link to the project.

![image](https://github.com/user-attachments/assets/d9519a74-0ae3-4c72-93e6-c74db024c294)


