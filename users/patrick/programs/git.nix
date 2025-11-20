{
  pkgs,
  lib,
  globals,
  ...
}:
let
  gf = lib.getExe (
    pkgs.writeShellApplication {
      name = "git-fixup-fzf";
      runtimeInputs = [
        pkgs.fzf
        pkgs.gnugrep
      ];
      text = ''
        if ! commit=$(set +o pipefail; git log --graph --color=always --format="%C(auto)%h%d %s %C(reset)%C(bold)%cr" "$@" \
          | fzf --ansi --multi --no-sort --reverse --print-query --expect=ctrl-d --toggle-sort=\`); then
          echo aborted
          exit 0
        fi

        sha=$(grep -o '^[^a-z0-9]*[a-z0-9]\{7\}[a-z0-9]*' <<< "$commit" | grep -o '[a-z0-9]\{7\}[a-z0-9]*')
        if [[ -z "$sha" ]]; then
          echo "Found no checksum for selected commit. Aborting."
          exit 1
        fi

        git fixup "$sha" "$@"
      '';
    }
  );
  learnSmartCard = lib.getExe (
    pkgs.writeShellApplication {
      name = "learnSmartCard";
      runtimeInputs = [
        pkgs.yubikey-manager
      ];
      text = ''
        UID_FILE="/run/yubikey/gpg-uid"
        if [ -f "$UID_FILE" ]; then
          args=()

          # remove the user we have gotten
          while [ $# -gt 0 ]; do
              arg=$1
              shift

              # Handle combined options ending with 'u' (e.g., -bsau)
              if [[ $arg == -* && ''${#arg} -gt 2 && ''${arg: -1} == "u" ]]; then
                  if [[ $# -gt 0 ]] && [[ "$1" == "patrick@${globals.domains.mail_public}" ]]; then
                      # Remove trailing 'u' from combined option
                      args+=("''${arg%?}")
                      shift  # Skip 'user'
                      continue
                  fi
              # Handle standalone '-u'
              elif [[ "$arg" == "-u" ]]; then
                  if [ $# -gt 0 ] && [ "$1" == "patrick@${globals.domains.mail_public}" ]; then
                      shift  # Skip 'patrick'
                      continue
                  fi
              fi

              # Keep argument if no match
              args+=("$arg")
          done

          GPGUID=$(cat $UID_FILE)

          exec gpg -u "$GPGUID" "''${args[@]}"
        fi
        exec gpg "$@"
      '';
    }
  );
in
{
  hm =
    { config, ... }:
    {
      home.packages = [
        # try for jujutsu
        pkgs.meld
      ];
      programs.jujutsu = {
        enable = true;
        settings = {
          revset-aliases = {
            "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
          };
          templates = {
            draft_commit_description = ''
              concat(
                coalesce(description, default_commit_description, "\n"),
                surround(
                  "\nJJ: This commit contains the following changes:\n", "",
                  indent("JJ:     ", diff.stat(72)),
                ),
                "\nJJ: ignore-rest\n",
                diff.git(),
              )
            '';
            # commit_trailers = ''
            #   format_signed_off_by_trailer(self)
            #   ++ if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))
            # '';
          };
          aliases = {
            tug = [
              "bookmark"
              "move"
              "--from"
              "closest_bookmark(@-)"
              "--to"
              "@-"
            ];
            l = [
              "log"
              "--limit"
              "15"
              "--revisions"
              "::"
            ];
            rebase-all = [
              "rebase"
              "--source"
              "all:roots(bookmarks(master)..bookmarks())"
              "--destination"
              "master"
            ];
            csp = [
              "util"
              "exec"
              "--"
              (lib.getExe (
                pkgs.writeShellApplication {
                  name = "jj-csp";
                  runtimeInputs = [ config.programs.jujutsu.package ];
                  text = ''
                    jj commit
                    jj tug
                    jj git push
                  '';
                }
              ))
            ];
          };
          signing = {
            # Only sign on push
            behavior = "drop";
            backend = "gpg";
            backends.gpg.program = learnSmartCard;
          };
          git = {
            sign-on-push = true;
            push-new-bookmarks = true;
          };
          ui = {
            default-command = "l";
            # Why no paginate if longer than a page??
            paginate = "never";
            diff-editor = ":builtin";
          };
          user = {
            email = "patrick@${globals.domains.mail_public}";
            name = "Patrick";
          };
        };
      };

      programs.gitui.enable = true;
      programs.difftastic = {
        enable = true;
        git.enable = true;
      };
      programs.git = {
        enable = true;
        lfs.enable = true;
        ignores = [ ".direnv" ];
        settings = {
          core.pager = "${pkgs.delta}/bin/delta";
          core.askpass = lib.getExe pkgs.pinentry-gnome3;
          user = {
            name = "Patrick";
            email = globals.accounts.email."1".address;
            #signingkey = globals.accounts.email."1".address;
          };
          sendemail.identity = globals.accounts.email."1".address;
          gpg.openpgp.program = learnSmartCard;
          delta = {
            hyperlinks = true;
            keep-plus-minus-markers = true;
            line-numbers = true;
            navigate = true;
            side-by-side = true;
            syntax-theme = "TwoDark";
            tabs = 4;
          };
          column.ui = "auto";
          branch.sort = "-committerdate";
          tag.sort = "version:refname";
          mergetool.prompt = true;
          merge.conflictstyle = "diff3";
          init.defaultBranch = "main";
          push.followTags = true;
          pull.ff = "only";
          pull.rebase = true;
          push.autoSetupRemote = true;
          fetch.prune = true;
          fetch.pruneTags = true;
          fetch.all = true;
          commit.verbose = true;
          rerere.enabled = true;
          rerere.autoupdate = true;
          rebase.autoSquash = true;
          rebase.autoStash = true;
          rebase.updateRefs = true;
          alias = {
            cs = "commit -v -S";
            s = "status";
            a = "add";
            p = "push";
            rebase = "rebase --gpg-sign";
            fixup = ''!f() { TARGET=$(git rev-parse "$1"); git commit --fixup=$TARGET ''${@:2} && EDITOR=true git rebase -i --gpg-sign --autostash --autosquash $TARGET^; }; f'';
            f = "!${gf}";
            crm = ''!git commit -v -S --edit --file "$(git rev-parse --git-dir)"/COMMIT_EDITMSG'';
          };
        };
        signing = {
          key = null;
          signByDefault = true;
        };
      };
    };
}
