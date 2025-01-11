{ default-pre-commit-hooks }:
{
  treefmt,
  system,
  src,
  pre-commit-hooks ? default-pre-commit-hooks,
}:
pre-commit-hooks.lib.${system}.run {
  inherit src;
  hooks = {
    treefmt.enable = true;
    treefmt.package = treefmt;
  };
}
