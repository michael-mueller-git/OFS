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
          rev = "24ad527b86bcb295a51da88b4e6b393e4e65a68";
          sha256 = "sha256-cOyFAcNptG2X7KcQ1IZWmoot5B4tyf1mxWCwGeaOhz4=";
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
