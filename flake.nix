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
            pkgs,
            ...
          }:
          {
            # === System ===
            system.stateVersion = "25.05";
            networking.hostName = "tinynix";

            # === Nix ===
            nix.settings = {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              substituters = [
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
            };

            # === WSL2  ===
            wsl = {
              enable = true;
              defaultUser = "user01";
              interop.includePath = false;
            };

            # TODO: remove this workaround when the next WSL2 image is released.
            # https://github.com/nix-community/NixOS-WSL/issues/854
            services.chrony.servers = [ ];

            # === SOPS ===
            sops.age.keyFile = "/config/keys.txt";
            sops.defaultSopsFile = ./secrets.yaml;

            # === Users ===
            users.defaultUserShell = pkgs.zsh;

            sops.secrets.user01-password.neededForUsers = true;
            users.users.user01 = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              hashedPasswordFile = config.sops.secrets.user01-password.path;
            };

            # === Programs ===
            programs = {
              nix-ld.enable = true;
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

                  # === Programs ===
                  home.packages = with pkgs; [
                    age
                    sops
                    fd
                    htop
                    just
                    ncdu
                    ripgrep
                  ];
                  programs = {
                    zsh = {
                      enable = true;
                      enableVteIntegration = true;
                      autosuggestion.enable = true;
                      syntaxHighlighting.enable = true;
                    };
                    git = {
                      enable = true;
                      lfs.enable = true;
                      settings = {
                        init.defaultBranch = "main";
                      };
                    };
                  };
                };
            };
          }
        )
      ];
    };
  };
}
