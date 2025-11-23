$Name = "tinynix"
$DownloadUrl = "https://github.com/nix-community/NixOS-WSL/releases/download/2505.7.0/nixos.wsl"

if (-not (Test-Path $WslFile)) {
  Invoke-WebRequest $DownloadUrl -OutFile $WslFile -UseBasicParsing
}

wsl --install --from-file nixos.wsl --name $Name

wsl -d $Name sudo mkdir /config
wsl -d $Name sudo chown nixos:users /config
wsl -d $Name nix-shell -p git --run 'git clone https://github.com/omasakun/tinynix-config /config'
wsl -d $Name nix-shell -p just --run 'just -f /config/justfile switch-boot tinynix'
wsl -t $Name
wsl -d $Name --user root exit
wsl -t $Name
