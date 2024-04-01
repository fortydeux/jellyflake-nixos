# jellyflake-nixos

This is a Jellyfin and Audiobookshelf homeserver done the Nix flake way on a RasPi 4, using Syncthing and Tailscale for syncing and connectivity. 

Can be installed over a fresh NixOS installation on a Raspberry Pi or other arm64 device without (much) modification.

For x86_64 system architecture settings will need to be modified and possibly some packages.

As with any Nix flake, make sure to use/generate your own hardware-configuration.nix before trying to build the configuration on your own machine. 
