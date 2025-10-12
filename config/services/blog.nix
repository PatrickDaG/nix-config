{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let
  prestart = pkgs.writeShellScript "blog-pre" ''
    if [ ! -d ./.ssh ]; then
      mkdir .ssh
    fi
    if [ ! -f ./.ssh/id_ed25519 ]; then
      ssh-keygen -t ed25519 -N "" -f .ssh/id_ed25519
    fi
    if [ ! -d ./blog ]; then
      ${lib.getExe pkgs.git} clone --recurse-submodules ssh://git@forge.lel.lol:9922/patrick/blog.git ||\
      echo "failed to clone the repository did you forget to add the ssh key?"
    fi
  '';
in
{
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 80 ];
  };
  globals.wireguard.services-extern.hosts.${config.node.name} = {
    firewallRuleForNode.torweg.allowedTCPPorts = [ 80 ];
  };
  services.nginx = {
    enable = true;
    virtualHosts."blog.lel.lol" = {
      root = "/var/lib/blog/blog/public/public";
    };
  };
  programs.ssh.knownHosts = {
    "[forge.lel.lol]:9922".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWoGqHwkLVFXJwYcKs3CjQognvlZmROUIgkvvUgNalx";
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/blog";
      user = "blog";
      group = "nginx";
      mode = "0700";
    }
  ];
  systemd.timers.blog-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
    };
  };
  users.users.blog = {
    isSystemUser = true;
    group = "nginx";
    home = "/var/lib/blog";
  };

  systemd.services.blog-update = {
    # Seems like this has the annoying side effect of making zfs think all files
    # have been completely changed, thus making snapshots unnecessarily large
    # (each ~100MB adding up quite quickly
    script = ''
      cd blog
      if (git add . && git diff --quiet && git diff --cached --quiet)
      then
        echo "Nothing to commit"
      else
        echo "Commiting newest changes"
        git -c user.name="blog-bot" \
          -c user.email="blog-bot@${globals.domains.mail_public}" \
          commit -m "Automatic commit for blog on $(date -u -I)"
      fi
      git pull --rebase --recurse-submodules=yes
      git push
      ${lib.getExe pkgs.zola} -r public build
    '';
    path = [
      pkgs.openssh
      pkgs.git
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "blog";
      Group = "nginx";
      StateDirectory = "blog";
      WorkingDirectory = "/var/lib/blog";
      LimitNOFILE = "1048576";
      PrivateTmp = true;
      PrivateDevices = true;
      StateDirectoryMode = "0700";
      ExecStartPre = prestart;
    };
  };
}
