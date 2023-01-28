pkgs: secretFiles:
(
	pkgs.stdenv.mkDerivation rec {
	pname = "host-secrets";
	version = "1";
	description = "Rekeyed secrets for this host";

	srcs = secretFiles;
	sourceRoot = ".";

	dontMakeSourcesWriteable = true;
	dontUnpack = true;
	dontConfigure = true;
	dontBuild = true;

	installPhase = ''
      cp -r /tmp/nix-rekey.d/ $out
	'';
  }
)
