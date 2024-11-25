{
  description = "Personal website for Sebastian";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    utils.url = "github:numtide/flake-utils";

    hugo-paper = {
      url = "github:adityatelange/hugo-PaperMod";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, utils, ... }:
    utils.lib.eachSystem [
      utils.lib.system.x86_64-linux
    ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        rec {

          packages.website = pkgs.stdenv.mkDerivation {
            name = "website";
            src = self;
            buildInputs = [ pkgs.git pkgs.nodePackages.prettier ];
            buildPhase = '' 
              echo "Running hugo"
              ln -s ${inputs.hugo-paper} themes/PaperMod
              ${pkgs.hugo}/bin/hugo --baseURL https://hensg.dev --logLevel info --cleanDestinationDir
            '';
            installPhase = ''
              cp -r dist $out
            '';
          };

          packages.default = packages.website;

          apps = rec {
            hugo = utils.lib.mkApp { drv = pkgs.hugo; };
            default = hugo;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [ pkgs.git pkgs.nixpkgs-fmt pkgs.hugo ];
          };
        });
}
