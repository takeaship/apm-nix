{
  description = "Nix package for Microsoft APM";

  # 26.05 is the last nixpkgs release supporting x86_64-darwin.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          apm = pkgs.callPackage ./package.nix { };
        in
        {
          default = apm;
          inherit apm;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${nixpkgs.lib.getExe self.packages.${system}.apm}";
        };
      });

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);
    };
}
