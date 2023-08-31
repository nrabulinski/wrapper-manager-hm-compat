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
    "programs/starship.nix"

    # TODO: For now only required to be present, hopefully will be compatible later
    "programs/bash.nix"
    "programs/zsh.nix"
    "programs/fish.nix"
    "programs/ion.nix"
    "programs/nushell.nix"
    "programs/autojump.nix"
    "programs/man.nix"
    "misc/fontconfig.nix"

    # Modules required for other HM modules
    "files.nix"
    "home-environment.nix"
    "systemd.nix"
    "misc/xdg.nix"
    "misc/version.nix"
    "misc/submodule-support.nix"
    "misc/nix.nix"
  ];
  hmModules = map (p: "${home-manager}/modules/${p}") compatibleModules;
in {
  _file = ./default.nix;

  home.stateVersion = lib.mkDefault "23.11";
  home.homeDirectory = "/home-manager-compat-home";
  home.username = "wrapper-manager-user";
  submoduleSupport.enable = true;
  nix.enable = lib.mkForce false;

  imports =
    [
      ./modules/programs/helix.nix
      ./modules/programs/starship.nix
      ./modules/misc/xdg.nix
      ./modules/misc/lib.nix
      libModule

      "${nixpkgs}/nixos/modules/misc/assertions.nix"
      "${nixpkgs}/nixos/modules/misc/meta.nix"
    ]
    ++ hmModules;
}
