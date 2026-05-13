#!/bin/sh
# Setup script for kali-anonymous on modern Kali Linux (systemd)

printf "\n"
printf "ANONYMOUS SETUP FOR KALI LINUX (MODERN / SYSTEMD)\n"
printf "\n"

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
    printf "[!] Please run as root: sudo ./setup.sh\n"
    exit 1
fi

# Check we're in the right directory
if [ ! -f "./anonymous" ]; then
    printf "[!] Cannot find the 'anonymous' file in the current directory.\n"
    printf "    Make sure you run this script from inside the kali-anonymous folder.\n"
    exit 1
fi

printf "[*] Updating package list...\n\n"
apt-get update || { printf "[!] apt-get update failed\n"; exit 1; }
printf "\n[+] Package list updated!\n\n"

# Install Tor if not already installed
if ! command -v tor >/dev/null 2>&1; then
    printf "[*] Tor not found. Installing...\n"
    apt-get install -y tor || { printf "[!] Failed to install tor\n"; exit 1; }
else
    printf "[+] Tor is already installed.\n"
fi

# Install macchanger if not already installed
if ! command -v macchanger >/dev/null 2>&1; then
    printf "[*] macchanger not found. Installing...\n"
    apt-get install -y macchanger || { printf "[!] Failed to install macchanger\n"; exit 1; }
else
    printf "[+] macchanger is already installed.\n"
fi

# Install curl if not already installed (needed for status check)
if ! command -v curl >/dev/null 2>&1; then
    printf "[*] curl not found. Installing...\n"
    apt-get install -y curl || { printf "[!] Failed to install curl\n"; exit 1; }
else
    printf "[+] curl is already installed.\n"
fi

# Ensure iproute2 is installed
printf "[*] Ensuring iproute2 is installed...\n"
apt-get install -y iproute2 || { printf "[!] Failed to install iproute2\n"; exit 1; }
printf "[+] iproute2 OK.\n\n"

# Add required Tor config entries (only if not already present)
printf "[*] Checking Tor configuration...\n"
TORRC="/etc/tor/torrc"

if [ ! -f "$TORRC" ]; then
    printf "[!] Tor config file not found at %s\n" "$TORRC"
    exit 1
fi

grep -q 'VirtualAddrNetwork 10.192.0.0/10' "$TORRC" || echo 'VirtualAddrNetwork 10.192.0.0/10' >> "$TORRC"
grep -q 'TransPort 9040'                   "$TORRC" || echo 'TransPort 9040'                   >> "$TORRC"
grep -q 'DNSPort 53'                       "$TORRC" || echo 'DNSPort 53'                       >> "$TORRC"
grep -q 'AutomapHostsOnResolve 1'          "$TORRC" || echo 'AutomapHostsOnResolve 1'          >> "$TORRC"

printf "[+] Tor configuration updated.\n\n"

# Enable and start Tor via systemd
printf "[*] Enabling Tor service...\n"
systemctl enable tor 2>/dev/null || printf "[!] Could not enable tor service (non-fatal)\n"
systemctl restart tor 2>/dev/null || { printf "[!] Failed to start tor\n"; exit 1; }
printf "[+] Tor service running.\n\n"

# Copy the main script
printf "[*] Installing anonymous to /usr/sbin/anonymous...\n"
cp ./anonymous /usr/sbin/anonymous || { printf "[!] Failed to copy anonymous script\n"; exit 1; }
chmod 755 /usr/sbin/anonymous
printf "[+] Done.\n\n"

# Copy default config file if it exists, otherwise create a minimal one
if [ -f "./kali-anonymous" ]; then
    printf "[*] Installing config to /etc/default/kali-anonymous...\n"
    cp ./kali-anonymous /etc/default/kali-anonymous
    printf "[+] Done.\n\n"
else
    printf "[*] No config file found, creating default at /etc/default/kali-anonymous...\n"
    cat > /etc/default/kali-anonymous <<'EOF'
# kali-anonymous default configuration
# Edit this file to customise behaviour

# Networks that bypass Tor (local subnets)
NON_TOR="192.168.0.0/16 172.16.0.0/12"

# UID that Tor runs as
TOR_UID="debian-tor"

# Tor transparent proxy port
TRANS_PORT="9040"

# Processes to kill on start/stop
TO_KILL="chrome chromium dropbox firefox pidgin skype thunderbird xchat"

# BleachBit cleaners to run on stop
BLEACHBIT_CLEANERS="bash.history system.cache system.clipboard system.custom system.recent_documents system.rotated_logs system.tmp system.trash"

# Overwrite files when cleaning (true/false)
OVERWRITE="true"

# Default hostname to restore when stopping
REAL_HOSTNAME="kali"
EOF
    printf "[+] Default config created.\n\n"
fi

printf "============================================\n"
printf " Install complete!\n"
printf "============================================\n"
printf " START:  sudo anonymous start\n"
printf " STOP:   sudo anonymous stop\n"
printf " STATUS: sudo anonymous status\n"
printf " UPDATE: sudo anonymous update\n"
printf "============================================\n"
printf " Report bugs: https://github.com/MardoxTV/Kali-Anonymous/issues\n\n"
