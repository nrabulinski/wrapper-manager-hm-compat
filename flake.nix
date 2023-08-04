{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.follows = "home-manager/nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: {
    wrapperManagerModules = rec {
      homeManagerCompat = import ./. {inherit nixpkgs home-manager;};
      default = homeManagerCompat;
    };

    formatter =
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.alejandra);
  };
}
