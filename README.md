# NixOS WSL Setup

A small single-file NixOS WSL setup.

Setup is based on
[NixOS-WSL](https://github.com/nix-community/NixOS-WSL),
[Home Manager](https://github.com/nix-community/home-manager) and
[SOPS-Nix](https://github.com/Mic92/sops-nix).

## Setup

Run the following commands in Windows PowerShell to install:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/omasakun/tinynix-config/refs/heads/main/setup.ps1 -UseBasicParsing | Invoke-Expression
```

Or manually run the following commands:

```bash
# windows powershell
curl -L https://github.com/nix-community/NixOS-WSL/releases/download/2505.7.0/nixos.wsl -o nixos.wsl
wsl --install --from-file nixos.wsl --name tinynix

# inside nixos
sudo mkdir /config
sudo chown $USER:users /config
nix-shell -p git just
git clone https://github.com/omasakun/tinynix-config /config
just -f /config/justfile switch-boot tinynix

# exit and back to windows powershell
wsl -t tinynix
wsl -d tinynix --user root exit # apply changes
wsl -t tinynix
```

The default password for the user `user01` is `password`.

## Useful Commands

```bash
# list registry
nix registry list

# run without installing
nix run nixpkgs#neofetch

# search packages
nix search nixpkgs wget

# generate age key
age-keygen -o keys.txt

# create password hash
mkpasswd -s
```

## Resources

- [Package Search](https://search.nixos.org/packages?channel=unstable)
- [Options Search](https://search.nixos.org/options?channel=unstable)
- [Options Search (Home Manager)](https://home-manager-options.extranix.com/?release=master)
- [Official Docs](https://nix.dev/)
- [Unofficial Wiki](https://nixos.wiki/wiki/WSL)
- [NixOS WSL Docs](https://nix-community.github.io/NixOS-WSL/index.html)
- [NixOS WSL GitHub](https://github.com/nix-community/NixOS-WSL)
- [Home Manager with Flakes](https://home-manager.dev/manual/24.11/index.xhtml#ch-nix-flakes)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/introduction/)

## License

This project is licensed under [Zero-Clause BSD](LICENSE).

No attribution required. Do whatever you want with it.
