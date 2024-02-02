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
      ofsDependencies = with pkgs; [
        mesa
        libGLU
        libglvnd
        mpv
        xorg.libX11
        xorg.libXext
        xorg.libXinerama
        xorg.libXi
        xorg.libXrandr
        xorg.libXfixes
        xorg.libXxf86vm
        wayland    
        waylandpp
        wayland-protocols
        wayland-scanner
        libGL
        SDL2
        gnome.zenity
        which
        git
      ];
      libPath = pkgs.lib.makeLibraryPath ofsDependencies;
      binPath = pkgs.lib.makeBinPath ofsDependencies;
    in
    {
      packages.x86_64-linux.ofs = pkgs.stdenv.mkDerivation {
        pname = "OpenFunscripter";
        version = "4.0.0";
        src = pkgs.fetchgit {
          url = "https://github.com/michael-mueller-git/OFS.git";
          rev = "4afb3b603a426720b8393cf6c55d1614fc9dcd7d";
          sha256 = "sha256-MMF6TepD8Ep4uX+7CRQXTCwBgAOLmt15wBKUp8yyggU=";
        };
        cmakeFlags = [ "-Wno-dev" "--compile-no-warning-as-error" "-DCFLAGS=-Wno-error" "-DCXXFLAGS=-Wno-error -DUSE_NIX_LIB=ON" ];
        buildInputs = ofsDependencies;
        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          makeWrapper
        ];
        postInstall = ''
          wrapProgram "$out/bin/OpenFunscripter" --prefix LD_LIBRARY_PATH : "${libPath}" --prefix PATH : "${binPath}"
          cp -rfv "$src/data" "$out/bin/"
        '';
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.ofs;
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.x86_64-linux.default = pkgs.mkShell {
        LD_LIBRARY_PATH = libPath;
        buildInputs = ofsDependencies;        
        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];
      };
    };
}
