{
  config,
  lib,
  ...
}: let
  cfg = config.programs.helix;
in {
  config = lib.mkIf cfg.enable {
    wrappers.helix = {
      basePackage = cfg.package;
      # Need to override XDG_CONFIG_HOME instead of using an argument since helix also reads .config/languages.toml
      # which home-manager allows us to populate.
      env = {
        XDG_CONFIG_HOME = {
          value = config.lib.hm-compat.xdgConfigDir {
            name = "helix";
            createDir = true;
          };
          force = true;
        };
      };
    };
  };
}
