# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

	# Aarch64 compilation
	# boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
	
	# Experimental features
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	
	# SWAP
	swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024;
  } ];

	# SWAP DISABLE
	#swapDevices = lib.mkForce [ ];


  # ENV VARS
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    TERM = "foot";
    TERMINAL = "foot";
    BROWSER = "firefox";
    VISUAL = "nvim";
		NIXOS_OZONE_WL = "1";
		ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

	#ld
	#programs.nix-ld.enable = true;
  #programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
		#aapt
    #gradle
		#clang
  #];

	# steam
	programs.steam = {
  	enable = true;
  	remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  	dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  	localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	};

	# firefox
	programs.firefox.enable = true;

	# hyprland
	programs.hyprland.enable = true;
	
	# adb
	programs.adb.enable = true;

  # Fish Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];

  # Nvim default
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = ''
        set number
        set tabstop=2
				set shiftwidth=2
      '';
    };
  };

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
			"i915.force_probe=!56a1"
			"xe.force_probe=56a1"
    ];
    consoleLogLevel = 0;
    # https://github.com/NixOS/nixpkgs/pull/108294
    initrd.verbose = false;
  };  

  networking.hostName = "pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.lightdm.enable = false;

  # Greeter
  # Run GreetD on TTY2
  services.greetd = {
    enable = true;
    vt = 7;
    settings = {
      default_session = {
        command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet --user-menu --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # MPD
  # services.mpd = {
  #  enable = true;
  #  musicDirectory = "/home/unclear/Musik";
  #  extraConfig = ''
  #    audio_output {
  #      type "pipewire"
  #      name "alsa_output.usb-Yamaha_Corporation_Steinberg_UR22mkII-00.analog-stereo"
  #  }
  #  '';
  #};

  #services.mpd.user = "cenk";
  #systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
  #  XDG_RUNTIME_DIR = "/run/user/1000"; # User-id 1000 must match above user. MPD will look inside this directory for the PipeWire socket.
  #};

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
    font-awesome
    meslo-lgs-nf
    ubuntu_font_family
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # XDG stuff

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable flatpak
  #services.flatpak.enable = true;

  # Enable gvfs (mount, trash...) for thunar
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

#  nixpkgs.overlays = [
#    (self: super: {
#      waybar = super.waybar.overrideAttrs (oldAttrs: {
#        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
#      });
#      mesa = super.mesa.overrideAttrs (oldAttrs: {
#				version = "24.3";
#        src = oldAttrs.src.override {
#    			rev = "b01d76027d39a24709185b5b6b7377806ca9457c";
#    			#hash = "sha256-KV0GGunouQ18UbyJEcTrlD4nftJBXNKNoG9VJpHLHU4=";
#  			 };	
# 		 });
#    })
#  ];

  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cenk = {
    isNormalUser = true;
    description = "Cenk";
    extraGroups = [ "networkmanager" "wheel" "mpd" "input" "adbusers" "kvm" "docker" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Latest Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # enable GameMode
  programs.gamemode.enable = true;

  # Wine Stuff (32bit)
  #hardware.opengl.enable = true;
  #hardware.opengl.driSupport = true;
  #hardware.opengl.driSupport32Bit = true;

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vaapiVdpau
		libvdpau-va-gl
  ];
  
	# For 32 bit applications 
  # Only available on unstable
  # hardware.opengl.extraPackages32 = with pkgs; [
    # driversi686Linux.vaapiIntel
  # ];
  
  # Enable virtualbox
  #virtualisation.virtualbox.host.enable = true;
  #users.extraGroups.vboxusers.members = [ "cenk" ];

	# Docker
	virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		yarn
		parted
		gparted
    wget
		minizip
    git
		git-lfs
    vulkan-tools
    vulkan-loader
    #godot_4
		#godot3
    foot
    adwaita-icon-theme
    waybar
    #xdg-desktop-portal
		#xdg-desktop-portal-hyprland
    grim
    slurp
    pipewire
    wireplumber
    pavucontrol
    xfce.thunar
    hyprpaper
		hyprcursor
    gnome-themes-extra
    vlc
    imv
    rofi-wayland
    ranger
    neofetch
    gamescope
    mpv
    mako
    p7zip
    unrar
    wl-clipboard
    brightnessctl
    killall
    playerctl
    mpc-cli
    unzip
    discord
    prismlauncher
    ffmpeg
    xarchiver
    obs-studio
    polkit
    polkit-kde-agent
		telegram-desktop
		jdk
		hugo
		audacity
		element-desktop
		shotcut
		#blender
		vscodium
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
