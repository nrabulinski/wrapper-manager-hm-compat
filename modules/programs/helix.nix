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
        sourceStorePath = file: let
          sourcePath = toString file.source;
          sourceName = config.lib.strings.storeFileName (baseNameOf sourcePath);
        in
          if builtins.hasContext sourcePath
          then file.source
          else
            builtins.path {
              path = file.source;
              name = sourceName;
            };
        prefix = "/home-manager-compat-config/helix/";
        isHelixConfig = name: file: lib.hasPrefix prefix name && file.enable;
        helixFiles = lib.filterAttrs isHelixConfig config.home.file;
        configDir = pkgs.runCommandLocal "helix-config" {} ''
          mkdir -p "$out/helix"
          function insertFile() {
            local source=$1
            local target=$2

            ln -s $source "$out/helix/$target"
          }
          ${lib.concatStrings (
            lib.mapAttrsToList (_: f: ''
              insertFile ${lib.escapeShellArgs [
                (sourceStorePath f)
                (lib.removePrefix prefix f.target)
              ]}
            '')
            helixFiles
          )}
        '';
      in {
        XDG_CONFIG_HOME = configDir;
      };
    };
  };
}
