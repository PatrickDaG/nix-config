{
  fetchFromGitHub,
  lib,
  openssl_legacy,
  pkgsCross,
  python3,
  python3Packages,
  stdenv,
  stdenvNoCC,
  zip,
}:
let
  oscrypto = python3Packages.oscrypto.overrideAttrs (_: {
    postPatch = ''
      for file in oscrypto/_openssl/_libcrypto_c{ffi,types}.py; do
        substituteInPlace "$file" \
          --replace-fail "get_library('crypto', 'libcrypto.dylib', '42')" "'${lib.getLib openssl_legacy}/lib/libcrypto${stdenv.hostPlatform.extensions.sharedLibrary}'"
      done
      for file in oscrypto/_openssl/_libssl_c{ffi,types}.py; do
        substituteInPlace "$file" \
          --replace-fail "get_library('ssl', 'libssl', '44')" "'${lib.getLib openssl_legacy}/lib/libssl${stdenv.hostPlatform.extensions.sharedLibrary}'"
      done
    '';
  });
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deacsm";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "Leseratte10";
    repo = "acsm-calibre-plugin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CtnRTEDfOi07orl6IxD8mT3D5QTPp21E+eZaEb5L7xU=";
  };

  nativeBuildInputs = [
    pkgsCross.mingw32.buildPackages.gcc
    pkgsCross.mingwW64.buildPackages.gcc
    zip
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p calibre-plugin/{asn1crypto,oscrypto}
    ln -s ${python3Packages.asn1crypto}/lib/python${python3.pythonVersion}/site-packages/asn1crypto calibre-plugin/asn1crypto/asn1crypto
    ln -s ${oscrypto}/lib/python${python3.pythonVersion}/site-packages/oscrypto calibre-plugin/oscrypto/oscrypto

    (cd calibre-plugin && zip -r asn1crypto.zip asn1crypto && zip -r oscrypto.zip oscrypto)
    rm -rf calibre-plugin/{asn1crypto,oscrypto}

    bash ./bundle_calibre_plugin.sh

    # Keep OpenSSL alive when Calibre plugin is installed from this ZIP.
    printf '%s' '${lib.getLib openssl_legacy}' > .nix-openssl-legacy
    zip -0 calibre-plugin.zip .nix-openssl-legacy

    runHook postBuild
  '';

  installPhase = ''
    install -Dm444 calibre-plugin.zip "$out/calibre-plugin.zip"
  '';

  meta = {
    description = "Calibre plugin for converting ACSM files to EPUB or PDF";
    homepage = "https://github.com/Leseratte10/acsm-calibre-plugin";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ patrickdag ];
    platforms = lib.platforms.all;
  };
})
