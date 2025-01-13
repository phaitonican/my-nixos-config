# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # React native expo go ports
  networking.firewall.allowedTCPPorts = [ 8081 ];
  networking.firewall.allowedUDPPorts = [ 8081 ];

  # cosmic shutdown fix
  services.geoclue2.enable = true;

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
	
  # SWAP
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024;
  } ];

  # SWAP DISABLE
  #swapDevices = lib.mkForce [ ];
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # ENV VARS
  environment.sessionVariables = {
    GDK_BACKEND="wayland";
    QT_QPA_PLATFORM="wayland";
    MOZ_ENABLE_WAYLAND = "1";
    TERM = "foot";
    TERMINAL = "foot";
    BROWSER = "firefox";
    VISUAL = "hx";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    LIBVA_DRIVER_NAME = "iHD";
    EDITOR = "hx";
    COSMIC_DATA_CONTROL_ENABLED = 1;
  };
	
  # steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # firefox
  programs.firefox.enable = true;
	
  # adb
  programs.adb.enable = true;

  # Fish Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  
  # Silent boot
  boot = { 
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      #"i915.force_probe=!56a1"
      #"xe.force_probe=56a1"
    ];
    consoleLogLevel = 0;
    # https://github.com/NixOS/nixpkgs/pull/108294
    initrd.verbose = false;
  };  

  # host name
  networking.hostName = "pc"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.utf8";

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # starship
  programs.starship.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
    font-awesome
    meslo-lgs-nf
    ubuntu_font_family
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono 
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cenk = {
    isNormalUser = true;
    description = "Cenk";
    extraGroups = [ "networkmanager" "wheel" "mpd" "input" "adbusers" "kvm" "docker" "audio" ];
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Latest Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # enable GameMode
  programs.gamemode.enable = true;

  # enable Gamescope
  programs.gamescope.enable = true;
	
  # intel graphics stuff (accel...)
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
	
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
    vpl-gpu-rt
    intel-compute-runtime
  ];
  
  # Docker
  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    yarn
    parted
    gparted
    wget
    minizip
    git
    git-lfs
    vulkan-tools
    vulkan-loader
    pipewire
    wireplumber
    fastfetch
    mpv
    p7zip
    unrar
    wl-clipboard
    brightnessctl
    killall
    unzip
    discord-canary
    prismlauncher
    ffmpeg
    xarchiver
    obs-studio
    jdk
    element-desktop
    rkdeveloptool
    qemu
    blender    
    nix-your-shell
    gimp
    inkscape
    nixd
    nil
    chromium
    
    #rust based tools
    zed-editor
    helix
    fractal
    oculante
    lsd
    rip2
    #spacedrive
    ouch
    sudo-rs
    zoxide
    mission-center
    starship
    #appflowy
    #warp-terminal
    airshipper
    kondo
    fd
    systeroid
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
