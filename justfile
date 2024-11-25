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
    nixos-rebuild switch --flake .#{{FLAKE}} --target-host root@{{HOST}}

format-mailserver HOST: 
    just format {{HOST}} mailserver

update-mailserver HOST: 
    just update {{HOST}} mailserver

format-website HOST: 
    just format {{HOST}} website

update-website HOST: 
    just update {{HOST}} website
