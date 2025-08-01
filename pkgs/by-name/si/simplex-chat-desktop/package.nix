{
  lib,
  appimageTools,
  fetchurl,
  gitUpdater,
}:

let
  pname = "simplex-chat-desktop";
  version = "6.4.0";

  src = fetchurl {
    url = "https://github.com/simplex-chat/simplex-chat/releases/download/v${version}/simplex-desktop-x86_64.AppImage";
    hash = "sha256-DxOq0pimXxvXDi65Hryp7Fv++M6a+V1qYyDSSEgttQs=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraBwrapArgs = [
    "--setenv _JAVA_AWT_WM_NONREPARENTING 1"
  ];

  extraInstallCommands = ''
    install --mode=444 -D ${appimageContents}/chat.simplex.app.desktop --target-directory=$out/share/applications
    substituteInPlace $out/share/applications/chat.simplex.app.desktop \
      --replace-fail 'Exec=simplex' 'Exec=simplex-chat-desktop'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  passthru.updateScript = gitUpdater {
    url = "https://github.com/simplex-chat/simplex-chat";
    rev-prefix = "v";
    # skip tags that does not correspond to official releases, like vX.Y.Z-(beta,fdroid,armv7a).
    ignoredVersions = "-";
  };

  meta = {
    description = "Desktop application for SimpleX Chat";
    mainProgram = "simplex-chat-desktop";
    homepage = "https://simplex.chat";
    changelog = "https://github.com/simplex-chat/simplex-chat/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ terryg ];
    platforms = [ "x86_64-linux" ];
  };
}
