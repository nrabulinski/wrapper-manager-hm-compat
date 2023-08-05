{
  pkgs,
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
      env = let
        inherit (config.lib.hm-compat) sourceStorePath collectFiles;
        inherit (config.xdg) configHome;
        prefix = "${configHome}/helix/";
        isHelixConfig = _: file: lib.hasPrefix prefix file.target && file.enable;
        files = lib.filterAttrs isHelixConfig config.home.file;
        configDir = collectFiles {
          name = "helix-config";
          inherit files prefix;
          root = "helix";
        };
      in {
        XDG_CONFIG_HOME = configDir;
      };
    };
  };
}
