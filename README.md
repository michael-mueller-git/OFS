# OpenFunscripter

Fork of [OpenFunscripter](https://github.com/OpenFunscripter/OFS) with some additional features and Nix/NixOS support.

## Nix

```sh
nix run github:michael-mueller-git/OFS --refresh
```

if you encounter the error message `ERROR: Failed to load glad.` when running the program, try the following:

```sh
nix run --impure github:guibou/nixGL -- nix run github:michael-mueller-git/OFS --refresh
```
