{
  pkgs,
  lib,
  ...
}:
let
  prestart = pkgs.writeShellScript "pr-tracker-pre" ''
    if [ ! -f ./ssh_key ]; then
      ssh-keygen -t ed25519 -N "" -f ssh_key
    fi
    ${lib.getExe pkgs.git} config core.sshCommand 'ssh -i ~/ssh_key'
    if [ ! -d ./blog ]; then
      ${lib.getExe pkgs.git} clone ssh://git@forge.lel.lol:9922/patrick/blog.git |\
      echo "failed to clone the repository did you forget to add the ssh key?"
    fi
  '';
in
{
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [ 3000 ];
  };
  services.nginx = {
    enable = true;
    user = "blog";
    virtualHosts."blog.lel.lol" = {
      root = "/var/lib/blog/blog/public";
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/blog";
      user = "blog";
      group = "blog";
      mode = "0700";
    }
    {
      directory = "/var/lib/signald";
      user = "signald";
      group = "signald";
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
      ${lib.getExe pkgs.git} -C blog pull
      ${lib.getExe pkgs.zola} -r blog/public build
    '';
    path = [ pkgs.openssh ];
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

  services.signald = {
    enable = true;
    group = "blog";
  };
}
