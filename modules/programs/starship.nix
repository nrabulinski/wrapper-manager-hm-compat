{
  config,
  lib,
  ...
}: let
  cfg = config.programs.starship;
in {
  config = lib.mkIf cfg.enable {
    wrappers.starship = {
      basePackage = cfg.package;
      env = lib.mkIf (cfg.settings != {}) {
        STARSHIP_CONFIG.value =
          config.lib.hm-compat.sourceStorePath config.xdg.configFile."starship.toml";
      };
    };
  };
}
