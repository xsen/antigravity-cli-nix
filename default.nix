{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  versionCheckHook,
}:

let
  metadata = builtins.fromJSON (builtins.readFile ./meta.json);
  
  version = metadata.version;
  build_id = metadata.build_id;

  # URL pattern for Google Storage
  metaToUrl = platform: "https://storage.googleapis.com/antigravity-public/antigravity-cli/${version}-${build_id}/${platform}";

  sourceData = {
    "x86_64-linux"   = { path = "linux-x64/cli_linux_x64.tar.gz"; hash = metadata.hashes."x86_64-linux"; };
    "aarch64-linux"  = { path = "linux-arm/cli_linux_arm64.tar.gz"; hash = metadata.hashes."aarch64-linux"; };
    "aarch64-darwin" = { path = "darwin-arm/cli_mac_arm64.tar.gz"; hash = metadata.hashes."aarch64-darwin"; };
    "x86_64-darwin"  = { path = "darwin-x64/cli_mac_x64.tar.gz"; hash = metadata.hashes."x86_64-darwin"; };
  };

  sources = lib.mapAttrs (
    _system: data:
    fetchzip {
      url = metaToUrl data.path;
      inherit (data) hash;
    }
  ) sourceData;

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity-cli";
  inherit version;

  src = source;

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 antigravity $out/bin/agy
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Google's Go-based terminal user interface (TUI) agent client";
    homepage = "https://antigravity.google";
    changelog = "https://antigravity.google/changelog";
    license = lib.licenses.unfree;
    mainProgram = "agy";
    platforms = lib.attrNames sourceData;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
