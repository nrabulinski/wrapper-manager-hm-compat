{
  nixpkgs,
  home-manager,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  optionsPatch = {
    options.build = with lib; {
      toplevel = mkOption {readOnly = false;};
      packages = mkOption {readOnly = false;};
    };
  };
  libModule = {
    config.lib = lib.hm or {};
  };
  compatibleModules = [
    # Modules confirmed to work
    "programs/helix.nix"
    "programs/starship.nix"
    "programs/kitty.nix"

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

  # Copied from https://github.com/viperML/wrapper-manager/blob/master/modules/build.nix
  # and added showing assertions and warnings.
  build = let
    failedAssertions = map (x: x.message) (lib.filter (x: !x.assertion) config.assertions);
    build = {
      toplevel = pkgs.buildEnv {
        name = "wrapper-manager";
        paths = builtins.attrValues config.build.packages;
      };

      packages = builtins.mapAttrs (_: value: value.wrapped) config.wrappers;
    };
    buildWarn =
      if failedAssertions != []
      then throw "\nFailed assertions:\n${lib.concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
      else lib.showWarnings config.warnings build;
  in
    lib.mkForce buildWarn;

  warnings = lib.optional (!lib ? hm) ''
    The `lib` argument is not extended with home-manager methods,
    meaning you're probably using the legacy method by importing
    wrapper-manager-hm-compat.wrapperManagerModules.homeManagerCompat.
    This breaks some home-manager modules, so instead use
    ```
    wrapper-manager-hm-compat.lib {
      modules = [ ... ];
    }
    ```
    or
    ```
    wrapper-manager-hm-compat.lib.build {
      modules = [ ... ];
    }
    ```
    (the same api wrapper-manager exposes)
  '';

  home.stateVersion = lib.mkDefault "23.11";
  home.homeDirectory = "/home-manager-compat-home";
  home.username = "wrapper-manager-user";
  submoduleSupport.enable = true;
  nix.enable = lib.mkForce false;

  imports =
    [
      ./programs/helix.nix
      ./programs/starship.nix
      ./programs/kitty.nix
      ./misc/xdg.nix
      ./misc/lib.nix
      libModule
      optionsPatch

      "${nixpkgs}/nixos/modules/misc/assertions.nix"
      "${nixpkgs}/nixos/modules/misc/meta.nix"
    ]
    ++ hmModules;
}
