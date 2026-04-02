{
  writeShellApplication,
  git,
}:
writeShellApplication {
  name = "git-dirty";
  runtimeInputs = [
    git
  ];
  text = ''
    ROOT_DIR="''${1:-$HOME/repos}"

    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    GREEN='\033[0;32m'
    BOLD='\033[1m'
    RESET='\033[0m'

    check_repo() {
      local repo="$1"
      local issues=()

      cd "$repo"

      if ! git diff --cached --quiet 2>/dev/null; then
        issues+=("staged but uncommitted changes")
      fi

      if ! git diff --quiet 2>/dev/null; then
        issues+=("unstaged modifications")
      fi

      if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
        issues+=("untracked files")
      fi

      if [[ -n $(git stash list 2>/dev/null) ]]; then
        issues+=("stashed changes")
      fi

      local unpushed_branches=()
      while IFS= read -r branch; do
        [[ -z "$branch" ]] && continue
        local upstream
        upstream=$(git rev-parse --abbrev-ref "''${branch}@{upstream}" 2>/dev/null) || continue
        local ahead
        ahead=$(git rev-list --count "''${upstream}..''${branch}" 2>/dev/null) || continue
        if [[ "$ahead" -gt 0 ]]; then
          unpushed_branches+=("''${branch} (''${ahead} ahead)")
        fi
      done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

      if [[ ''${#unpushed_branches[@]} -gt 0 ]]; then
        issues+=("unpushed commits: $(IFS=', '; echo "''${unpushed_branches[*]}")")
      fi

      local no_upstream=()
      while IFS= read -r branch; do
        [[ -z "$branch" ]] && continue
        if ! git rev-parse --abbrev-ref "''${branch}@{upstream}" &>/dev/null; then
          no_upstream+=("$branch")
        fi
      done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

      if [[ ''${#no_upstream[@]} -gt 0 ]]; then
        issues+=("branches without upstream: $(IFS=', '; echo "''${no_upstream[*]}")")
      fi

      if [[ ''${#issues[@]} -gt 0 ]]; then
        echo -e "''${RED}''${BOLD}✗ ''${repo}''${RESET}"
        for issue in "''${issues[@]}"; do
          echo -e "  ''${YELLOW}→ ''${issue}''${RESET}"
        done
        return 1
      fi

      return 0
    }

    find_and_check() {
      local dir="$1"
      local dirty=0
      local clean=0
      local total=0

      while IFS= read -r gitdir; do
        repo="$(dirname "$gitdir")"
        total=$((total + 1))
        if ! check_repo "$repo"; then
          dirty=$((dirty + 1))
        else
          clean=$((clean + 1))
        fi
      done < <(find "$dir" -name .git -type d 2>/dev/null | sort)

      echo ""
      echo -e "''${BOLD}Summary:''${RESET} ''${total} repos scanned, ''${GREEN}''${clean} clean''${RESET}, ''${RED}''${dirty} with unpublished changes''${RESET}"
    }

    if [[ ! -d "$ROOT_DIR" ]]; then
      echo "Error: directory '$ROOT_DIR' does not exist" >&2
      exit 1
    fi

    echo -e "''${BOLD}Scanning for git repos under ''${ROOT_DIR}...''${RESET}"
    echo ""
    find_and_check "$ROOT_DIR"
  '';
}
