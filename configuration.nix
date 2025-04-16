# This is a custom NixOS config for a small home-media server
# The configuration was originally made for a Raspberry Pi 4
# Some tweaking may be necessary or beneficial for other machines
# Always make sure to generate your own hardware config before trying
# to build this (or any) NixOS config.

# The basic idea of this config is that it enables the following services:
#   -Jellyfin - Media server for Movies, TV, Music, and more
#   -Audiobookshelf - Audiobook & Podcast server
#   -Syncthing - Sync your media files from wherever you have them primarily stored
#       up to custom folders on this server
#       *Note: I have also added a custom mount in this config for a dedicated media HDD/SSD
#   -Tailscale - Tailscale is a mesh VPN that will provide an easy and secure way to access 
#       all your media from this server while on-the-go, and can even be used to share your media 
#       with friends and family members (Both Jellyfin and Audiobookshelf support multiple user accounts)


# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Hardware - enables resdistributable firmware for Raspberry Pi and adds OpenGL packages for transcoding
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
  	enable = true; 
  	extraPackages = with pkgs; [
  		vaapiVdpau
  		libvdpau-va-gl
  	#	intel-media-driver #Not available for aarm64 architecture
  	#	intel-compute-runtime #Not available for aarm64 architecture  
 	];
  };

  # Mounting external HD/SSD that will contain all media
  # I have media drive structure set up something like this:
  #
  # Media
  #  |
  #  |
  #  -Audiobookshelf
  #        |
  #        -Audiobooks
  #        |
  #        -Podcasts
  #        |
  #        -eBooks
  #   |
  #   |
  #   -Jellyfin
  #      |
  #      -Videos
  #         |
  #         -Films
  #         |
  #         -TV Series
  #      |
  #      -Music
  #
  # There are many ways you could set this up, but I am pushing media to this little server using Syncthing
  #  (see Syncthing configuration below)
  # This way I can have a more "daily driver" or "always-on" computer with decent storage capacity OR that with access 
  #  to a NAS or storage service such as Dropbox or pCloud (wherever I want to store the primary copies of all my media files)
  #  this way I can drop files into my primary storage at will, and Syncthing on the daily-driver or always-on computer will regularly
  #  scan for new files and push them up to this media server.
  fileSystems."/run/media/fortydeux/Jellyshelf-media" = { 
    device = "/dev/disk/by-label/Jellyshelf-media";
    fsType = "ext4";
  };

  # Enable Nix Flakes 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader settings - will likely need to be changed for a different device
  boot = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  	loader.grub.enable = false;
    # Enables the generation of /boot/extlinux/extlinux.conf - for Raspberry Pi
  	loader.generic-extlinux-compatible.enable = true;
  #	kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
  };

  # Network settings
  networking.hostName = "jellyshelf-nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
   time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    displayManager.lightdm.enable = false;
    desktopManager.lxqt.enable = true;
  };
  services.displayManager.defaultSession = "none";
  
  # Shell - ZSH setup
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Optimise nix storage
  nix.optimise.automatic = true;
  # nix.settings.auto-optimise-store = true;

  # Environment variables
  environment.sessionVariables = {
    VISUAL = "hx"; # Sets preferred editor as default visual editor
    EDITOR = "hx"; # Sets preferred editor as default editor
  };
  
  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fortydeux = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.bash;
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # General tools
    alacritty
    duf
    fd
    git
    gh
    helix
    neovim 
    nnn
    micro
    ranger
    ripgrep
    wget
    yazi
    zellij
    
    # Jellyfin
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    
    #Raspberry Pi packages
    libraspberrypi
    raspberrypi-eeprom
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # List services that you want to enable:
  
  # Syncthing
  services.syncthing = {
  	enable = true;
  	openDefaultPorts = true; 
  	guiAddress = "0.0.0.0:8384"; # Allows access from other computers on network, not just localhost/127.0.0.1
  };

  # Jellyfin
  services.jellyfin = {
  	enable = true;
  	openFirewall = true;
    group = "syncthing";
  };

  # Audiobookshelf
  services.audiobookshelf = {
  	enable = true;
  	openFirewall = true;
  	port = 8234;
  	host = "0.0.0.0"; # Allows access from other computers on network, not just localhost/127.0.0.1
  	user = "fortydeux";
  };

  # Tailscale
  services.tailscale = {
    enable = true; 
    openFirewall = true;		
  };
  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8384 8234 ]; # Opens firewall ports for Syncthing and Audiobookshelf
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

