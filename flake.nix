{
  description = "Jellyfin Audiobookshelf Server Flake";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
  };

  outputs = { self, determinate, nixpkgs }@inputs: 
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
    		};
    	};
    };


}
