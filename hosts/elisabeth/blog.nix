{
  services.nginx.virtualHosts."blog.lel.lol" = {
    root = "/persist/blog";
    forceSSL = true;
    useACMEHost = "web";
  };
}
