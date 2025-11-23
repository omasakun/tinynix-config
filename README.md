# NixOS WSL Setup

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
