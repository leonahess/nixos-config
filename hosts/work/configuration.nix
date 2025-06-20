# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1'';
  security.polkit.enable = true;

  networking.hostName = "8700K"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = false;
  programs.xwayland.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.brlaser ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.leluxlu = {
    isNormalUser = true;
    description = "Leona Lux Hess";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = (with pkgs; [
      firefox
      discord
      vivaldi
      obs-studio
      zoom-us
      spotify
      signal-desktop
      telegram-desktop
      slack
      nextcloud-client
      keepassxc
      libreoffice-fresh
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
      vlc
      plex-media-player
    ])
    ++
    (with pkgs-unstable; [
      jetbrains-toolbox
      standardnotes
      ssm-session-manager-plugin
      terraform
    ]);
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };

    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      "leluxlu" = import ./home.nix;
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9000;

  };

  services.prometheus.exporters.nvidia-gpu = {
    enable = true;
  };

  services.tailscale = {
    enable = true;
  };

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.1.0/24 --dport 9000:9000 -j nixos-fw-accept
    iptables -A nixos-fw -p udp --source 192.168.1.0/24 --dport 9000:9000 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --source 192.168.1.0/24 --dport 9835:9835 -j nixos-fw-accept
    iptables -A nixos-fw -p udp --source 192.168.1.0/24 --dport 9835:9835 -j nixos-fw-accept
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     btop
     git
     curl
     guake
     docker
     tailscale
     trayscale
     caligula
     docker-compose
     zsh
     zsh-z
     zsh-autosuggestions
     pwvucontrol
     intel-gpu-tools
     oh-my-zsh
     fzf
     jq
     ansible
     direnv
     envsubst
     zip
     gnome-tweaks
     awscli2
     awsebcli
     gnomeExtensions.appindicator
     gnomeExtensions.gtile
     prometheus-node-exporter
     python3
     nvtopPackages.full
     prometheus-nvidia-gpu-exporter
     binutils
     graphviz
     maven
     jdk21_headless
  ];

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # remove default gnome apps
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gedit # text editor
    #cheese # webcam tool
    gnome-music
    # gnome-terminal
    epiphany # web browser
    geary # email reader
    # evince # document viewer
    #gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
