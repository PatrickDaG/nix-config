{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "mongodb-bin";
  version = "1.0.0";
  srcs = [
    (
      fetchurl {
        url = "https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-ubuntu2204-6.0.14.tgz";
        #hash = "";
      }
    )
    (
      fetchurl {
        url = "https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz";
        #hash = "";
      }
    )
  ];
}
