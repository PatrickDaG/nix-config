{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../starfish.nix
  ];

  # for zsh-histdb
  # TODO replace sqlite inplace with nix path
  home.packages = [pkgs.sqlite];

  # save history in xdg data home
  home.sessionVariables.HISTDB_FILE = "${config.xdg.dataHome}/zsh/history.db";

  # has to be enabled to support zsh reverse search
  programs.fzf.enable = true;

  programs.carapace = {
    enable = true;
    # this would source all completers sadly some are worse than the builtin completers
    enableZshIntegration = false;
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history = {
      extended = true;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      save = 1000000;
      share = false;
    };
    initExtra = builtins.readFile ./zshrc;
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      {
        # TODO change to separate packages
        name = "zsh-histdb";
        src = pkgs.stdenv.mkDerivation {
          name = "zsh-histdb";
          src = pkgs.fetchFromGitHub {
            owner = "larkery";
            repo = "zsh-histdb";
            rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
            hash = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
          };
          patchPhase = ''
            substituteInPlace "sqlite-history.zsh" "histdb-migrate" "histdb-merge" \
            --replace "sqlite3" "${pkgs.sqlite}/bin/sqlite3"
          '';
          installPhase = ''
            mkdir -p $out
            cp -r * $out
          '';
        };
      }
      {
        name = "zsh-histdb-skim";
        src = pkgs.rustPlatform.buildRustPackage rec {
          pname = "zsh-histd-skim";
          version = "0.8.6";
          buildInputs = [pkgs.sqlite];
          src = pkgs.fetchFromGitHub {
            owner = "m42e";
            repo = "zsh-histdb-skim";
            rev = "v${version}";
            hash = "sha256-lJ2kpIXPHE8qP0EBnLuyvatWMtepBobNAC09e7itGas=";
          };
          cargoHash = "sha256-BMy9Shy9KAx5+VbvH2WaA0wMFUNM5dqU/dssUNE1NWY=";
          postInstall = ''
            substituteInPlace zsh-histdb-skim-vendored.zsh \
            --replace "zsh-histdb-skim" "$out/bin/zsh-histdb-skim"
            cp zsh-histdb-skim-vendored.zsh $out/zsh-histdb-skim.plugin.zsh
          '';
        };
      }
    ];
  };
}
