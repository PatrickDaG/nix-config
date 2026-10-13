{ pkgs, ... }:
{
  hm.programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      --restrict-filenames
      -P "temp:~/tmp"
      -P "~/videos"
      -o "%(epoch>%Y-%m-%dT%H:%M:%SZ)s%(uploader)s_%(title)s.%(ext)s"
    '';
    settings = {
      sponsorblock-remove = "sponsor";
      sponsorblock-mark = "all";
      cookies-from-browser = "firefox";
    };
  };
  hm.home.packages = [ pkgs.ytdlp-pot-provider ];
  hm.xdg.configFile.yt-dlp-get-pot =
    let
      source = pkgs.fetchFromGitHub {
        owner = "coletdjnz";
        repo = "yt-dlp-get-pot";
        tag = "v0.2.0";
        hash = "sha256-c5iKnZ7rYckbqvEI20nymOV6/QJAWyu/FX0QM6ps2D4=";
      };
    in
    {
      inherit source;
      target = "yt-dlp/plugins/yt-dlp-get-pot";
    };
  hm.xdg.configFile.bgutil-ytdlp-pot-provider =
    let
      source = pkgs.fetchFromGitHub {
        owner = "Brainicism";
        repo = "bgutil-ytdlp-pot-provider";
        tag = "0.7.2";
        hash = "sha256-IiPle9hZEHFG6bjMbe+psVJH0iBZXOMg3pjgoERH3Eg=";
      };
    in
    {
      source = "${source}/plugin";
      target = "yt-dlp/plugins/bgutil-ytdlp-pot-provider";
    };
}
