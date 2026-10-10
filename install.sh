#!/bin/sh
# One-time setup on your own machine (Linux / macOS). Safe to run again.
#
#   ./install.sh           link the LaTeX class and the Typst package
#   ./install.sh --fonts   also let Typst / R / matplotlib see TeX Live's fonts
#                          (New Computer Modern Book, STIX Two, Libertinus, Inconsolata)
#
# Everything is a symlink into this repository, so `git pull` updates every
# template at once. Quarto and R are set up per project / per R library — see README.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
version=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$here/typst/typst.toml" | head -n1)

# ---- LaTeX: \documentclass{mainsub-report} and \usepackage{mainsub} from anywhere
if command -v kpsewhich >/dev/null 2>&1; then
  texmf=$(kpsewhich -var-value TEXMFHOME)
  mkdir -p "$texmf/tex/latex"
  ln -sfn "$here/core/latex" "$texmf/tex/latex/mainsub"
  echo "LaTeX : $texmf/tex/latex/mainsub -> core/latex"
  kpsewhich mainsub-report.cls >/dev/null || echo "        (kpsewhich cannot see it yet; run 'texhash $texmf' once)"
else
  echo "LaTeX : skipped (no kpsewhich; is TeX Live installed?)"
fi

# ---- Typst: #import "@local/mainsub-report:$version": *
case "$(uname -s)" in
  Darwin) tdata="$HOME/Library/Application Support/typst" ;;
  *)      tdata="${XDG_DATA_HOME:-$HOME/.local/share}/typst" ;;
esac
mkdir -p "$tdata/packages/local/mainsub-report"
ln -sfn "$here/typst" "$tdata/packages/local/mainsub-report/$version"
echo "Typst : @local/mainsub-report:$version -> typst/"

# ---- optional: TeX Live's OpenType fonts for fontconfig (Typst, ragg, matplotlib)
if [ "${1:-}" = "--fonts" ]; then
  dist="$(kpsewhich -var-value TEXMFDIST)/fonts/opentype/public"
  conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig/conf.d"
  mkdir -p "$conf_dir"
  {
    echo '<?xml version="1.0"?>'
    echo '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">'
    echo '<!-- written by mainsub-templates/install.sh -->'
    echo '<fontconfig>'
    for d in newcomputermodern libertinus-fonts stix2-otf inconsolata; do
      [ -d "$dist/$d" ] && echo "  <dir>$dist/$d</dir>"
    done
    echo '</fontconfig>'
  } > "$conf_dir/60-mainsub-texlive.conf"
  fc-cache -f >/dev/null 2>&1 || true
  echo "Fonts : $conf_dir/60-mainsub-texlive.conf"
fi

cat <<EOF

Next:
  Quarto  in a project folder:  quarto add Mainsub-Linvega/mainsub-templates
          new document:         quarto use template Mainsub-Linvega/mainsub-templates
  R       remotes::install_github("Mainsub-Linvega/mainsub-templates", subdir = "r")
          or, from this clone:  R CMD INSTALL $here/r
  Typst   typst init @local/mainsub-report:$version my-report
  LaTeX   cp -r $here/latex/template my-report && cd my-report && latexmk main.tex
EOF
