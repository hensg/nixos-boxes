{ pkgs
, inputs
, ...
}:
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

  environment.systemPackages = with pkgs; [
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
    inputs.nixvim.packages.${system}.default
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
    chromium
    playerctl
    gparted
    nixfmt-rfc-style
    alacritty
    syncthing
    poetry
    (python3.withPackages (python-pkgs: [
      python-pkgs.pandas
      python-pkgs.requests
      python-pkgs.pyquery
    ]))
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
    wezterm
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

    gnome-extension-manager
    gnome.adwaita-icon-theme
    gnome.gnome-characters
    gnome.gnome-tweaks
    gnomeExtensions.mullvad-indicator
    gnomeExtensions.vitals
    gnomeExtensions.pano
    gnomeExtensions.krypto
    gnomeExtensions.dollar
    gnomeExtensions.weather
    gnomeExtensions.kube-config
    gnomeExtensions.spotify-tray
    gnomeExtensions.mic-monitor

    openssl

    obsidian

    ffmpeg

    spotify
    bitwarden-desktop
    firefox
    thunderbird
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

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "intl";
      };
      videoDrivers = [ "nvidia" ];

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
    noto-fonts-cjk
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
