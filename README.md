# Meine wundervolle nix config  ❄️

[Structure](./STRUCTURE.md)


## Hosts
| | Name | Device | Description
---|---|---|---
💻 | patricknix | HP spectre x360 | Patrick's laptop, mainly used for on the go university
🖥️ | desktopnix | Intel i5-8600K <br> NVIDIA GeForce GTX 1080 <br> 32 GiB RAM | Patrick's desktop, used for most development and gaming
🖥️ | elisabeth | AMD Ryzen 7 5800X <br> 32 GiB RAM | Server running most cloud services
🖥️ | maddy | Hetzner VPS | Static IP server running mail
💻 | gojo | ? |Simons Laptop

## User Configuration
This showcases my end user setup, which I dailydrive on all my hosts.

| | Programm | Description
---|---|---
🐚 Shell | [ZSH](./users/common/shells/zsh/default.nix) & [Starship](./users/common/shells/starfish.nix) | ZSH with FZF autocomplete, starship prompt, sqlite history and histdb-skim for fancy reverse search
🪟 WM | [Sway](./users/common/graphical/wayland/sway.nix) & [i3](./users/common/graphical/Xorg/i3.nix) | Tiling window managers with similar behaviour for wayland and xorg
🖼️ Styling | [Stylix](./modules/graphical/default.nix) | globally consistent styling 
📝 Editor | [NeoVim](./users/common/programs/nvim/default.nix) | Extensively configured neovim
🎮 Gaming | [Bottles](./users/common/programs/bottles.nix) & [Steam](./modules/optional/steam.nix) | Pew, Pew and such
🌐 Browser | [Firefox](./users/patrick/firefox.nix) | Heavily configured Firefox to still my privacy and security needs
💻 Terminal | [Kitty](./users/common/programs/kitty.nix) | fast terminal
🎵 Music | [Spotify](./users/common/programs/spicetify.nix) | Fancy looking spotify using spicetify
📫 Mail | [Thunderbird](./users/common/programs/thunderbird.nix) | Best email client there is
🎛️ StreamDeck | [StreamDeck](./users/patrick/streamdeck.nix) | More hotkeys = more better

## Service Configuration
These are services I've set up

| | Programm | Description
---|---|---
💸 Budgeting | [FireflyIII](./config/services/firefly.nix) | Self Hosted budgeting tool
🛡️ AdBlock | [AdGuard Home](./config/services/adguardhome.nix) | DNS Adblocker
🔨 Git | [Forgejo](./config/services/forgejo.nix) | Selfhosted GitHub alternative
📸 Photos | [Immich](./config/services/immich.nix) | Selfhosted Google Photos equivalent
🔒 SSO | [Kanidm](./config/services/kanidm.nix) | Secure single sign on Identity Provider
📧 E-Mail | [Maddy](./config/services/maddy.nix) | All in one mail server
🎧 Communication | [Murmur](./config/services/murmur.nix) | Selfhosted mumble server for secure and always available communication
🌐 VPN | [Netbird](./config/services/netbird.nix) | Easy to use peer to peer VPN solution based on wireguard
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
[spicetify](https://github.com/the-argus/spicetify-nix) | spotify looking fancy



## How-To

### Add additional hosts

1. Add host definition to `hosts.toml`
2. Create host configuration in `hosts/<name>`
    1. Create and fill `default.nix`
    1. Fill `net.nix`
    1. Fill `fs.nix`
    2. Don't forget to add necessary config for filesystems, etc.
3. Generate ISO image using `nix build --print-out-paths --no-link .#images.<target-system>.live-iso`
    - This might take multiple minutes(~10)
    - Alternatively boot an official nixos image connect with password
3. Copy ISO to usb using dd
3. After booting copy the installer to the live system using `nix copy --to <target> .#packages.<target-system>.installer-package.<target>`
4. Run the installer script from the nix store of the live system
    - you can get the path using `nix path-info .#packages.<target-system>.installer-package.<target>`
4. Export all zpools and reboot into system
6. Retrieve hostkeys using `ssh-keyscan <host> | grep -o 'ssh-ed25519.*' > host/<target>/secrets/host.pub`
5. Deploy system

### Add secureboot to new systems

1. generate keys with `sbct create-keys`
1. tar the resulting folder using `tar cvf secureboot.tar -C /etc/secureboot .`
1. Copy the tar to local using scp and encrypt it using rage
    - `rage -e -R ./secrets/recipients.txt secureboot.tar -o <host>/secrets/secureboot.tar.age`
1. safe the encrypted archive to `hosts/<host>/secrets/secureboot.tar.age`
1. *DO NOT* forget to delete the unecrypted archives
1. Deploy your system with lanzaboote enabled
    - link `/run/secureboot` to `/etc/secureboot`
    - This is necesarry since for your this apply the rekeyed keys are not yet available but already needed for signing the boot files
1. ensure the boot files are signed using `sbctl verify`
1. Now reboot the computer into BIOS and enable secureboot,
    this may include removing any existing old keys
1. bootctl should now read `Secure Boot: disabled (setup)`
1. you can now enroll your secureboot keys using
1. `sbctl enroll-keys`
    If you want to be able to boot microsoft signed images append `--microsoft`
1. Time to reboot and pray

### Add luks encryption TPM keys

`systemd-cryptenroll --tpm2-with-pin={yes/no} --tpm2-device=auto <device>`


### Deploy from new host

If deploying from a host not containing the necessary nix configuration option append
```bash
--nix-option plugin-files "$NIX_PLUGINS"/lib/nix/plugins --nix-option extra-builtins-file ./nix/extra-builtins`
```
