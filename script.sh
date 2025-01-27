#!/bin/bash

echo -e "\033[1;32m                                                           "
echo -e "@@@@@@@   @@@@@@    @@@@@@                                 "
echo -e "@@@@@@@  @@@@@@@@  @@@@@@@@                                "
echo -e "  @@!    @@!  @@@  @@!  @@@                                "
echo -e "  !@!    !@!  @!@  !@!  @!@                                "
echo -e "  @!!    @!@!@!@!  @!@  !@!                                "
echo -e "  !!!    !!!@!!!!  !@!  !!!                                "
echo -e "  !!:    !!:  !!!  !!:!!:!:                                "
echo -e "  :!:    :!:  !:!  :!: :!:                                 "
echo -e "   ::    ::   :::  ::::: :!                                "
echo -e "   :      :   : :   : :  :::                               "
echo -e "@@@@@@@    @@@@@@    @@@@@@  @@@@@@@   @@@@@@   @@@  @@@   "
echo -e "@@@@@@@@  @@@@@@@@  @@@@@@@  @@@@@@@  @@@@@@@@  @@@@ @@@   "
echo -e "@@!  @@@  @@!  @@@  !@@        @@!    @@!  @@@  @@!@!@@@   "
echo -e "!@   @!@  !@!  @!@  !@!        !@!    !@!  @!@  !@!!@!@!   "
echo -e "@!@!@!@   @!@  !@!  !!@@!!     @!!    @!@!@!@!  @!@ !!@!   "
echo -e "!!!@!!!!  !@!  !!!   !!@!!!    !!!    !!!@!!!!  !@!  !!!   "
echo -e "!!:  !!!  !!:  !!!       !:!   !!:    !!:  !!!  !!:  !!!   "
echo -e ":!:  !:!  :!:  !:!      !:!    :!:    :!:  !:!  :!:  !:!   "
echo -e " :: ::::  ::::: ::  :::: ::     ::    ::   :::   ::   ::   "
echo -e ":: : ::    : :  :   :: : :      :      :   : :  ::    :    "
echo -e "                                                           \033[0m"

echo -e "\033[1;33m=========================================================="
echo -e "Created by Parsa in OPIran club https://t.me/OPIranClub"
echo -e "Love Iran :)"
echo -e "==========================================================\033[0m"

# Prompt the user before installing packages
read -p "Do you want to start installing packages? (yes/no): " start_install
if [[ "$start_install" != "yes" ]]; then
    echo "Canceled by user."
    exit 0
fi

function ask_yes_no() {
    local prompt="$1"
    local answer=""
    while true; do
        read -p "$prompt (yes/no): " answer
        if [[ "$answer" == "yes" || "$answer" == "no" ]]; then
            echo "$answer"
            break
        else
            echo -e "\033[1;31mOnly yes or no allowed.\033[0m"
        fi
    done
}

echo -e "\033[1;33mInstalling WireGuard (if not installed)...\033[0m"
sudo apt update
sudo apt install wireguard -y

read -p "Are you running this script on the IRAN server or the FOREIGN server? (IRAN/FOREIGN): " server_location

if [[ "$server_location" == "IRAN" || "$server_location" == "iran" ]]; then
    sudo mkdir -p /etc/wireguard
    cd /etc/wireguard
    umask 077

    if [ -f "wg_ir_private.key" ]; then
        echo -e "\033[1;32mExisting WireGuard keys found for IRAN server.\033[0m"
        IRAN_PRIV_KEY=$(cat wg_ir_private.key)
        IRAN_PUB_KEY=$(cat wg_ir_public.key)
        echo -e "\033[1;36mYour IRAN server public key is: \033[1;37m$IRAN_PUB_KEY\033[0m"
        echo -e "Skipping key generation..."
    else
        echo -e "\033[1;33mGenerating IRAN server private/public keys...\033[0m"
        wg genkey | tee wg_ir_private.key | wg pubkey > wg_ir_public.key
        IRAN_PRIV_KEY=$(cat wg_ir_private.key)
        IRAN_PUB_KEY=$(cat wg_ir_public.key)
        echo -e "\033[1;32mKeys generated.\033[0m"
        echo -e "\033[1;36mYour IRAN server public key is: \033[1;37m$IRAN_PUB_KEY\033[0m"
    fi

    read -p "Please enter the public IPv4 address of the IRAN server: " iran_ip
    read -p "Please enter the WireGuard port (default 51822): " wg_port
    wg_port=${wg_port:-51822}

    read -p "How many FOREIGN servers do you want to connect? " n_foreign
    declare -a foreign_ips
    declare -a foreign_pubs

    for (( i=1; i<=$n_foreign; i++ )); do
        read -p "Enter the public IPv4 of FOREIGN server #$i: " f_ip
        foreign_ips[i]=$f_ip
        read -p "Enter the PUBLIC KEY of FOREIGN server #$i: " f_pub
        foreign_pubs[i]=$f_pub
    done

    read -p "Please enter the MTU (default 1380): " mtu
    mtu=${mtu:-1380}

    echo -e "\033[1;33mCreating /etc/wireguard/TAQ-BOSTAN-wg.conf for IRAN server...\033[0m"
    sudo bash -c "cat > /etc/wireguard/TAQ-BOSTAN-wg.conf <<EOF
[Interface]
PrivateKey = $IRAN_PRIV_KEY
MTU = $mtu
Address = 2619:db8:85a3:1b2::1/64
ListenPort = $wg_port
EOF"

    count_even=2
    for (( i=1; i<=$n_foreign; i++ )); do
        sudo bash -c "cat >> /etc/wireguard/TAQ-BOSTAN-wg <<EOF

[Peer]
PublicKey = ${foreign_pubs[i]}
AllowedIPs = 2619:db8:85a3:1b2::${count_even}/128
Endpoint = ${foreign_ips[i]}:$wg_port
PersistentKeepalive = 20
EOF"
        count_even=$((count_even + 2))
    done

    sudo chmod 600 /etc/wireguard/TAQ-BOSTAN-wg.conf
    sudo wg-quick down TAQ-BOSTAN-wg 2>/dev/null
    sudo wg-quick up TAQ-BOSTAN-wg
    sudo systemctl enable wg-quick@TAQ-BOSTAN-wg

    echo -e "\033[1;32mWireGuard configuration for IRAN server is ready.\033[0m"
    echo -e "IRAN server public key: \033[1;37m${IRAN_PUB_KEY}\033[0m"
    echo -e "Local IPv6 for IRAN server: \033[1;37m2619:db8:85a3:1b2::1\033[0m"

    reboot_choice=$(ask_yes_no "Do you want to reboot the IRAN server now?")
    if [ "$reboot_choice" == "yes" ]; then
        sudo reboot
    else
        echo -e "\033[1;33mSetup complete. Reboot later if needed.\033[0m"
    fi

else
    sudo mkdir -p /etc/wireguard
    cd /etc/wireguard
    umask 077

    if [ -f "wg_for_private.key" ]; then
        echo -e "\033[1;32mExisting WireGuard keys found for FOREIGN server.\033[0m"
        FOR_PRIV_KEY=$(cat wg_for_private.key)
        FOR_PUB_KEY=$(cat wg_for_public.key)
        echo -e "\033[1;36mYour FOREIGN server public key is: \033[1;37m$FOR_PUB_KEY\033[0m"
        echo -e "Skipping key generation..."
    else
        echo -e "\033[1;33mGenerating FOREIGN server private/public keys...\033[0m"
        wg genkey | tee wg_for_private.key | wg pubkey > wg_for_public.key
        FOR_PRIV_KEY=$(cat wg_for_private.key)
        FOR_PUB_KEY=$(cat wg_for_public.key)
        echo -e "\033[1;32mKeys generated.\033[0m"
        echo -e "\033[1;36mYour FOREIGN server public key is: \033[1;37m$FOR_PUB_KEY\033[0m"
    fi

    read -p "Please enter the public IPv4 of this FOREIGN server: " foreign_ip
    read -p "Please enter the PUBLIC IPv4 of the IRAN server: " iran_ip
    read -p "Enter the PUBLIC KEY of IRAN server: " iran_pub
    read -p "Please enter the WireGuard port used by IRAN server (default 51822): " wg_port
    wg_port=${wg_port:-51822}

    read -p "Which number is this FOREIGN server? (1,2,3,...): " f_number
    local_even=$((2 * f_number))

    read -p "Please enter the MTU (default 1380): " mtu
    mtu=${mtu:-1380}

    echo -e "\033[1;33mCreating /etc/wireguard/TAQ-BOSTAN-wg.conf for FOREIGN server...\033[0m"
    sudo bash -c "cat > /etc/wireguard/TAQ-BOSTAN-wg.conf <<EOF
[Interface]
PrivateKey = $FOR_PRIV_KEY
MTU = $mtu
Address = 2619:db8:85a3:1b2::${local_even}/64
ListenPort = $wg_port

[Peer]
PublicKey = $iran_pub
AllowedIPs = 2619:db8:85a3:1b2::1/128
Endpoint = $iran_ip:$wg_port
PersistentKeepalive = 20
EOF"

    sudo chmod 600 /etc/wireguard/TAQ-BOSTAN-wg.conf
    sudo wg-quick down TAQ-BOSTAN-wg 2>/dev/null
    sudo wg-quick up TAQ-BOSTAN-wg
    sudo systemctl enable wg-quick@TAQ-BOSTAN-wg

    echo -e "\033[1;32mWireGuard setup on FOREIGN server completed.\033[0m"
    echo -e "FOREIGN server public key: \033[1;37m${FOR_PUB_KEY}\033[0m"
    echo -e "Local IPv6 for this FOREIGN server: \033[1;37m2619:db8:85a3:1b2::${local_even}\033[0m"

    reboot_choice=$(ask_yes_no "Do you want to reboot the FOREIGN server now?")
    if [ "$reboot_choice" == "yes" ]; then
        sudo reboot
    else
        echo -e "\033[1;33mSetup complete. Reboot later if needed.\033[0m"
    fi
fi
