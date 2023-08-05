{
  nixpkgs,
  home-manager,
}: {
  pkgs,
  lib,
  ...
}: let
  extendedLib = import "${home-manager}/modules/lib/stdlib-extended.nix" lib;
  libModule = {
    config.lib = extendedLib.hm;
  };
  compatibleModules = [
    # Modules confirmed to work
    "programs/helix.nix"

    # Modules required for other HM modules
    "files.nix"
    "home-environment.nix"
    "systemd.nix"
    "programs/bash.nix"
    "programs/zsh.nix"
    "programs/fish.nix"
    "programs/autojump.nix"
    "programs/man.nix"
    "misc/xdg.nix"
    "misc/version.nix"
  ];
  hmModules = map (p: "${home-manager}/modules/${p}") compatibleModules;
in {
  _file = ./default.nix;

  home.stateVersion = lib.mkDefault "23.11";
  home.homeDirectory = "/home-manager-compat-home";
  home.username = "wrapper-manager-user";

  imports =
    [
      ./modules/programs/helix.nix
      ./modules/misc/xdg.nix
      ./modules/misc/lib.nix
      libModule

      "${nixpkgs}/nixos/modules/misc/assertions.nix"
      "${nixpkgs}/nixos/modules/misc/meta.nix"
    ]
    ++ hmModules;
}
