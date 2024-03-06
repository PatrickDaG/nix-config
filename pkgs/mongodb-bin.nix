{
  stdenv,
  fetchurl,
  openssl,
  xz,
  curl,
  autoPatchelfHook,
  libgcc,
}:
stdenv.mkDerivation {
  pname = "mongodb-bin";
  version = "1.0.0";
  srcs = [
    (
      fetchurl {
        url = "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2204-6.0.14.tgz";
        hash = "sha256-1MW3pVIffdxq63gY64ozM1erWM2ou2L8T+MTfG+ZPLg=";
      }
    )
    (
      fetchurl {
        url = "https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz";
        hash = "sha256-R1GGB0ZGqmpJtMUNF2+EJK6iNiChHuoHyOf2vKDcOKA=";
      }
    )
  ];
  sourceRoot = ".";
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildPhase = ''
    mkdir -p $out/bin
    cp mongosh-2.1.5-linux-x64/bin/mongosh $out/bin/mongo
    cp mongodb-linux-x86_64-ubuntu2204-6.0.14/bin/mongod $out/bin/mongod
  '';
  buildInputs = [openssl curl xz libgcc];
}
