let
  rust_overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  pkgs = import <nixpkgs> { overlays = [ rust_overlay ]; };
  rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
in
pkgs.mkShell {
  name = "hcs-cli";
  buildInputs = [
    rustToolchain
  ] ++ (with pkgs; [
    pkg-config
    protobuf
  ]);
  RUST_BACKTRACE = 1;
}