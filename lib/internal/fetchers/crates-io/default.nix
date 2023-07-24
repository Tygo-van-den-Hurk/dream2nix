{
  pkgs,
  utils,
  ...
}: {
  inputs = ["pname" "version"];

  versionField = "version";

  outputs = {
    pname,
    version,
    ...
  }: let
    b = builtins;
    # See https://github.com/rust-lang/crates.io-index/blob/master/config.json#L2
    url = "https://crates.io/api/v1/crates/${pname}/${version}/download";
  in {
    calcHash = algo:
      utils.hashFile algo (b.fetchurl {
        inherit url;
      });

    fetched = hash: let
      fetched = pkgs.fetchurl {
        inherit url;
        sha256 = hash;
        name = "download-${pname}-${version}";
      };
    in
      pkgs.runCommandLocal "unpack-${pname}-${version}" {}
      ''
        mkdir -p $out
        tar --strip-components 1 -xzf ${fetched} -C $out
        echo '{"package":"${hash}","files":{}}' > $out/.cargo-checksum.json
      '';
  };
}