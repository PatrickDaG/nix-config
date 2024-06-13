{pkgs, ...}: {
  home.packages = [pkgs.pwndbg];
  home.enableDebugInfo = true;
  xdg.configFile.gdbinit = {
    target = "gdb/gbdinit";
    text = ''
      set auto-load safe-path /
      set debuginfod enabled on

      set history save on
      set history filename ~/.local/share/gdb/history

      set disassembly-flavor intel
      set print pretty on
    '';
  };

  home.persistence."/state".directories = [
    ".local/share/gdb"
  ];
}
