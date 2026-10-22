# mainsub-templates

[中文说明](README.zh-CN.md)

A clean academic report template for LaTeX, Typst, Quarto and R Markdown.
The PDF is made for printing and annotating, the HTML for reading on screen; headings, numbering,
tables and maths fonts stay the same across every route.

| Route | Output | Entry point | Example |
|---|---|---|---|
| LaTeX | PDF | `\documentclass{mainsub-report}` | [Chinese](gallery/latex-zh.pdf) · [English](gallery/latex-en.pdf) |
| Typst | PDF | `#import "@local/mainsub-report:0.1.0": *` | [PDF](gallery/typst-zh.pdf) |
| Quarto | HTML, PDF | `format: mainsub-html` / `mainsub-pdf` / `mainsub-typst` | [HTML](gallery/quarto.html) · [PDF](gallery/quarto-latex.pdf) · [PDF (Typst)](gallery/quarto-typst.pdf) |
| R Markdown | HTML, PDF | `output: mainsub::html_report` / `mainsub::pdf_report` | [HTML](gallery/rmd.html) · [PDF](gallery/rmd.pdf) |

* **PDF**: New Computer Modern, three-line tables, code hidden.
* **HTML**: the system's sans-serif font, folded code, a table of contents, one self-contained file.
* **Numbering** is the same in every route: Figure 1, Equation (2), Theorem 1.

## Quick start

### Quarto

```bash
quarto use template Mainsub-Linvega/mainsub-templates   # new document from the demo
quarto add Mainsub-Linvega/mainsub-templates            # or: add to an existing project
```

```yaml
lang: en
format:
  mainsub-html: default
  mainsub-pdf: default     # XeLaTeX; or mainsub-typst (both write a .pdf, pick one)
```

### R Markdown

```r
remotes::install_github("Mainsub-Linvega/mainsub-templates", subdir = "r")
rmarkdown::draft("report.Rmd", template = "report", package = "mainsub")
```

```yaml
output:
  mainsub::html_report: default
  mainsub::pdf_report: default
```

The package also provides a matching ggplot2 theme and palette (`theme_mainsub()`,
`scale_colour_mainsub()`), which both formats turn on automatically. In Quarto, call
`mainsub::use_mainsub_ggplot()` in a setup chunk.

### LaTeX and Typst

```bash
git clone https://github.com/Mainsub-Linvega/mainsub-templates
cd mainsub-templates && ./install.sh     # installs symlinks, so `git pull` updates everything

cp -r latex/template my-report && cd my-report && latexmk main.tex
typst init @local/mainsub-report:0.1.0 my-report && cd my-report && typst watch main.typ
```

Run `./install.sh --fonts` to let Typst, R graphics and matplotlib use the fonts that come with
TeX Live (New Computer Modern, STIX Two and others).

### matplotlib

```python
plt.style.use("path/to/mainsub-templates/python/mainsub.mplstyle")
```

## Options

| | LaTeX class option | Typst `report()` | Quarto YAML | R Markdown |
|---|---|---|---|---|
| Language | `lang=zh` | `lang: "zh"` | `lang: zh` | `lang: zh` |
| Font preset | `font=stix` | `font: "stix"` | `mainsub: {font: stix}` | `pdf_report(font = "stix")` |
| Review draft (line numbers + draft stamp) | `review` | `review: true` | `mainsub: {review: true}` | `pdf_report(review = TRUE)` |
| Number by section (2.1) | `numbering=section` | `numbering: "section"` | `mainsub: {numbering: section}` | `pdf_report(numbering = "section")` |
| Paper | `paper=letter` | `paper: "us-letter"` | `papersize: letter` | `papersize: letter` |

Font presets: `newcm` (default, New Computer Modern), `libertinus`, `stix` (STIX Two).

## Writing notes

* **Maths macros** such as `\E`, `\Var`, `\Normal`, `\argmin` and `\norm{}` work in every route; the full
  list is in [`core/latex/mainsub-macros.tex`](core/latex/mainsub-macros.tex). In Quarto and R Markdown,
  add your own per document with `macros: my-macros.tex`. In Typst, use `EE`, `PP`, `Var`, `argmin` and others from the package.
* **Equation numbers**: only labelled equations are numbered.
* **Chinese cross-references**: in Quarto, `第 -@sec-model 节` gives 第 2 节 and `由 @eq-x 及` gives
  由式 (1) 及; in LaTeX, write `由\cref{eq:x} 及`.
* **Citations**: Chinese documents default to GB/T 7714-2015 author-date, English ones to author-year;
  set `csl:` to change it.
* **CJK fonts** are looked up in order: Noto / Source Han, Songti, Fandol. With
  [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) installed, Chinese emphasis uses Kai; otherwise Hei.

## Requirements

* **LaTeX**: XeLaTeX, biber, and packages including `ctex`, `newcomputermodern`, `unicode-math` and
  `biblatex-gb7714-2015`.
  * Debian / Ubuntu: `sudo apt install texlive-xetex texlive-lang-chinese texlive-fonts-extra texlive-latex-extra texlive-science texlive-bibtex-extra biber fonts-noto-cjk`
  * TinyTeX: install missing packages with `tlmgr install` (the Quarto route does this automatically).
* **Typst** ≥ 0.14 (tested with 0.15).
* **Quarto** ≥ 1.6 (tested with 1.10).
* **R** ≥ 4.1 with rmarkdown, bookdown and knitr; ggplot2 and ragg suggested.
* Optional: `pngquant`, to compress images in the HTML.

## Development

The sources are in `core/` and `typst/`. `_extensions/` (the Quarto extension), `r/inst/` (the R
package's resources) and the CSL file in `typst/` are copied from them by a script; don't edit them
directly.

```bash
make sync      # copy core/ to everywhere it is needed
make gallery   # rebuild every example in gallery/
```

CI checks that the copies are in sync with `core/`.

```
core/          design sources: LaTeX style, HTML styles, pandoc filters, Quarto and R Markdown templates
typst/         the Typst package
_extensions/   the Quarto extension (generated)
r/             the R package (inst/ is generated)
latex/         LaTeX starter documents
python/        matplotlib style
gallery/       example output
scripts/       sync and build scripts
```

## Licence

MIT. `gb7714-author-date.csl` is adapted from the Citation Style Language project under CC BY-SA 3.0.
No fonts are included.
