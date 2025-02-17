{
  #services.nixseparatedebuginfod.enable = true;
  hm = {
    home.enableDebugInfo = true;
    xdg.configFile.gdbinit = {
      target = "gdb/gdbinit";
      text = ''
        set debuginfod enabled on
        set auto-load safe-path /

        set history save on
        set history filename ~/.local/share/gdb/history

        set disassembly-flavor intel
        set print pretty on
      '';
    };

    home.persistence."/state".directories = [ ".local/share/gdb" ];
  };
}
