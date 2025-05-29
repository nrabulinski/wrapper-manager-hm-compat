{
  # The eval function for wrapper-manager, not the flake or the path
  wrapper-manager,
  home-manager,
  nixpkgs ? null,
}: {
  pkgs,
  modules ? [],
  specialArgs ? {},
}: let
  nixpkgsPath =
    if nixpkgs == null
    then pkgs.path
    else nixpkgs;
  hmCompat = import ./modules {
    nixpkgs = nixpkgsPath;
    inherit home-manager;
  };
in
  wrapper-manager {
    inherit pkgs;
    modules = modules ++ [hmCompat];

    specialArgs =
      specialArgs
      // {
        lib = import "${home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib;
      };
  }
