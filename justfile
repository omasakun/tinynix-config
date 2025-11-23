_default:
  @just --list --unsorted

# Update the flake inputs
update:
  nix flake update

# Validate the config
check:
  nix flake check

# Activate the new config
switch host=`hostname` *args:
  sudo nixos-rebuild switch --flake . ".#{{ host }}" {{ args }}

# Activate on next boot
switch-boot host=`hostname` *args:
  sudo nixos-rebuild boot --flake ".#{{ host }}" {{ args }}

# Edit the secrets
secrets:
  sops secrets.yaml
