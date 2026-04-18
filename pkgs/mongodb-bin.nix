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
  version = "1.0.1";
  srcs = [
    (fetchurl {
      url = "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2404-8.2.7.tgz";
      hash = "sha256-GYyWeVSoRXgrlQqx7R2chxH3+5S4ewbTefWJR9S2Frs=";
    })
    (fetchurl {
      url = "https://downloads.mongodb.com/compass/mongosh-2.8.2-linux-x64.tgz";
      hash = "sha256-nkEtOLbaoTRawo1JnQf4Dooj4aBZO/bD4F9NLUdD6+s=";
    })
  ];
  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildPhase = ''
    mkdir -p $out/bin
    cp mongosh-2.8.2-linux-x64/bin/mongosh $out/bin/mongo
    cp mongodb-linux-x86_64-ubuntu2404-8.2.7/bin/mongod $out/bin/mongod
  '';
  buildInputs = [
    openssl
    curl
    xz
    libgcc
  ];
}
