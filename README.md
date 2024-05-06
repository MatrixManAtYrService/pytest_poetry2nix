This repo is for either:
  - getting help with poetry2nix
  - reporting a bug

My goal:

```
❯ nix develop
$ pytest
  ... 1 failed ...
$ vi path/to/some/file # fix the problem
$ pytest
$ ... 1 passed ...
```

What happens instead:

```
❯ nix develop
  error:
       … while calling the 'derivationStrict' builtin

         at /builtin/derivation.nix:9:12: (source not available)

       … while evaluating derivation 'nix-shell'
         whose name attribute is located at /nix/store/zxvhfzx4ccad408gxy4ah90w2l30lfm2-source/pkgs/stdenv/generic/make-derivation.nix:331:7

       … while evaluating attribute 'nativeBuildInputs' of derivation 'nix-shell'

         at /nix/store/zxvhfzx4ccad408gxy4ah90w2l30lfm2-source/pkgs/stdenv/generic/make-derivation.nix:375:7:

          374|       depsBuildBuild              = elemAt (elemAt dependencies 0) 0;
          375|       nativeBuildInputs           = elemAt (elemAt dependencies 0) 1;
             |       ^
          376|       depsBuildTarget             = elemAt (elemAt dependencies 0) 2;

       … while evaluating derivation 'python3.11-myapp-0.1.0'
         whose name attribute is located at /nix/store/zxvhfzx4ccad408gxy4ah90w2l30lfm2-source/pkgs/stdenv/generic/make-derivation.nix:331:7

       … while evaluating attribute 'editablePackageSources' of derivation 'python3.11-myapp-0.1.0'

         at /nix/store/3r12x1spbjwnr3j3cyi1x1v43y4d1xpp-source/flake.nix:39:55:

           38|
           39|               (mkPoetryApplication{ projectDir = ./.; editablePackageSources = {myapp = ./src; }; })
             |                                                       ^
           40|               # this causes an error when I enter the devshell:

       error: cannot coerce a set to a string
```

If I use `mkPoetryApplication` without `editablePackageSources`, `pytest` works as expected, but the sources are not editable.
