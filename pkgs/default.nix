_inputs: [
  (import ./scripts)
  (_final: prev: {
    zsh-histdb-skim = prev.callPackage ./zsh-histdb-skim.nix { };
    zsh-histdb = prev.callPackage ./zsh-histdb.nix { };
    signal-to-blog = prev.callPackage ./signal-to-blog.nix { };
    ytdlp-pot-provider = prev.callPackage ./ytdlp-pot-provider.nix { };
    mongodb-bin = prev.callPackage ./mongodb-bin.nix { };
    disneyplus = prev.callPackage ./disney.nix { };
    amazon = prev.callPackage ./amazon.nix { };
    nix-plugins = prev.callPackage ./nix-plugins.nix { };
    awakened-poe-trade = prev.callPackage ./awakened-poe-trade.nix { };
    goldfish = prev.callPackage ./goldfish.nix { };
    soulver-cpp = prev.callPackage ./soulver-cpp.nix { };
    neovim-clean = prev.neovim-unwrapped.overrideAttrs (
      _neovimFinal: neovimPrev: {
        nativeBuildInputs = (neovimPrev.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
        postInstall = (neovimPrev.postInstall or "") + ''
          wrapProgram $out/bin/nvim --add-flags "--clean"
        '';
      }
    );
    sd-switch = prev.rustPlatform.buildRustPackage {
      pname = "sd-switch";

      src = prev.fetchFromGitea {
        domain = "forge.lel.lol";
        owner = "patrick";
        repo = "sd-switch";
        rev = "master";
        hash = "sha256-WzbFGbFCS0TQXRM09U0nUATpduQ+ZZF6D1uFD2UlnhA=";
      };
      meta.mainProgram = "sd-switch";
      version = "0.6.3-pre";
      cargoHash = "sha256-jclRF05eUAW/ggCmfZfWE6c4q25d/WGX0dad4rsP8vk=";
    };
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (_pythonFinal: pythonPrev: {
        pyhumps = pythonPrev.pyhumps.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            (prev.fetchpatch {
              url = "https://patch-diff.githubusercontent.com/raw/nficano/humps/pull/305.patch";
              hash = "sha256-KH+VNDR6524RrR3SgedzRoWfv+YahsjDYPITGJdJUDQ=";
            })
          ];
        });
        home-assistant-chip-wheels = pythonPrev.home-assistant-chip-wheels.overrideAttrs {
          prePatch = ''
            rm 0002-Use-data-as-platform-storage-location.patch
          '';
        };
      })
    ];

    path-of-building = prev.path-of-building.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/pobfrontend \
          --set QT_QPA_PLATFORM xcb
      '';
    });
    home-assistant-custom-components = prev.home-assistant-custom-components // {
      another_mvg = prev.home-assistant.python.pkgs.callPackage ./another_mvg.nix { };
      solaredge-modbus = prev.home-assistant.python.pkgs.callPackage ./solaredge-modbus.nix { };
    };
    home-assistant-custom-lovelace-modules = prev.home-assistant-custom-lovelace-modules // {
      another_mvg_1 = prev.callPackage ./another_mvg_l.nix { };
      another_mvg_2 = prev.callPackage ./another_mvg_l.nix {
        entrypoint = "content-card-another-mvg-big.js";
      };
      another_mvg_3 = prev.callPackage ./another_mvg_l.nix {
        entrypoint = "content-card-another-mvg-livemap.js";
      };
    };
  })
]
