{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  git,
  bzip2,
  libffi,
  openssl,
  readline,
  sqlite,
  util-linux,
  xz,
  zlib,
}:
let
  source = import ./version.nix;
  system = stdenv.hostPlatform.system;
  platform = if stdenv.hostPlatform.isDarwin then "darwin" else "linux";
  arch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x86_64";
  bundleName = "apm-${platform}-${arch}";
in
stdenv.mkDerivation {
  pname = "apm";
  inherit (source) version;
  dontStrip = true;

  src = fetchurl {
    url = "https://github.com/microsoft/apm/releases/download/v${source.version}/${bundleName}.tar.gz";
    hash = source.hashes.${system};
  };

  sourceRoot = bundleName;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    bzip2
    libffi
    openssl
    readline
    sqlite
    util-linux
    xz
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/apm" "$out/bin"
    cp -R . "$out/lib/apm"
    chmod +x "$out/lib/apm/apm"
    makeWrapper "$out/lib/apm/apm" "$out/bin/apm" \
      --prefix PATH : ${lib.makeBinPath [ git ]}

    runHook postInstall
  '';

  meta = {
    description = "Agent Package Manager for AI coding agents";
    homepage = "https://github.com/microsoft/apm";
    license = lib.licenses.mit;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "apm";
  };
}
