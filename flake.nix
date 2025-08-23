{
  description = "Jellyfin Audiobookshelf Server Flake";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
  };

  outputs = { self, determinate, nixpkgs, nixpkgs-unstable }@inputs: 
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
            determinate.nixosModules.default
    			];
          specialArgs = {
            unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
          };
    		};
    	};
    };


}
