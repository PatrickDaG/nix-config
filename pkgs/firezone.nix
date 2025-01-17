{
  lib,
  fetchFromGitHub,
  beamPackages,
  pnpm_9,
  nodejs,
  tailwindcss,
  esbuild,
}:

beamPackages.mixRelease rec {
  pname = "firezone";
  version = "1.4.0";

  src = "${
    fetchFromGitHub {
      owner = "firezone";
      repo = "firezone";
      tag = "headless-client-${version}";
      hash = "sha256-juDqENBUAZ43AsRkNkFqh5+6Pj6dQeUbVvsU8Y50NJQ=";
    }
  }/elixir";

  pnpmDeps = pnpm_9.fetchDeps {
    inherit pname version;
    src = "${src}/apps/web/assets";
    hash = "sha256-6rhhGv3jQY5MkOMNe1GEtNyrzJYXCSzvo8RLlKelP10=";
  };
  pnpmRoot = "./apps/web/assets";

  preBuild = ''
    cat >> config/config.exs <<EOF
    config :tailwind, path: "${lib.getExe tailwindcss}"
    config :esbuild, path: "${lib.getExe esbuild}"
    EOF
  '';

  postBuild = ''

    pushd apps/web
    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
    mix do deps.loadpaths --no-deps-check, phx.digest priv/static
    popd
  '';

  nativeBuildInputs = [
    pnpm_9
    pnpm_9.configHook
    nodejs
  ];
  mixReleaseName = "domain";
  removeCookie = false;

  #https://github.com/elixir-cldr/cldr_numbers/pull/52
  mixNixDeps = import ./mix.nix {
    inherit lib beamPackages;
    overrides =
      final: prev:
      (lib.mapAttrs (
        _: value:
        value.override {
          appConfigPath = src + "/config";
        }
      ) prev)
      // {
        # mix2nix does not support git dependencies yet,
        # so we need to add them manually
        openid_connect = beamPackages.buildMix {
          name = "openid_connect";
          version = "2024-06-15-unstable";

          src = fetchFromGitHub {
            owner = "firezone";
            repo = "openid_connect";
            rev = "e4d9dca8ae43c765c00a7d3dfa12d6f24f5b3418";
            hash = "sha256-LMmG+WWs83Hw/jcrersUMpk2tdXxkOU0CTe7qVbk6GQ=";
          };
          beamDeps = with final; [
            jason
            finch
            jose
          ];
        };
      };
  };

  meta = {
    description = "Enterprise-ready zero-trust access platform built on WireGuard";
    homepage = "https://github.com/firezone/firezone";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      oddlama
      patrickdag
    ];
    mainProgram = "firezone";
    platforms = lib.platforms.all;
  };
}
