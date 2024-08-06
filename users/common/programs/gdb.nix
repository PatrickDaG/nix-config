{ pkgs, ... }:
let
  pwndbgWithDebuginfod =
    (pkgs.pwndbg.override { gdb = pkgs.gdb.override { enableDebuginfod = true; }; }).overrideAttrs
      (
        _finalAttrs: previousAttrs: {
          installPhase =
            previousAttrs.installPhase
            + ''
              ln -s $out/bin/pwndbg $out/bin/gdb
            '';
        }
      );
in
{
  home.packages = [ pwndbgWithDebuginfod ];
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
}
