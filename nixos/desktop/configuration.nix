{ pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./bitcoin.nix
    ./yubikey-gpg.nix
    ./backups.nix
    ./networking.nix
    ./audio.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.tailscale.enable = false;

  environment.systemPackages = with pkgs; [
    davinci-resolve
    perl
    flamegraph
    jemalloc
    krita
    xournalpp
    inkscape
    gh
    lsof
    nethogs
    iw
    gtop
    iotop
    libwacom
    wacomtablet
    cachix
    ollama
    cudatoolkit
    libGLU
    libGL
    libva
    vdpauinfo
    woeusb
    xsensors
    mission-center
    deluge
    terraform
    packer
    k9s
    inetutils
    tcpdump
    ghostscript
    pdftk
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        wlrobs
        obs-mute-filter
        input-overlay
        obs-gstreamer
        obs-vkcapture
        obs-nvfbc
        obs-backgroundremoval
      ];
    })
    okular
    sops
    mpv
    nvme-cli
    vlc
    v4l-utils
    guvcview
    webcamoid

    # vim stuff
    unstable.neovim
    unstable.rust-analyzer
    unstable.nixd
    #unstable.pyright
    unstable.pylyzer
    unstable.ruff
    unstable.black
    unstable.yamlfmt
    unstable.yaml-language-server
    unstable.lua
    unstable.lua-language-server
    #inputs.nixvim.packages.${system}.default

    unstable.vscode-extensions.vadimcn.vscode-lldb
    poetry
    (python3.withPackages (python-pkgs: [
      python-pkgs.pandas
      python-pkgs.requests
      python-pkgs.pyquery
      python-pkgs.debugpy
      python-pkgs.python-lsp-server
      python-pkgs.python-lsp-ruff
      python-pkgs.python-lsp-black
      python-pkgs.pyls-isort
    ]))

    unstable.atuin
    jq
    mdadm
    tmux
    anki
    yarn
    parallel
    xorg.xrandr
    lxappearance
    polybar
    openssl
    unstable.chromium
    google-chrome
    vivaldi
    playerctl
    gparted
    nixfmt-rfc-style
    alacritty
    syncthing
    clipman
    pamixer
    nh
    pwgen
    just
    gamemode
    pavucontrol
    vulkan-headers
    vulkan-tools
    kitty
    dig
    duf
    pciutils
    file
    gnumake
    gcc13
    clang
    lshw
    conky
    btop
    #wezterm
    inputs.wezterm-flake.packages."${system}".default
    unstable.blesh
    unstable.sqlite
    wget
    curl
    cron
    git
    xclip
    unzip

    thinkfan
    lm_sensors

    starship
    zoxide
    fzf
    ripgrep
    fd
    bat
    direnv

    statix
    clang
    gcc
    zig
    rustup
    unstable.luarocks
    go
    nodejs_22
    jdk
    jre
    terraform

    gimp

    killall

    cryptsetup

    glxinfo
    mesa
    libGL
    libGLU

    capitaine-cursors
    variety
    gnome-solanum
    gnome-extension-manager
    gnome-characters
    gnome-tweaks
    gnome-backgrounds
    unstable.papirus-icon-theme
    unstable.arc-theme
    unstable.whitesur-gtk-theme
    adwaita-icon-theme
    gsettings-desktop-schemas
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.just-perfection
    gnomeExtensions.mullvad-indicator
    gnomeExtensions.pano
    gnomeExtensions.krypto
    gnomeExtensions.freon
    gnomeExtensions.vitals
    gnomeExtensions.astra-monitor
    gnomeExtensions.spotify-tray

    openssl

    unstable.obsidian

    ffmpeg

    spotify
    bitwarden-desktop
    unstable.firefox
    unstable.thunderbird
    discord
    zoom-us

    tor
    tor-browser
    unstable.sparrow

    appimage-run
    docker
    docker-compose
    kubectl

    dbeaver-bin
    dumbpipe

    nixpkgs-fmt
  ];

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "henrique" ];

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "intl";
      };
      videoDrivers = [ "nvidia" "modesettings" ];

      # desktopManager = {
      #   xterm.enable = false;
      # };
      # displayManager = {
      #   defaultSession = "none+i3";
      # };
      # windowManager.i3 = {
      #   enable = true;
      #   extraPackages = with pkgs; [
      #     dmenu
      #     i3status
      #     i3lock
      #   ];
      # };
      displayManager = {
        gdm = {
          enable = true;
          wayland = false;
        };
      };
      desktopManager.gnome.enable = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    optimise = {
      automatic = true;
      dates = [ "11:50" ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "henrique"
        "root"
      ];
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us-acentos";
  time.timeZone = "America/Sao_Paulo";

  security.rtkit.enable = true;

  users.users.henrique = {
    isNormalUser = true;
    description = "Henrique Goulart";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "kvm"
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
      ];
    })
  ];

  environment.variables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    EDITOR = "nvim";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
