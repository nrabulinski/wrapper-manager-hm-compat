{
  lib,
  config,
  ...
}: let
  defaultDirs = {
    cacheHome = "/home-manager-compat-cache";
    configHome = "/home-manager-compat-config";
    dataHome = "/home-manager-compat-data";
    stateHome = "/home-manager-compat-state";
  };
in {
  config = {
    assertions =
      (
        map
        (name: {
          assertion = config.xdg.${name} == defaultDirs.${name};
          message = ''
            Looks like you overwrote xdg.${name}.
            This will most certainly break the hm-compat module.
            Please don't change any xdg-related options.
          '';
        })
        (lib.attrNames defaultDirs)
      )
      ++ [
        {
          assertion = config.home.xdg.enable;
          message = ''
            Looks like you disabled xdg module.
            This will make it impossible for the hm-compat module to find config files for specific programs etc.
            Please don't change any xdg-related options.
          '';
        }
      ];

    xdg =
      {
        enable = true;
      }
      // defaultDirs;
  };
}
