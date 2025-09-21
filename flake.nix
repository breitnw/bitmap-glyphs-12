{
  description = "Cozette with modifications for use as a nerd/unicode font for Terminus";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  inputs.cozette.url = "github:breitnw/cozette/dev-updated";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    cozette,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      cozette-font = cozette.packages.${system}.cozette;
      bitsnpicas = cozette.packages.${system}.bitsnpicas-bin;
    in {
      packages = rec {
        cozette-patched = pkgs.stdenvNoCC.mkDerivation {
          pname = "bitmap-glyphs-12";
          version = "1.28.0";
          src = ./.;
          buildPhase = ''
            cat header-patched.txt >> "BitmapGlyphsUnshifted.bdf"
            sed '0,/^ENDPROPERTIES$/d' ${cozette-font}/share/fonts/misc/cozette.bdf >> "BitmapGlyphsUnshifted.bdf"
            ${bitsnpicas}/bin/bitsnpicas convertbitmap -tx -1 -f bdf BitmapGlyphsUnshifted.bdf
          '';
          installPhase = ''
            mkdir -p $out/share/fonts/misc
            mv BitmapGlyphs.bdf $out/share/fonts/misc
          '';
        };
        default = cozette-patched;
      };
    });
}
