# https://nix-community.github.io/NixOS-WSL/how-to/nix-flakes.html

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    nixosConfigurations.tinynix = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        (
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            # === System ===
            system.stateVersion = "25.05";
            networking.hostName = "tinynix";

            # === Nix ===
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            # === WSL2  ===
            wsl = {
              enable = true;
              defaultUser = "user01";
              interop.includePath = false;
            };
            services.chrony.enable = lib.mkForce false;

            # === SOPS ===
            sops.age.keyFile = "/config/keys.txt";
            sops.defaultSopsFile = ./secrets.yaml;
            sops.secrets.user01-password.neededForUsers = true;

            # === Users ===
            users.defaultUserShell = pkgs.zsh;
            users.users.user01 = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              hashedPasswordFile = config.sops.secrets.user01-password.path;
            };

            # === Programs ===
            programs = {
              nix-ld.enable = true;
              git.enable = true;
              neovim = {
                enable = true;
                defaultEditor = true;
              };
              zsh.enable = true;
            };

            # === Home Manager ===
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
              users.user01 =
                { pkgs, ... }:
                {
                  home.stateVersion = "25.05";

                  # === SOPS ===
                  sops.age.keyFile = "/config/keys.txt";
                  sops.defaultSopsFile = ./secrets.yaml;
                  home.sessionVariables.SOPS_AGE_KEY_FILE = "/config/keys.txt";

                  sops.secrets.user01-secrets = {
                    mode = "0400";
                    path = "secrets.txt";
                  };

                  # === Packages ===
                  home.packages = with pkgs; [
                    age
                    sops
                    fd
                    htop
                    just
                    ncdu
                    ripgrep
                  ];
                };
            };
          }
        )
      ];
    };
  };
}
