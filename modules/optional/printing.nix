{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = [pkgs.hplipWithPlugin pkgs.hplip];
  };
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/cups";
      mode = "755";
    }
  ];
}
