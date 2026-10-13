{
  globals,
  lib,
  pkgs,
  ...
}:
let
  learnSmartCard = lib.getExe (
    pkgs.writeShellApplication {
      name = "learnSmartCard";
      runtimeInputs = [ pkgs.yubikey-manager ];
      text = ''
        UID_FILE="/run/yubikey/gpg-uid"
        if [ -f "$UID_FILE" ]; then
          args=()

          while [ $# -gt 0 ]; do
            arg=$1
            shift

            if [[ $arg == -* && ''${#arg} -gt 2 && ''${arg: -1} == "u" ]]; then
              if [[ $# -gt 0 ]] && [[ "$1" == "patrick@${globals.domains.mail_public}" ]]; then
                args+=("''${arg%?}")
                shift
                continue
              fi
            elif [[ "$arg" == "-u" ]]; then
              if [ $# -gt 0 ] && [ "$1" == "patrick@${globals.domains.mail_public}" ]; then
                shift
                continue
              fi
            fi

            args+=("$arg")
          done

          GPGUID=$(cat "$UID_FILE")
          exec gpg -u "$GPGUID" "''${args[@]}"
        fi
        exec gpg "$@"
      '';
    }
  );
in
{
  hm = {
    programs.jujutsu.settings = {
      signing = {
        behavior = "drop";
        backend = "gpg";
        backends.gpg.program = learnSmartCard;
      };
      git.sign-on-push = true;
    };

    programs.git = {
      signing = {
        format = "openpgp";
        key = null;
        signByDefault = true;
      };
      settings = {
        gpg.openpgp.program = learnSmartCard;
        alias = {
          cs = lib.mkForce "commit -v -S";
          rebase = "rebase --gpg-sign";
          fixup = lib.mkForce ''!f() { TARGET=$(git rev-parse "$1"); git commit --fixup=$TARGET ''${@:2} && EDITOR=true git rebase -i --gpg-sign --autostash --autosquash $TARGET^; }; f'';
          crm = lib.mkForce ''!git commit -v -S --edit --file "$(git rev-parse --git-dir)"/COMMIT_EDITMSG'';
        };
      };
    };
  };
}
