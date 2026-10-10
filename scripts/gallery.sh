#!/bin/sh
# Build every example into gallery/ — also the quickest end-to-end test.
#   ./scripts/gallery.sh            (needs xelatex, typst, quarto, R)
set -eu
cd "$(dirname "$0")/.."
root=$(pwd)
out="$root/gallery"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$out"
export LANG="${LANG:-C.UTF-8}"
step() { printf '\n== %s\n' "$*"; }

step "LaTeX class"
cp -r latex/template "$tmp/latex"
( cd "$tmp/latex" && TEXINPUTS="$root/core/latex//:" latexmk -xelatex -quiet main.tex >/dev/null \
  && TEXINPUTS="$root/core/latex//:" latexmk -xelatex -quiet main-en.tex >/dev/null )
cp "$tmp/latex/main.pdf" "$out/latex-zh.pdf"
cp "$tmp/latex/main-en.pdf" "$out/latex-en.pdf"

step "Typst package"
mkdir -p "$tmp/typst-pkgs/local/mainsub-report"
ln -s "$root/typst" "$tmp/typst-pkgs/local/mainsub-report/0.1.0"
typst compile --package-path "$tmp/typst-pkgs" typst/template/main.typ "$out/typst-zh.pdf"

step "Quarto extension (HTML, PDF via LaTeX, PDF via Typst)"
mkdir -p "$tmp/quarto"
cp -r _extensions template.qmd references.bib "$tmp/quarto/"
( cd "$tmp/quarto" && quarto render template.qmd --quiet )
cp "$tmp/quarto/template.html" "$out/quarto.html"
( cd "$tmp/quarto" && quarto render template.qmd --to mainsub-pdf --quiet )
cp "$tmp/quarto/template.pdf" "$out/quarto-latex.pdf"
( cd "$tmp/quarto" && quarto render template.qmd --to mainsub-typst --quiet )
cp "$tmp/quarto/template.pdf" "$out/quarto-typst.pdf"

step "R Markdown (mainsub R package)"
mkdir -p "$tmp/rlib" "$tmp/rmd"
R CMD INSTALL --no-test-load -l "$tmp/rlib" r >/dev/null 2>&1
cp r/inst/rmarkdown/templates/report/skeleton/* "$tmp/rmd/"
( cd "$tmp/rmd" && R_LIBS="$tmp/rlib" Rscript -e '
  rmarkdown::render("skeleton.Rmd", "mainsub::html_report", quiet = TRUE)
  rmarkdown::render("skeleton.Rmd", "mainsub::pdf_report", quiet = TRUE)' )
cp "$tmp/rmd/skeleton.html" "$out/rmd.html"
cp "$tmp/rmd/skeleton.pdf" "$out/rmd.pdf"

step "done"
ls -l "$out"
