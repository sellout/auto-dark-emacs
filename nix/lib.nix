{emacs}: let
  emacsPath = package: "${package}/share/emacs/site-lisp/elpa/${package.pname}-${package.version}";
in {
  ## We need to tell Eldev where to find its Emacs package.
  ELDEV_LOCAL = emacsPath emacs.pkgs.eldev;
}
