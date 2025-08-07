{
  checkedDrv,
  emacs,
  src,
  stdenv,
}: let
  lib = import ./lib.nix {inherit emacs;};
in {
  doctor = checkedDrv (stdenv.mkDerivation {
    inherit src;
    inherit (lib) ELDEV_LOCAL;

    name = "eldev doctor";

    nativeBuildInputs = [
      (emacs.pkgs.withPackages (e: [e.elisp-lint]))
      # Emacs-lisp build tool, https://doublep.github.io/eldev/
      emacs.pkgs.eldev
    ];

    buildPhase = ''
      runHook preBuild
      ## TODO: Currently needed to make a temp file in
      ##      `eldev--create-internal-pseudoarchive-descriptor`.
      HOME="$(mktemp --directory --tmpdir fake-home.XXXXXX)"
      mkdir -p "$HOME/.cache/eldev"
      ## NB: `EMACS*LOADPATH` is needed by `elisp-lint`.
      EMACSLOADPATH= EMACSNATIVELOADPATH= eldev doctor
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      runHook postInstall
    '';
  });

  lint = let
    emacsWithPackages = emacs.pkgs.withPackages (e: [
      e.elisp-lint
      e.package-lint
      e.relint
    ]);
  in
    checkedDrv (stdenv.mkDerivation {
      inherit src;
      inherit (lib) ELDEV_LOCAL;

      name = "eldev lint";

      nativeBuildInputs = [
        emacsWithPackages
        emacs.pkgs.eldev
      ];

      buildPhase = ''
        runHook preBuild

        ## Need `--disable-dependencies` here so that we don’t try to download
        ## any package archives (which would break the sandbox).
        ## NB: `EMACS*LOADPATH` is needed by `elisp-lint`.
        EMACSLOADPATH= EMACSNATIVELOADPATH= \
          eldev --disable-dependencies lint --required

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        runHook preInstall
      '';
    });
}
