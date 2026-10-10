# mainsub-templates

[中文说明](README.zh-CN.md)

One quiet design for reports, carried through six routes:

| Route | Output | Entry point |
|---|---|---|
| LaTeX | PDF | `\documentclass{mainsub-report}` |
| Typst | PDF | `#import "@local/mainsub-report:0.1.0": *` |
| R Markdown | PDF | `output: mainsub::pdf_report` |
| R Markdown | HTML | `output: mainsub::html_report` |
| Quarto | PDF | `format: mainsub-pdf` (XeLaTeX) or `mainsub-typst` |
| Quarto | HTML | `format: mainsub-html` |

The same demo document rendered by every route is in [`gallery/`](gallery/):
[LaTeX](gallery/latex-zh.pdf) ·
[LaTeX, English](gallery/latex-en.pdf) ·
[Typst](gallery/typst-zh.pdf) ·
[Quarto → PDF](gallery/quarto-latex.pdf) ·
[Quarto → Typst](gallery/quarto-typst.pdf) ·
[Quarto → HTML](gallery/quarto.html) ·
[R Markdown → PDF](gallery/rmd.pdf) ·
[R Markdown → HTML](gallery/rmd.html)

## The idea: two tiers, one identity

**PDF is print.** It is what a supervisor reads, annotates and files. Typography
is fixed, so it is set the way LaTeX lecture notes are: New Computer Modern
(the *Book* weight, which holds its own next to Source Han / Noto Serif CJK),
Kai for Chinese emphasis, hanging section numbers, three-line tables, code hidden.

**HTML is a screen.** It is what classmates open on a phone or laptop. Text
reflows, so it uses each system's own sans-serif (no web fonts to download or
embed), code is shown but folded, there is a table of contents, and the file
stays small.

What carries across is the structure, not the font: the same heading hierarchy,
the same numbering (Figure 1, Equation (2), Theorem 1 — never 3.1 in one route and
1 in another), the same three-line tables, the same maths font (MathJax 4 renders
New Computer Modern, as the PDFs do), the same six colours. There is exactly one
accent, a dark oxblood, used only for URLs and the draft stamp.

## Quick start

### Quarto (HTML + PDF from one `.qmd`)

```bash
quarto use template Mainsub-Linvega/mainsub-templates   # new document from the demo
quarto add Mainsub-Linvega/mainsub-templates            # or: add to an existing project
```

```yaml
lang: zh                 # or en
format:
  mainsub-html: default    # one self-contained .html
  mainsub-pdf: default     # XeLaTeX
  # mainsub-typst: default # or: the same design compiled by Typst in about a second
                           # (both write a .pdf, so pick one of the two)
```

### R Markdown

```r
remotes::install_github("Mainsub-Linvega/mainsub-templates", subdir = "r")
rmarkdown::draft("report.Rmd", template = "report", package = "mainsub")  # demo skeleton
```

```yaml
output:
  mainsub::html_report: default
  mainsub::pdf_report:
    review: true         # line numbers + "Draft" stamp
```

The package also gives `theme_mainsub()`, `scale_colour_mainsub()` and
`use_mainsub_ggplot()` (called automatically by both formats; call it yourself in
a Quarto setup chunk) so plots match the documents.

### LaTeX and Typst

```bash
git clone https://github.com/Mainsub-Linvega/mainsub-templates
cd mainsub-templates && ./install.sh        # symlinks; `git pull` updates everything

cp -r latex/template my-report && cd my-report && latexmk main.tex
typst init @local/mainsub-report:0.1.0 my-report && cd my-report && typst watch main.typ
```

`./install.sh --fonts` also tells fontconfig about TeX Live's fonts, so Typst,
R graphics and matplotlib can use New Computer Modern Book, STIX Two or Inconsolata.

### matplotlib

```python
plt.style.use("path/to/mainsub-templates/python/mainsub.mplstyle")
```

## Options

| | LaTeX class option | Typst `report()` | Quarto YAML | R Markdown |
|---|---|---|---|---|
| Language | `lang=zh` | `lang: "zh"` | `lang: zh` | `lang: zh` |
| Font preset | `font=stix` | `font: "stix"` | `mainsub: {font: stix}` | `pdf_report(font = "stix")` |
| Draft for review | `review` | `review: true` | `mainsub: {review: true}` | `pdf_report(review = TRUE)` |
| Numbering 2.1, 2.2 | `numbering=section` | `numbering: "section"` | `mainsub: {numbering: section}` | `pdf_report(numbering = "section")` |
| Paper | `paper=letter` | `paper: "us-letter"` | `papersize: letter` | `papersize: letter` |

Font presets: `newcm` (default; New Computer Modern Book + Math), `libertinus`, `stix` (STIX Two).

## Writing notes

* **Maths macros.** `\E`, `\Prob`, `\Var`, `\Cov`, `\Corr`, `\Bias`, `\MSE`,
  `\Normal`, `\iid`, `\indep`, `\ind`, `\convp`, `\convd`, `\convas`, `\Op`,
  `\op`, `\R`, `\N`, `\Z`, `\Q`, `\tr`, `\diag`, `\rank`, `\sign`, `\argmin`,
  `\argmax`, `\norm{}`, `\abs{}`, `\inner{}{}`, `\dd`, `\eps` work everywhere.
  They live in [`core/latex/mainsub-macros.tex`](core/latex/mainsub-macros.tex);
  LaTeX reads that file, and the HTML and Typst routes expand the macros at build
  time, so MathJax never has to know them. Add your own per document with
  `macros: my-macros.tex` (Quarto / R Markdown). In Typst use `EE`, `PP`, `Var`,
  `argmin`, ... from the package.
* **Only labelled equations are numbered** (Quarto's rule, applied to Typst too).
* **Theorems.** LaTeX: `theorem`, `lemma`, `proposition`, `corollary`,
  `definition`, `assumption`, `example`, `remark`, `proof`. Typst: `#theorem[...]`,
  `#definition(title: [...])[...] <def-x>`, `#proof[...]`. Quarto: `::: {#thm-x}`.
  R Markdown: `::: {.theorem #x}` (bookdown).
* **Chinese references.** Quarto: `第 -@sec-model 节` gives 第 2 节, and `由 @eq-x 及`
  gives 由式 (1) 及 — the space you need in the source is removed in the output.
  LaTeX: write `由\cref{eq:x} 及`; xeCJK handles the rest.
* **Citations.** Chinese documents default to GB/T 7714-2015 author-date (with
  mixed-case names); English ones to author-year (Chicago author-date in the pandoc
  and Typst routes, biblatex `authoryear` in the LaTeX class). Set `csl:` to override.
* **CJK fonts** are found by name, in order: Noto/Source Han → Songti/STSong/SimSun
  → Fandol (bundled with TeX Live). Installing [LXGW WenKai](https://github.com/lxgw/LxgwWenKai)
  turns Chinese emphasis into Kai; without it, emphasis falls back to Hei.

## Why the old HTML was 10 MB, and what this one does instead

`dpi: 200` with `fig.retina: 2` and `fig-width: 9` makes every PNG 3600 px wide —
four times what a retina screen can show — and a scatterplot of a few thousand
translucent points at that size is about 1 MB. `self-contained-math: true` adds
another 1.3 MB of MathJax while the maths fonts are *still* fetched from the CDN.

Here the HTML formats use 96 dpi × retina 2 (crisp, about 1300 px wide), squeeze
generated PNGs with `pngquant` when it is installed (another −60 %), never embed
MathJax, and embed no web fonts. The R Markdown HTML has no Bootstrap or jQuery
at all: the demo is 110 kB. Quarto's own Bootstrap bundle puts a floor of about
1.2 MB under the Quarto HTML. For a scatterplot with many points, `#| dev: svglite`
is not smaller — keep PNG there; for line and bar charts SVG is tiny.

## Repository layout

```
core/         the single source of truth — edit here
  latex/      mainsub.sty (the design), mainsub-report.cls, mainsub-macros.tex
  html/       base.css (both HTML routes), quarto.css, rmd.css, MathJax config
  filters/    pandoc Lua filters shared by Quarto and R Markdown
  quarto/     the extension manifest and template partials
  rmd/        pandoc templates behind the R Markdown formats
typst/        the Typst package (mainsub.typ is its own implementation of the design)
_extensions/  the Quarto extension — generated, at the root so `quarto add` finds it
r/            the R package — inst/ is generated
latex/        LaTeX starter documents
python/       matplotlib style
gallery/      every route's output for the demo document
scripts/      sync.sh (core/ → copies), gallery.sh (build everything), demo-figure.R
```

After editing anything in `core/`, run `make sync` (copies into `_extensions/`,
`typst/` and `r/inst/`), then `make gallery` to rebuild and eyeball every route.
CI fails if the copies are out of date.

## Requirements

* PDF via LaTeX: XeLaTeX and TeX Live with `ctex`, `newcomputermodern`,
  `unicode-math`, `biblatex-gb7714-2015`, `biber` (Debian: `texlive-xetex
  texlive-lang-chinese texlive-fonts-extra texlive-latex-extra texlive-science
  texlive-bibtex-extra biber`), and `fonts-noto-cjk`.
* Typst ≥ 0.14 (tested with 0.15). Quarto ≥ 1.6 (tested with 1.10).
* R ≥ 4.1 with rmarkdown, bookdown, knitr; ggplot2 and ragg suggested.
* Optional: `pngquant` for smaller HTML.

## Licence

MIT. `gb7714-author-date.csl` is adapted from the Citation Style Language project
under CC BY-SA 3.0. No fonts are bundled.
