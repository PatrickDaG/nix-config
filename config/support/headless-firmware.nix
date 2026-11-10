{ pkgs, ... }:
{
  # Wired, headless servers do not need GPU, Wi-Fi, Bluetooth, or sound firmware.
  # Keep NIC, storage controller, and other firmware rather than guessing the NIC model.
  hardware = {
    enableAllFirmware = false;
    enableRedistributableFirmware = false;
    firmware = [
      (pkgs.runCommand "linux-firmware-headless"
        {
          passthru.compressFirmware = false;
          outputChecks.out.allowedRequisites = [ "out" ];
          __structuredAttrs = true;
        }
        ''
          mkdir -p "$out/lib"
          cp -aL ${pkgs.compressFirmwareZstd pkgs.linux-firmware}/lib/firmware "$out/lib/"
          chmod -R u+w "$out"
          cd "$out/lib/firmware"
          rm -rf amdgpu nvidia nouveau i915 xe \
            ath* brcm b43 b43legacy qcom mediatek \
            rtl_bt rtlwifi rtw88 rtw89 ti-connectivity mrvl libertas \
            iwlwifi-* intel/ibt-* intel/sof* intel/avs cirrus ess yamaha
        ''
      )
    ];
  };
}
