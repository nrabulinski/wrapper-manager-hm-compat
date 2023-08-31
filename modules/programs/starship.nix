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
      env.STARSHIP_CONFIG =
        lib.mkIf
        (cfg.settings != {})
        (config.lib.hm-compat.sourceStorePath config.xdg.configFile."starship.toml");
    };
  };
}
