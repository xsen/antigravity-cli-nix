{
  description = "Google Antigravity CLI custom flake with auto-updater";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { 
            inherit system; 
            config.allowUnfree = true; 
          };
        in {
          antigravity-cli = pkgs.callPackage ./default.nix {};
          default = self.packages.${system}.antigravity-cli;
        }
      );

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = nixpkgs.lib;
          # Environment for the update script with required binaries
          updateScript = pkgs.writeShellScriptBin "update-antigravity" ''
            export PATH="${lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.nix pkgs.coreutils ]}:$PATH"
            exec ${./update.sh}
          '';
        in {
          update = {
            type = "app";
            program = "${updateScript}/bin/update-antigravity";
          };
        }
      );
    };
}
