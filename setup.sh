#!/bin/sh
# Setup script for kali-anonymous on modern Kali Linux (systemd)

printf "\n"
printf "ANONYMOUS SETUP FOR KALI LINUX (MODERN / SYSTEMD)\n"
printf "\n"

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
    printf "[!] Please run as root\n"
    exit 1
fi

printf "[*] Updating package list ...\n\n"
apt update
printf "\n[+] Package list updated!\n\n"

# Install Tor if needed
read -p "Is Tor installed on this computer? [Y/n] (N if unsure) > " tor_ans
case $tor_ans in
    [Nn]* ) apt install tor -y ;;
    [Yy]* ) ;;
    *     ) printf "Unrecognised input, skipping Tor install.\n" ;;
esac

# Install macchanger if needed
read -p "Is macchanger installed? [Y/n] (N if unsure) > " mac_ans
case $mac_ans in
    [Nn]* ) apt install macchanger -y ;;
    [Yy]* ) ;;
    *     ) printf "Unrecognised input, skipping macchanger install.\n" ;;
esac

# Install iproute2 (provides ip command) — usually already present
printf "[*] Ensuring iproute2 is installed...\n"
apt install -y iproute2

# Add required Tor config entries (only if not already present)
printf "\n[.] Checking Tor configuration...\n"
TORRC="/etc/tor/torrc"

grep -q 'VirtualAddrNetwork 10.192.0.0/10' "$TORRC" || echo 'VirtualAddrNetwork 10.192.0.0/10' >> "$TORRC"
grep -q 'TransPort 9040'                   "$TORRC" || echo 'TransPort 9040'                   >> "$TORRC"
grep -q 'DNSPort 53'                       "$TORRC" || echo 'DNSPort 53'                       >> "$TORRC"
grep -q 'AutomapHostsOnResolve 1'          "$TORRC" || echo 'AutomapHostsOnResolve 1'          >> "$TORRC"

printf "[*] Tor configuration updated.\n\n"

# Enable and start Tor via systemd
printf "[.] Enabling Tor service via systemd...\n"
systemctl enable tor
systemctl start tor
printf "[*] Tor service enabled and started.\n\n"

# Copy script files
printf "[.] Copying files to designated locations...\n"
cp anonymous /usr/sbin/anonymous
cp kali-anonymous /etc/default/kali-anonymous
printf "[*] Done!\n\n"

printf "[.] Setting permissions...\n"
chmod +x /usr/sbin/anonymous
printf "[*] Done!\n\n"

printf "Install complete!\n"
printf "------------------------------\n"
printf "START:  sudo anonymous start\n"
printf "STOP:   sudo anonymous stop\n"
printf "STATUS: sudo anonymous status\n"
printf "UPDATE: sudo anonymous update\n"
printf "------------------------------\n"
printf "Report bugs to https://github.com/keeganjk/kali-anonymous/issues\n\n"
