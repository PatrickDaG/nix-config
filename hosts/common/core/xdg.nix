{
  # XDG base spec
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    # xdg ninja recommendations
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    WINEPREFIX = "${XDG_DATA_HOME}/wine";
  };
}
