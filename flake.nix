{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      #url = "github:hensg/nixvim";
      url = "path:///home/henrique/Projects/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko.url = "github:nix-community/disko";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    hugo-site.url = "./nixos/website/hensg.dev/";
  };

  outputs =
    inputs@{ nixpkgs
    , nixpkgs-unstable
    , flake-utils
    , nixvim
    , disko
    , sops-nix
    , nix-bitcoin
    , simple-nixos-mailserver
    , hugo-site
    , ...
    }:
    let
      boxesSystem = flake-utils.lib.system.x86_64-linux;
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = boxesSystem;
          config.allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = boxesSystem;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            { nixpkgs.overlays = [ overlay-unstable ]; }
            nix-bitcoin.nixosModules.default
            disko.nixosModules.disko
            ./nixos/desktop/configuration.nix
          ];
        };

        mailserver = nixpkgs.lib.nixosSystem {
          system = boxesSystem;
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            simple-nixos-mailserver.nixosModules.default
            ./nixos/mailserver/configuration.nix
          ];
        };

        website = nixpkgs.lib.nixosSystem
          {
            system = boxesSystem;
            specialArgs = {
              system = boxesSystem;
              inherit inputs hugo-site;
            };
            modules = [
              disko.nixosModules.disko
              ./nixos/website/configuration.nix
            ];
          };
      };
    } //
    flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    {
      devShell = pkgs.mkShell {
        sopsPGPKeyDirs = [
          "./sopsKeys/"
        ];
        nativeBuildInputs = [
          (pkgs.callPackage sops-nix { }).sops-import-keys-hook
        ];
        buildInputs = with pkgs; [
          rsync
          hugo
          just
        ];
      };
    }
    );
}
