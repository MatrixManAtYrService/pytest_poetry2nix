{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; })
          mkPoetryApplication mkPoetryEnv mkPoetryEditablePackage;
        pkgs = import nixpkgs { inherit system; };

      in
      {
        packages = {
          myapp = mkPoetryApplication { projectDir = self; };
          default = self.packages.${system}.myapp;
        };
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [ 
              poetry 

              # without this `pytest` is not found
              (mkPoetryEnv { projectDir = self; groups = [ "dev" ]; })

              # without this,`pytest` fails with: ModuleNotFoundError: No module named 'myapp'
              # but the sources are not editable
              # (mkPoetryApplication { projectDir = ./.; })

              # this appears to have no effect, `pytest` still fails with:
              #   ModuleNotFoundError: No module named 'myapp'
              # but at least it doesn't raise errors when I enter the devshell
              # (mkPoetryEditablePackage{ projectDir = ./.; editablePackageSources = {myapp = ./src; }; })

              (mkPoetryApplication{ projectDir = ./.; editablePackageSources = {myapp = ./src; }; })
              # this causes an error when I enter the devshell:
              # … while calling the 'derivationStrict' builtin
              #
              #   at /builtin/derivation.nix:9:12: (source not available)
              #
              # … while evaluating derivation 'nix-shell'
              #   whose name attribute is located at /nix/store/zxvhfzx4ccad408gxy4ah90w2l30lfm2-source/pkgs/stdenv/generic/make-derivation.nix:331:7
              #
              # … while evaluating attribute 'nativeBuildInputs' of derivation 'nix-shell'
              #
              #   at /nix/store/zxvhfzx4ccad408gxy4ah90w2l30lfm2-source/pkgs/stdenv/generic/make-derivation.nix:375:7:
              #
              #    374|       depsBuildBuild              = elemAt (elemAt dependencies 0) 0;
              #    375|       nativeBuildInputs           = elemAt (elemAt dependencies 0) 1;
              #       |       ^
              #    376|       depsBuildTarget             = elemAt (elemAt dependencies 0) 2;
              #
              # … while evaluating derivation 'python3.11-myapp-0.1.0'
              #   whose name attribute is located at /nix/store/zxvhfzx4ccad408gxy4ah90w2l30lfm2-source/pkgs/stdenv/generic/make-derivation.nix:331:7
              #
              # … while evaluating attribute 'editablePackageSources' of derivation 'python3.11-myapp-0.1.0'
              #
              #   at /nix/store/3r12x1spbjwnr3j3cyi1x1v43y4d1xpp-source/flake.nix:39:55:
              #
              #     38|
              #     39|               (mkPoetryApplication{ projectDir = ./.; editablePackageSources = {myapp = ./src; }; })
              #       |                                                       ^
              #     40|               # this causes an error when I enter the devshell:
              #
              # error: cannot coerce a set to a string
            ];
          };
        };
      });
}
