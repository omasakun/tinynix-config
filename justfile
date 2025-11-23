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

# Start a Nix REPL
repl:
  nix repl -f flake:nixpkgs

# Show profile versions
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Delete old versions
wipe-history target="--older-than 7d":
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  {{ target }}
