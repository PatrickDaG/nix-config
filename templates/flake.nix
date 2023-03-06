{
  description = "A collection of flake templates";

  outputs = {self}: {
    templates = {
      default = {
        path = ./default;
        description = "My own basic flake template";
      };
    };
  };
}
