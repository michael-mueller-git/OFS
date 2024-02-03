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
      packages.${system}.ofs = pkgs.stdenv.mkDerivation {
        pname = "OpenFunscripter";
        version = "4.0.1";
        src = pkgs.fetchgit {
          url = "https://github.com/michael-mueller-git/OFS.git";
          rev = "084ff44c93fd6a7f75ec01d9634146bb21b7c77";
          sha256 = "sha256-P6Ht3V2vi4jJ8cMRhDLVEt2GjhQwcOYDDAPsIWKZSBs=";
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
      defaultPackage.${system} = self.packages.${system}.ofs;
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.${system}.default = pkgs.mkShell {
        LD_LIBRARY_PATH = libPath;
        buildInputs = ofsDependencies;        
        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];
      };
    };
}
