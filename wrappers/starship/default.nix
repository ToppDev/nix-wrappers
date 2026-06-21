{...}: {
  flake.wrappers.starship = {
    wlib,
    lib,
    ...
  }: {
    imports = [wlib.wrapperModules.starship];

    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "\${custom.yazi}"
        "$character"
      ];
      right_format = lib.concatStrings [
        "$all"
      ];
      directory = {
        read_only = " 🔒";
      };
      cmake = {
        symbol = " ";
      };
      python = {
        symbol = " ";
      };

      custom.yazi = {
        # See https://github.com/Sonico98/yazi-prompt.sh
        description = "Indicate when the shell was launched by `yazi`";
        symbol = " ";
        when = ''test -n "$YAZI_LEVEL" '';
      };
    };
  };
}
