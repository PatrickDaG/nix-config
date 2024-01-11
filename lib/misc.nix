_inputs: _self: super: let
  writeText = text: (super.writeText (builtins.hashString "sha256" "${text}") "${text}");
in {
  lib =
    super.lib
    // {
      inherit
        writeText
        ;
    };
}
