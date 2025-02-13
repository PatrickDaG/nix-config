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
  globals.wireguard.services.hosts.${config.node.name} = { };
  environment.systemPackages = [
    pkgs.signal-cli
    pkgs.cargo
  ];
  services.nginx = {
    enable = true;
    user = "blog";
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
      group = "blog";
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
  users.groups.blog = { };
  users.users.blog = {
    isSystemUser = true;
    group = "blog";
    home = "/var/lib/blog";
  };

  systemd.services.blog-update = {
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
      git pull --rebase
      git push
      ${lib.getExe pkgs.zola} -r public build
    '';
    path = [
      pkgs.openssh
      pkgs.git
    ];
    serviceConfig = {
      Requires = "blog";
      Type = "oneshot";
      User = "blog";
      Group = "blog";
      StateDirectory = "blog";
      WorkingDirectory = "/var/lib/blog";
      LimitNOFILE = "1048576";
      PrivateTmp = true;
      PrivateDevices = true;
      StateDirectoryMode = "0700";
      ExecStartPre = prestart;
    };
  };

  systemd.services.signal-to-blog = {
    script = ''
      ${lib.getExe pkgs.signal-to-blog} \
      --allowed-sender "${config.secrets.secrets.local.allowedSender}" \
      --data-folder "signal-data" \
      --output-folder ~/blog/public/content/journal/ \
      --url "https://blog.lel.lol/journal" \
      --timezone 2
    '';
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.signal-cli ];
    serviceConfig = {
      Requires = "blog";
      Type = "oneshot";
      User = "blog";
      Group = "blog";
      StateDirectory = "blog";
      WorkingDirectory = "/var/lib/blog/";
      LimitNOFILE = "1048576";
      PrivateTmp = true;
      PrivateDevices = true;
      StateDirectoryMode = "0700";
    };
  };

}
