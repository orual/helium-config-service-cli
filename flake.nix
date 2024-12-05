{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # for building Rust packages
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, flake-utils, naersk, nixpkgs, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = (import nixpkgs) {
          inherit system overlays;
          
          
        };
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        naersk' = naersk.lib.${system}.override {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };
      in rec {
        
        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage {
          src = ./.;
          doCheck = false;
          nativeBuildInputs = with pkgs; [ 
            pkgsStatic.stdenv.cc 
          ];
          buildInputs = with pkgs; [
            openssl
            pkg-config
            protobuf
          ];

          # Tells Cargo that we're building for musl.
          # (https://doc.rust-lang.org/cargo/reference/config.html#buildtarget)
          CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
          CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static";
        };

        # For `nix develop` (optional, can be skipped):
        devShell = pkgs.mkShell {
          name = "hcs-cli";
          buildInputs = [
            rustToolchain
          ] ++ (with pkgs; [
            openssl
            pkg-config
            protobuf
          ]);
          RUST_BACKTRACE = 1;
        };
      }
    );
}