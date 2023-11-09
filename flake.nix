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
        pname = "OpenFunscripter";
        version = "4.0.0";
        src = pkgs.fetchgit {
          url = "https://github.com/michael-mueller-git/OFS.git";
          rev = "a95b3a68be691ca6d2dae1f7ae51988227fafe87";
          sha256 = "sha256-B8efNEukT/cakNmNMCO5PDP+A0GmNvxCPWOSRwGFgXE=";
        };
        cmakeFlags = [ "-Wno-dev" "--compile-no-warning-as-error" "-DCFLAGS=-Wno-error" "-DCXXFLAGS=-Wno-error" ];
        nativeBuildInputs = with pkgs; [
          cmake
          mesa
          libGLU
          libglvnd
          pkg-config
          mpv
        ];
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.ofs;
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.x86_64-linux.default = pkgs.mkShell {
        shellHook = ''
          echo " >> Welcome to Nix developer shell"
        '';
        nativeBuildInputs = with pkgs; [
          cmake
          mesa
          libGLU
          libglvnd
          pkg-config
          mpv
        ];
      };
    };
}
