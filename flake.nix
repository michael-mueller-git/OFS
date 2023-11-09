{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = "${system}";
      };
    in
    {
      packages.x86_64-linux.ofs = pkgs.stdenv.mkDerivation {
        pname = "OFS";
        version = "4.0.0";
        src = pkgs.fetchgit {
          url = "https://github.com/michael-mueller-git/OFS.git";
          rev = "42a9f1a07941dda70a1c6c58c3be0612fd44129d";
          sha256 = "sha256-UFU3Ln/XdjjujpPSrnIK0EPFw+/ZJ10fBLSe4ZA3PH4=";
        };
        cmakeFlags = [ "-Wno-dev" "--compile-no-warning-as-error" "-DCFLAGS=-Wno-error" ];
        nativeBuildInputs = with pkgs; [
          cmake
          mesa
          libGLU
          pkg-config
          mpv
        ];
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.ofs;
      formatter.${system} = pkgs.nixpkgs-fmt;
       devShells.x86_64-linux.default = pkgs.mkShell {
        shellHook = ''
          echo " >> Welcome to NixOS developer shell"
        '';
        nativeBuildInputs = with pkgs; [
          cmake
          mesa
          libGLU
          pkg-config
          mpv
        ];
      };
    };
}
