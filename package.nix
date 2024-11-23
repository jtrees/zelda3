{ lib, stdenv, requireFile, python312, SDL2 }:

let
  fs = lib.fileset;
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
  python = (python312.withPackages (ps: with ps; [ pillow pyyaml ]));
in
stdenv.mkDerivation
{
  name = "zelda3";
  version = "0.3";

  srcs = [
    (fs.toSource {
      root = ./.;
      fileset = sourceFiles;
    })
    (requireFile {
      name = "zelda3.smc";
      message = "Please provide your legal backup copy of The Legend of Zelda - A Link to the Past (US)";
      hash = "sha256-2cacUnCy9+rFTyVGiKQ8x2f9XLTyH8B5oPn74Jl46uw=";
    })
  ];

  buildInputs = [
    python
    SDL2.dev
  ];

  unpackPhase = ''
    runHook preUnpack

    for src in $srcs; do
      if [ "''${src#*-}" = "zelda3.smc" ]; then
        cp "$src" ./zelda3.smc
      else
        cp -r "$src"/* .
      fi
    done

    if [ "$dontMakeSourcesWritable" = "1" ]; then
      :
    else
      chmod -R u+w .
    fi

    runHook postUnpack
  '';

  patchPhase = ''
    runHook prePatch

    substituteInPlace Makefile \
      --replace-fail "/usr/bin/env python3" "${python}/bin/python3"

    runHook postPatch
  '';

  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp zelda3 "$out/bin/zelda3"

    runHook postInstall
  '';
}
