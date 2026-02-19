{
  hm-all.home.shellAliases = {
    # Aliases
    # Yeah no shit the things in aliases.nix under config shellAliases are aliases
    l = "ls -lahF --group-directories-first --show-control-chars --quoting-style=escape --color=auto";
    ll = "ls -lahF --group-directories-first --show-control-chars --quoting-style=escape --color=auto";
    t = "tree -F --dirsfirst -L 2";
    tt = "tree -F --dirsfirst -L 3 --filelimit 16";
    ttt = "tree -F --dirsfirst -L 6 --filelimit 16";

    md = "mkdir";
    rmd = "rm -d";

    #what the fuck is going on here????
    cpr = "rsync -axHAWXS --numeric-ids --info=progress2";

    cp = "cp -vi";
    mv = "mv -vi";
    rm = "rm -I";
    chmod = "chmod -c --preserve-root";
    chown = "chown -c --preserve-root";

    ip = "ip --color";
    tmux = "tmux -2";
    rg = "rg -S";

    zf = "zathura --fork";
    flop = "poweroff"; # ???
    claudius = "claude";

    ltar = "tar --exclude=\"*/*/*\" -tvf";
    untar = "tar -xvf";
  };
}
