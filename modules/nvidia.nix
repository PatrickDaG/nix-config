{pkgs, ...}: let
  prime-run = pkgs.writeShellScriptBin "prime-run" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_Provider=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  services.xserver.videoDrivers = ["nvidia"];

  environment.systemPackages = [prime-run];

  hardware.nvidia.prime = {
    offload.enable = true;

    intelBusId = "PCI:00:02:0";
    nvidiaBusId = "PCI:59:00:0";
  };
}
