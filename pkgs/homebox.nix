{
  stdenvNoCC,
  jq,
  moreutils,
  nodePackages,
  cacert,
  lib,
  buildGoModule,
  fetchFromGitHub,
}: let
  pname = "homebox";
  version = "0.10.3";
  src = "${fetchFromGitHub {
    owner = "hay-kot";
    repo = "homebox";
    rev = "v${version}";
    hash = "sha256-Hej/dM0BgtRWiMOpp/SDVr3H1IbYb935T1pfX8apjpE=";
    # Inspired by: https://github.com/NixOS/nixpkgs/blob/f2d7a289c5a5ece8521dd082b81ac7e4a57c2c5c/pkgs/applications/graphics/pdfcpu/default.nix#L20-L32
    # The intention here is to write the information into files in the `src`'s
    # `$out`, and use them later in other phases (in this case `preBuild`).
    # In order to keep determinism, we also delete the `.git` directory
    # afterwards, imitating the default behavior of `leaveDotGit = false`.
    # More info about git log format can be found at `git-log(1)` manpage.
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git log -1 --pretty=%H > "backend/COMMIT"
      git log -1 --pretty=%cd --date=format:'%Y-%m-%dT%H:%M:%SZ' > "backend/SOURCE_DATE"
      rm -rf ".git"
    '';
  }}";

  frontend = stdenvNoCC.mkDerivation {
    pname = "${pname}-frontend";
    inherit version;

    src = "${src}/frontend";

    preBuild = ''
      export HOME=$(mktemp -d)
      export STORE_PATH=$(mktemp -d)

      pnpm config set store-dir "${pnpm-deps}"
      pnpm install --offline --frozen-lockfile --shamefully-hoist
      patchShebangs node_modules/{*,.*}
    '';

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';
    env.NUXT_TELEMETRY_DISABLED = 1;

    nativeBuildInputs = [
      nodePackages.pnpm
      #breakpointHook
    ];
    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r .output/public/* $out/

      runHook postInstall
    '';
  };
  pnpm-deps = stdenvNoCC.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit version;
    src = "${src}/frontend";

    nativeBuildInputs = [
      jq
      moreutils
      nodePackages.pnpm
      cacert
    ];

    installPhase = ''
      export HOME=$(mktemp -d)
      pnpm config set store-dir $out
      # This version of the package has different versions of esbuild as a dependency.
      # You can use the command below to get esbuild binaries for a specific platform and calculate hashes for that platforms. (linux, darwin for os, and x86, arm64, ia32 for cpu)
      # cat package.json | jq '.pnpm.supportedArchitectures += { "os": ["linux"], "cpu": ["arm64"] }' | sponge package.json
      pnpm install --frozen-lockfile --ignore-script

      # Remove timestamp and sort the json files.
      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
    '';

    dontBuild = true;
    dontFixup = true;
    outputHashMode = "recursive";
    outputHash = "sha256-BVZSdc8e6v+paMzMYazEdnKSNw+OnCpjSzGSEKxVl24=";
  };
in
  buildGoModule {
    inherit pname version;
    src = "${src}/backend";

    vendorHash = "sha256-TtFz+dDpoMs3PAQjiYQm1+Q6prn4Hiaf7xqWt41oY7w=";

    CGO_ENABLED = 0;
    GOOS = "linux";
    doCheck = false;

    # options used by upstream:
    # https://github.com/simulot/immich-go/blob/0.13.2/.goreleaser.yaml
    ldflags = [
      "-s"
      "-w"
      "-extldflags=-static"
      "-X main.version=${version}"
    ];

    preBuild = ''
      ldflags+=" -X main.commit=$(cat COMMIT)"
      ldflags+=" -X main.date=$(cat SOURCE_DATE)"
      mkdir -p ./app/api/static/public
      cp -r ${frontend}/* ./app/api/static/public
    '';

    meta = with lib; {
      mainProgram = "api";
      homepage = "https://hay-kot.github.io/homebox/";
      maintainers = with maintainers; [patrickdag];
      license = licenses.agpl3Only;
      description = "A inventory and organization system built for the Home User";
      platforms = platforms.all;
    };
  }
