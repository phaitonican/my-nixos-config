# NixOS system configuration for host "nixos".
#
# Sections:
#   1. Core system      - Nix, boot, networking, locale, users
#   2. Desktop          - COSMIC, fonts, audio, session environment
#   3. Hardware & AI    - Intel graphics, Ollama
#   4. Programs         - shell, browser, gaming, virtualisation
#   5. System packages
#   6. Disabled options - alternatives kept for reference

{ pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ------------------------------------------------------------------
  # 1. Core system
  # ------------------------------------------------------------------

  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # Run unpatched dynamically linked binaries (AppImages, downloaded tools).
  programs.nix-ld.enable = true;

  # Memory-safe sudo implementation (replaces the default sudo).
  security.sudo-rs.enable = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "splash"
    "vga=current"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "kvm.enable_virt_at_load=0"
    "i915.enable_guc=3"
    # "i915.force_probe=!56a1"
    # "xe.force_probe=56a1"
  ];

  # 16 GiB swap file.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 8081 ];

  # Time and locale
  time.timeZone = "Europe/Berlin";
  time.hardwareClockInLocalTime = true; # dual-boot with Windows
  i18n.defaultLocale = "de_DE.UTF-8";
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

  # Keyboard
  console.keyMap = "de";
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Users
  users.users.cenk = {
    isNormalUser = true;
    description = "Cenk";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "input"
      "kvm"
      "docker"
      "mpd"
      "adbusers"
    ];
  };

  # Printing
  services.printing.enable = true;

  # ------------------------------------------------------------------
  # 2. Desktop
  # ------------------------------------------------------------------

  # COSMIC desktop
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  services.geoclue2.enable = true; # fixes COSMIC shutdown

  # Session-wide environment variables, Wayland first.
  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # Default applications
    BROWSER = "firefox";
    EDITOR = "hx";
    VISUAL = "hx";

    # Intel media / Level Zero
    LIBVA_DRIVER_NAME = "iHD";
    ZET_ENABLE_PROGRAM_DEBUGGING = "0";

    # COSMIC
    XCURSOR_THEME = "Adwaita";
    COSMIC_DATA_CONTROL_ENABLED = "1";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
    font-awesome
    meslo-lgs-nf
    ubuntu-classic
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # Audio (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ------------------------------------------------------------------
  # 3. Hardware & AI
  # ------------------------------------------------------------------

  # Intel graphics: VA-API, OpenCL, Level Zero and Vulkan.
  # Mesa is already provided by hardware.graphics; listing mesa (or the
  # deprecated mesa.drivers) in extraPackages is redundant.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      vpl-gpu-rt
      libvdpau-va-gl
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # Ollama with Vulkan acceleration.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    environmentVariables = {
      # Make the system graphics drivers visible to Ollama.
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
      # Force the Vulkan backend.
      OLLAMA_LLM_LIBRARY = "vulkan";
    };
  };

  # ------------------------------------------------------------------
  # 4. Programs
  # ------------------------------------------------------------------

  # Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];
  programs.starship.enable = true;

  # Browser
  programs.firefox.enable = true;

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # Virtualisation
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.docker.enable = true;
  users.groups.libvirtd.members = [ "cenk" ];

  # ------------------------------------------------------------------
  # 5. System packages
  # ------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # CLI and system utilities
    fastfetch
    killall
    lsd
    fd
    rip2
    ouch
    zoxide
    parted
    gparted
    wget
    git
    git-lfs
    unzip
    minizip
    p7zip
    unrar
    xarchiver
    wl-clipboard
    brightnessctl
    systeroid
    intel-gpu-tools
    nix-your-shell
    kondo

    # Editors and development
    helix
    zed-editor
    nixd
    nil
    nixfmt
    claude-code
    opencode

    # Media and graphics
    blender
    gimp
    inkscape
    shotcut
    vlc
    obs-studio
    oculante
    vulkan-tools

    # Browsers and communication
    chromium
    discord-canary
    element-desktop
    fractal

    # Games
    airshipper

    # System monitoring
    mission-center
  ];

  # ------------------------------------------------------------------
  # State
  # ------------------------------------------------------------------

  system.stateVersion = "25.11";

  # ------------------------------------------------------------------
  # 6. Disabled / alternative options (kept for reference)
  # ------------------------------------------------------------------

  # Disable the swap file above:
  # swapDevices = lib.mkForce [ ];

  # GNOME instead of COSMIC:
  # services.xserver = {
  #   enable = true;
  #   displayManager.gdm.enable = true;
  #   desktopManager.gnome = {
  #     enable = true;
  #     extraGSettingsOverridePackages = [ pkgs.mutter ];
  #     extraGSettingsOverrides = ''
  #       [org.gnome.mutter]
  #       experimental-features=['variable-refresh-rate']
  #     '';
  #   };
  #   xkb.layout = "de,de";
  # };
  #
  # environment.gnome.excludePackages = with pkgs; [
  #   atomix
  #   cheese
  #   epiphany
  #   evince
  #   geary
  #   gedit
  #   gnome-characters
  #   gnome-music
  #   gnome-photos
  #   gnome-terminal
  #   gnome-tour
  #   hitori
  #   iagno
  #   tali
  # ];

  # VirtualBox instead of libvirt:
  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "cenk" ];

  # ADB:
  # programs.adb.enable = true;

  # Packages not currently installed:
  # yarn, mpv, prismlauncher, ffmpeg, jdk, rkdeveloptool, tor-browser, qemu,
  # tiled, gnome-tweaks, papers, showtime, dconf-editor, spacedrive,
  # appflowy, warp-terminal
}
