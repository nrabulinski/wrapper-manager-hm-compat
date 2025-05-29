{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.follows = "home-manager/nixpkgs";
    wrapper-manager.url = "github:viperML/wrapper-manager";
    wrapper-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    wrapper-manager,
    ...
  }: let
    eval = import ./. {
      inherit nixpkgs home-manager;
      wrapper-manager = wrapper-manager.lib;
    };
  in {
    lib = {
      inherit eval;
      __functor = _: eval;
      build = args: (eval args).config.build.toplevel;
    };

    wrapperManagerModules = rec {
      homeManagerCompat = import ./modules {inherit nixpkgs home-manager;};
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
