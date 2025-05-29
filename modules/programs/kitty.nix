{
  config,
  lib,
  ...
}: let
  cfg = config.programs.kitty;
in {
  config = lib.mkIf cfg.enable {
    wrappers.kitty = {
      basePackage = cfg.package;
      env = {
        KITTY_CONFIG_DIRECTORY.value = config.lib.hm-compat.xdgConfigDir {name = "kitty";};
      };
    };
  };
}
