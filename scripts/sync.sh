#!/bin/sh
# Copy the single source of truth in core/ (and typst/) into the places that
# need their own copies: the Quarto extension and the R package.
# Run after editing anything in core/:   ./scripts/sync.sh   (or: make sync)
set -eu
cd "$(dirname "$0")/.."

ext=_extensions/mainsub
rinst=r/inst/rmarkdown/resources
mkdir -p "$ext/partials" "$rinst"

# ---- Quarto extension
cp core/quarto/extension.yml "$ext/_extension.yml"   # named differently in core/ so Quarto finds only one extension
cp core/quarto/partials/* "$ext/partials/"
cp core/latex/mainsub.sty core/latex/mainsub-macros.tex "$ext/"
cp core/filters/mainsub.lua core/filters/mainsub-post.lua core/highlight/mainsub.theme core/csl/gb7714-author-date.csl core/html/mathjax-config.html "$ext/"
cp typst/mainsub.typ typst/mainsub.tmTheme "$ext/"
{
  echo "/*-- scss:defaults --*/"
  cat core/html/quarto-defaults.scss
  echo
  echo "/*-- scss:rules --*/"
  cat core/html/base.css core/html/quarto.css
} > "$ext/mainsub.scss"

# ---- Typst package (its own copy of the CSL file)
cp core/csl/gb7714-author-date.csl typst/

# ---- R package
cp core/latex/mainsub.sty core/latex/mainsub-macros.tex "$rinst/"
cp core/filters/mainsub.lua core/filters/mainsub-post.lua core/highlight/mainsub.theme core/csl/gb7714-author-date.csl core/html/mathjax-config.html "$rinst/"
cp core/rmd/mainsub.tex core/rmd/mainsub.html "$rinst/"
cat core/html/base.css core/html/rmd.css > "$rinst/mainsub.css"


echo "synced core/ -> $ext, typst/, $rinst"
