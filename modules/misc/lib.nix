{
  config,
  lib,
  pkgs,
  ...
}: {
  options.lib = with lib;
    mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = ''
        This option allows modules to define helper functions,
        constants, etc.
      '';
    };

  config.lib.hm-compat = rec {
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
    collectFiles = {
      name ? "collected-files",
      # Files which should be symlinked
      files,
      # Root directory to put the files under
      root ? "",
      # Path prefix to strip from the files
      prefix ? "",
      # Extra arguments passed to runCommandLocal
      extraArgs ? {},
    }:
      pkgs.runCommandLocal name ({inherit root;} // extraArgs) ''
        mkdir -p "$out/$root"
        cd "$out/$root"

        function insertFile() {
          local source=$1
          local target=$2

          local targetDir=$(dirname "$target")

          mkdir -p "$targetDir"
          ln -s "$source" "$target"
        }

        ${with lib;
          concatStrings (
            mapAttrsToList (_: f: ''
              insertFile ${escapeShellArgs [
                (sourceStorePath f)
                (removePrefix prefix f.target)
              ]}
            '')
            files
          )}
      '';
    xdgConfigDir = {
      name,
      createDir ? false,
    }: let
      inherit (config.xdg) configHome;
      prefix = "${configHome}/${name}/";
      files =
        lib.filterAttrs
        (_: file: lib.hasPrefix prefix file.target && file.enable)
        config.home.file;
    in
      collectFiles {
        name = "${name}-config";
        inherit files prefix;
        root = lib.optionalString createDir name;
      };
  };
}
