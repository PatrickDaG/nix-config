# Meine wundervolle nix config  ❄️

[Structure](./STRUCTURE.md)


## Hosts
| | Name | Device | Description
---|---|---|---
💻 | patricknix | HP spectre x360 | Patrick's laptop, mainly used for on the go university
🖥️ | desktopnix | Intel i5-8600K <br> NVIDIA GeForce GTX 1080 <br> 32 GiB RAM | Patrick's desktop, used for most development and gaming
🖥️ | elisabeth | AMD Ryzen 7 5800X <br> 32 GiB RAM | Server running most cloud services
🖥️ | mailnix | Hetzner VPS | Static IP server running mail
🖥️ | torweg | Hetzner VPS | Static IP server running gatway services

## User Configuration
This showcases my end user setup, which I dailydrive on all my hosts.

| | Programm | Description
---|---|---
🐚 Shell | [ZSH](./users/common/shells/zsh/default.nix) & [Starship](./users/common/shells/starfish.nix) | ZSH with FZF autocomplete, starship prompt, sqlite history and histdb-skim for fancy reverse search
🪟 WM | [Hyprland](./users/patrick/wayland/hyprland.nix) | Tiling window manager
🖼️ Styling | [Stylix](./users/patrick/theme.nix) | globally consistent styling 
📝 Editor | [NeoVim](./users/patrick/programs/nvim/default.nix) | Extensively configured neovim
🎮 Gaming | [Bottles](./users/patrick/programs/bottles.nix) & [Steam](./users/patrick/programs/steam.nix) | Pew, Pew and such
🌐 Browser | [Firefox](./users/patrick/firefox.nix) | Heavily configured Firefox to still my privacy and security needs
💻 Terminal | [Kitty](./users/patrick/programs/kitty.nix) | fast terminal
🎵 Music | [Spotify](./users/patrick/programs/spicetify.nix) | Fancy looking spotify using spicetify
📫 Mail | [Thunderbird](./users/common/programs/thunderbird.nix) | Best email client there is

## Service Configuration
These are services I've set up

| | Programm | Description
---|---|---
💸 Budgeting | [FireflyIII](./config/services/firefly.nix) | Self Hosted budgeting tool
🛡️ AdBlock | [AdGuard Home](./config/services/adguardhome.nix) | DNS Adblocker
🔨 Git | [Forgejo](./config/services/forgejo.nix) | Selfhosted GitHub alternative
📸 Photos | [Immich](./config/services/immich.nix) | Selfhosted Google Photos equivalent
🔒 SSO | [Kanidm](./config/services/kanidm.nix) | Secure single sign on Identity Provider
📧 E-Mail | [Stalwart](./config/services/stalwart.nix) | All in one mail server
🎧 Communication | [Teamspeak](./config/services/murmur.nix) | Selfhosted teamspeak server for secure and always available communication
🌐 VPN | [Firezone](./config/services/firezone.nix) | Easy to use peer to peer VPN solution based on wireguard
🌧️ Cloud | [NextCloud](./config/services/nextcloud.nix) | All in one cloud solution providing online File storage as well as notes, contacts and calendar synchronization
🗄️ Documents | [Paperless](./config/services/paperless.nix) | Machine learnig supported document organizing plattform
📁 NAS | [Samba](./config/services/samba.nix) | Local network shared storage
📰 Feedreader | [freshRSS](./config/services/ttrss.nix) | hosted RSS feed aggregator
🔑 Passwords | [Vaultwarden](./config/services/vaultwarden.nix) | Self hosted bitwarden server
🎵 Music | [Your Spotify](./config/services/yourspotify.nix) | Spotify listening habits analyzer


## External dependencies
These are notable external flakes which this config depend upon

| Name | Usage |
---|---
[NixVim](https://github.com/nix-community/nixvim) | NeoVim using nix
[MicroVM](https://github.com/astro/microvm.nix) | Declarative VMs
[Disko](https://github.com/nix-community/disko)| disk partitioning
[nixos-generators](https://github.com/nix-community/nixos-generators) | generate installers
[home-manager](https://github.com/nix-community/home-manager) | user config
[agenix](https://github.com/ryantm/agenix) | secret files for nix
[agenix-rekey](https://github.com/oddlama/agenix-rekey) | secret files that are git commitable
[nixos-nftables-firewall](https://github.com/thelegy/nixos-nftables-firewall) | nftables based firewall
[impermanence](https://github.com/nix-community/impermanence) | stateless filesystem
[lanzaboote](https://github.com/nix-community/lanzaboote) | Secure Boot
[stylix](https://github.com/danth/stylix) | theming
[spicetify](https://github.com/Gerg-l/spicetify-nix) | spotify looking fancy



## How-To                                                                            PP-Bizon | Facility Sketch

### Add additional hosts

2. Create host configuration in `hosts/<name>`
    1. Create and fill `default.nix`
    1. Fill `net.nix`
    1. Fill `fs.nix`
    2. Don't forget to add necessary config for filesystems, etc.
3. Generate ISO image using `nix build --print-out-paths --no-link .#images.<target-system>.live-iso`
    - This might take multiple minutes(~10)
    - Alternatively boot an official nixos image connect with password
3. Copy ISO to usb using dd
3. After booting copy the installer to the live system using `nix copy --to <target> .#minimalConfigurations.<target-system>.config.system.build.installFromLive`
4. Run the installer script from the nix store of the live system
    - you can get the path using `nix path-info .#minimalConfigurations.<target-system>.config.system.build.installFromLive`
4. Export all zpools and reboot into system
6. Retrieve hostkeys using `ssh-keyscan <host> | grep -o 'ssh-ed25519.*' > host/<target>/secrets/host.pub`
5. Deploy system

### Add new services
1. Add service config to `config/services/<service>`
    1. Add Impermanence
    1. Add allowed ports
1. Add id to `ids.json`
2. Add UID to `config/basic/users.nix`
2. Add definitions to `globals.nix`
2. Add Container/VM to `hosts/<host>/guests.nix`
3. Run `agenix generate && agenix rekey`
4. Deploy system
5. Fetch ssh hostkey using `ssh-keyscan`
5. Rekey again `agenix rekey`
6. Deploy again

### Add secureboot to new systems

1. generate keys with `sbctl create-keys`
1. tar the resulting folder using `tar cvf secureboot.tar -C /var/lib/sbctl .`
1. Copy the tar to local using scp and encrypt it using rage
    - `rage -e -R ./secrets/recipients.txt secureboot.tar -o <host>/secrets/secureboot.tar.age`
1. safe the encrypted archive to `hosts/<host>/secrets/secureboot.tar.age`
1. *DO NOT* forget to delete the unecrypted archives
1. Deploy your system with lanzaboote enabled
1. ensure the boot files are signed using `sbctl verify`
1. Now reboot the computer into BIOS and enable secureboot,
    this may include removing any existing old keys
1. bootctl should now read `Secure Boot: disabled (setup)`
1. you can now enroll your secureboot keys using
1. `sbctl enroll-keys`
    If you want to be able to boot microsoft signed images append `--microsoft`
1. Time to reboot and pray

### Deploy from new host

If deploying from a host not containing the necessary nix configuration option append
```bash
--nix-option plugin-files "$NIX_PLUGINS"/lib/nix/plugins --nix-option extra-builtins-file ./nix/extra-builtins`
```
