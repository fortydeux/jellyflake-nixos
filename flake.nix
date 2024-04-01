{
  description = "Jellyfin Audiobookshelf Server Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let 
      lib = nixpkgs.lib;
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in 
    {
    	nixosConfigurations = {
    		jellyshelf-nixos = lib.nixosSystem {
    			inherit system;
    			modules = [
    				./configuration.nix
    			];
    		};
    	};
    };


}
