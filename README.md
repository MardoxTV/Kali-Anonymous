# kali-anonymous

```
                  _   __      _ _           ___  
                 | | / /     | (_)         / _ \                                                   
                 | |/ /  __ _| |_  ______ / /_\ \_ __   ___  _ __  _   _ _ __ ___   ___  _   _ ___ 
                 |    \ / _` | | | ______ |  _  | '_ \ / _ \| '_ \| | | | '_ ` _ \ / _ \| | | / __|
                 | |\  \ (_| | | |        | | | | | | | (_) | | | | |_| | | | | | | (_) | |_| \__ \
                 \_| \_/\__,_|_|_|        \_| |_/_| |_|\___/|_| |_|\__, |_| |_| |_|\___/ \__,_|___/
                                                                 __/ |                          
                                                                |___/   
```

The `anonymous` script from ParrotSec and BackBox, updated to run on modern Kali Linux (systemd).

---

## Supported platforms

**Kali Linux** (Rolling) — uses `systemd`, `iproute2`, and `systemd-resolved`.

Other Debian-based distros may work but are not officially supported.

---

## What does it do?

When started, `anonymous` helps reduce common identity leaks by optionally performing the following steps:

- **Kills leaky processes** — terminates browsers, chat clients, and other apps that may leak identity (Firefox, Chromium, Skype, Pidgin, Thunderbird, etc.)
- **Spoofs your MAC address** — uses `macchanger` to assign a random MAC address to a chosen network interface
- **Changes your hostname** — replaces your system hostname with a random word from the dictionary (or one you specify)
- **Routes all traffic through Tor** — sets up `iptables` rules to transparently redirect all TCP traffic and DNS queries through the Tor network, so no application-level configuration is needed

When stopped, it reverses all of the above: restores `iptables` rules, restores `systemd-resolved` and `resolv.conf`, lets you reset your MAC address and hostname, and optionally runs BleachBit to clean up traces left on disk.

---

## Requirements

- Kali Linux (modern, systemd-based)
- `tor`
- `macchanger`
- `iproute2` (usually pre-installed)
- `bleachbit` (optional, used during `stop` to clean up files)
- Root / sudo access

---

## Installation

Clone the repository and run the setup script:

```bash
git clone https://github.com/keeganjk/kali-anonymous
cd kali-anonymous
chmod +x setup.sh
sudo ./setup.sh
```

The setup script will:

1. Update your package list
2. Optionally install `tor` and `macchanger`
3. Ensure `iproute2` is installed
4. Add the required Tor configuration entries to `/etc/tor/torrc`:
   - `VirtualAddrNetwork 10.192.0.0/10`
   - `TransPort 9040`
   - `DNSPort 53`
   - `AutomapHostsOnResolve 1`
5. Enable and start the Tor systemd service
6. Copy the `anonymous` script to `/usr/sbin/anonymous` and the config file to `/etc/default/kali-anonymous`

---

## Usage

All commands require root:

| Command | Description |
|---|---|
| `sudo anonymous start` | Start anonymous mode (interactive — prompts for MAC/hostname/Tor) |
| `sudo anonymous stop` | Stop anonymous mode and restore your system |
| `sudo anonymous status` | Show current MAC addresses, hostname, public IP, and Tor status |
| `sudo anonymous update` | Pull and reinstall the latest version from GitHub |

### Starting anonymous mode

```bash
sudo anonymous start
```

You will be prompted interactively:

1. **Change MAC address?** — Select a network interface from the list shown; a random MAC will be assigned.
2. **Change hostname?** — Press Enter for a random hostname, or type one of your choice.
3. **Route traffic through Tor?** — Sets up iptables rules to transparently send all traffic through Tor.

### Stopping anonymous mode

```bash
sudo anonymous stop
```

This will:

- Flush the Tor iptables rules and restore your saved rules
- Restart `systemd-resolved` and restore `/etc/resolv.conf`
- Prompt you to restore or change your MAC address
- Prompt you to restore or change your hostname
- Optionally run BleachBit to delete browser history, caches, temp files, and other traces

### Checking status

```bash
sudo anonymous status
```

Displays:
- Current MAC address for each network interface
- Current hostname
- Current public IP address
- Whether traffic is currently going through Tor

---

## Configuration

You can customise settings by editing `/etc/default/kali-anonymous`:

```sh
# Networks that bypass Tor (local subnets)
NON_TOR="192.168.0.0/16 172.16.0.0/12"

# UID that Tor runs as
TOR_UID="debian-tor"

# Tor transparent proxy port
TRANS_PORT="9040"

# Processes to kill on start/stop
TO_KILL="chrome chromium dropbox firefox pidgin skype thunderbird xchat"

# BleachBit cleaners to run on stop
BLEACHBIT_CLEANERS="bash.history system.cache system.clipboard ..."

# Whether to overwrite files (vs just delete)
OVERWRITE="true"

# Default hostname to restore on stop
REAL_HOSTNAME="kali"
```

---

## Notes

- Tor must be running before traffic can be routed through it. If it isn't, `anonymous start` will attempt to start it automatically.
- MAC address spoofing does not work inside virtual machines.
- This tool reduces common leaks but **does not guarantee anonymity**. Your behaviour matters — avoid logging into personal accounts, enabling JavaScript on untrusted sites, etc.

---

## License

GNU Affero General Public License v3.0 — see [LICENSE](LICENSE) for details.

---

## Bugs / Issues

Report bugs at: https://github.com/keeganjk/kali-anonymous/issues
