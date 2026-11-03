{
  description = "Sito statico G.Scacco realizzato con Hugo";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "gscacco-site";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [ pkgs.hugo ];

            buildPhase = ''
              runHook preBuild
              hugo --minify --destination "$out" --cacheDir "$TMPDIR/hugo-cache"
              runHook postBuild
            '';

            dontInstall = true;
            dontFixup = true;

            meta = {
              description = "Sito statico G.Scacco generato con Hugo";
              homepage = "https://gscacco.github.io/";
              license = pkgs.lib.licenses.mit;
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.hugo ];
          };
        });

      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
