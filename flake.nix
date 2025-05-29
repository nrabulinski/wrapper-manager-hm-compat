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
    homeManagerCompat = import ./modules {inherit nixpkgs home-manager;};
    eval = {
      pkgs,
      modules ? [],
      specialArgs ? {},
    }:
      wrapper-manager.lib {
        inherit pkgs;
        modules = modules ++ [homeManagerCompat];
        specialArgs =
          specialArgs
          // {
            lib = import "${home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib;
          };
      };
  in {
    lib = {
      inherit eval;
      __functor = _: eval;
      build = args: (eval args).config.build.toplevel;
    };

    wrapperManagerModules = rec {
      inherit homeManagerCompat;
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
