default:
    @just --list

format HOST FLAKE:
    #!/usr/bin/env bash
    echo "Are you sure you want to format the server at {{HOST}} with the flake {{FLAKE}}? [y/N]"
    read -r CONFIRMATION
    if [[ "$CONFIRMATION" == "y" ]]; then
      nix run github:nix-community/nixos-anywhere -- --flake .#{{FLAKE}} root@{{HOST}}
    else
      echo "Aborted."
    fi 

update HOST FLAKE:
    nix run nixpkgs#nixos-rebuild -- switch --flake .#{{FLAKE}} --target-host root@{{HOST}}

format-mailserver:
    just format mail.hensg.dev mailserver

update-mailserver:
    just update mail.hensg.dev mailserver

format-website:
    just format hensg.dev website

update-website:
    just update hensg.dev website
