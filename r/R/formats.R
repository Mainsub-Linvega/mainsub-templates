res_file <- function(...) {
  f <- system.file("rmarkdown", "resources", ..., package = "mainsub")
  if (!nzchar(f)) stop("mainsub resource not found: ", file.path(...), call. = FALSE)
  f
}

`%||%` <- function(x, y) if (is.null(x)) y else x

doc_is_zh <- function(metadata = rmarkdown::metadata) {
  lang <- metadata$lang %||% ""
  startsWith(tolower(as.character(lang)), "zh")
}

# knitr's markdown source hook, wrapped in <details> so code folds without any JavaScript.
fold_source_hook <- function(default_fold) {
  base <- knitr::hooks_markdown()$source
  function(x, options) {
    out <- base(x, options)
    fold <- options$code_folding %||% default_fold
    if (identical(fold, "none") || isFALSE(options$echo)) return(out)
    label <- options$code_summary %||% if (doc_is_zh()) "\u4ee3\u7801" else "Code"
    open <- if (identical(fold, "show")) " open" else ""
    paste0("\n\n<details class=\"ms-fold\"", open, "><summary>", label, "</summary>\n\n",
           out, "\n\n</details>\n\n")
  }
}

# bookdown's labels ("Figure 1", "Theorem 1", ...) in Chinese when lang: zh, unless the
# project has its own _bookdown.yml. bookdown reads them from its (internal) config.
zh_labels <- list(
  fig = "\u56fe ", tab = "\u8868 ", eq = "\u5f0f ", thm = "\u5b9a\u7406 ", lem = "\u5f15\u7406 ",
  cor = "\u63a8\u8bba ", prp = "\u547d\u9898 ", cnj = "\u731c\u60f3 ", def = "\u5b9a\u4e49 ",
  exm = "\u4f8b ", exr = "\u4e60\u9898 ", hyp = "\u5047\u8bbe ",
  proof = "\u8bc1\u660e ", remark = "\u6ce8 ", solution = "\u89e3 "
)
set_bookdown_language <- function(input = NULL) {
  if (file.exists("_bookdown.yml")) return(invisible())
  opts <- utils::getFromNamespace("opts", "bookdown")
  if (!doc_is_zh()) return(invisible())
  cfg <- opts$get("config")
  cfg$language$label <- utils::modifyList(zh_labels, as.list(cfg$language$label))
  opts$set(config = cfg)
  invisible()
}

# Make mainsub.sty and mainsub-macros.tex visible to (Xe)LaTeX without copying them.
add_texinputs <- function() {
  dir <- dirname(res_file("mainsub.sty"))
  old <- Sys.getenv("TEXINPUTS")
  if (!grepl(dir, old, fixed = TRUE)) {
    sep <- .Platform$path.sep
    Sys.setenv(TEXINPUTS = paste0(dir, "//", sep, if (nzchar(old)) old else ""))
  }
  invisible(dir)
}

#' PDF report (XeLaTeX) with the mainsub design
#'
#' A thin wrapper around [bookdown::pdf_document2()]: cross-references with
#' `\@ref()`, theorem environments, numbered equations, and the typography of
#' `mainsub.sty` (the same file the LaTeX class and the Quarto extension use).
#'
#' Set `lang: zh` in the YAML header for Chinese conventions (Chinese captions, 2em indent,
#' GB/T 7714 citations).
#'
#' @param toc,number_sections,keep_tex As in [rmarkdown::pdf_document()].
#' @param fig_width,fig_height Default figure size in inches (text width is about 5.4 in).
#' @param dev Graphics device; `"cairo_pdf"` handles Chinese labels.
#' @param echo Show code chunks? Reports usually hide them in print.
#' @param review Line numbers and a "draft" stamp, for drafts you send for comments.
#' @param font `"newcm"` (New Computer Modern), `"libertinus"` or `"stix"`.
#' @param numbering `"plain"` (1, 2, 3) or `"section"` (2.1, 2.2) for theorems and equations.
#' @param pandoc_args,... Passed on to [bookdown::pdf_document2()].
#' @export
pdf_report <- function(toc = FALSE, number_sections = TRUE, fig_width = 6.2, fig_height = 3.6,
                       dev = "cairo_pdf", echo = FALSE, review = FALSE,
                       font = c("newcm", "libertinus", "stix"), numbering = c("plain", "section"),
                       keep_tex = FALSE, pandoc_args = NULL, ...) {
  font <- match.arg(font)
  numbering <- match.arg(numbering)
  add_texinputs()
  opts <- paste0("font=", font, ",numbering=", numbering, if (review) ",review")
  fmt <- bookdown::pdf_document2(
    toc = toc, number_sections = number_sections, global_numbering = TRUE,
    fig_width = fig_width, fig_height = fig_height, fig_crop = FALSE, dev = dev,
    highlight = res_file("mainsub.theme"), template = res_file("mainsub.tex"),
    latex_engine = "xelatex", keep_tex = keep_tex, citation_package = "default",
    pandoc_args = c(
      "--lua-filter", res_file("mainsub.lua"),
      "--lua-filter", res_file("mainsub-post.lua"),
      "--variable", paste0("mainsub-opts=", opts),
      pandoc_args
    ),
    ...
  )
  fmt$knitr$opts_chunk$echo <- echo
  fmt$knitr$opts_chunk$fig.align <- "center"
  fmt$knitr$opts_chunk$fig.pos <- "htbp"
  fmt$pre_knit <- chain(fmt$pre_knit, function(...) { set_bookdown_language(); use_mainsub_ggplot() })
  fmt
}

#' Small, self-contained HTML report with the mainsub design
#'
#' No Bootstrap and no jQuery: one stylesheet, a dozen lines of script for the
#' table of contents, code folding with plain `<details>`, figures at a sensible
#' resolution (and squeezed with pngquant when it is installed), maths through
#' MathJax 4 loaded from a CDN. A typical report is a few hundred kilobytes.
#'
#' @param toc,number_sections As in [rmarkdown::html_document()].
#' @param code_folding `"hide"` (default), `"show"` or `"none"`. Per chunk: `code_folding: show`.
#' @param self_contained Embed figures and CSS into the single .html file.
#' @param fig_width,fig_height Figure size in inches.
#' @param dpi,fig_retina Figure resolution: 96 x 2 gives crisp figures at a modest size.
#' @param mathjax URL of the MathJax 4 script; `NULL` turns maths rendering off.
#' @param pandoc_args,... Passed on to [rmarkdown::html_document_base()].
#' @export
html_report <- function(toc = TRUE, number_sections = TRUE, code_folding = c("hide", "show", "none"),
                        self_contained = TRUE, fig_width = 7, fig_height = 4.2, dpi = 96, fig_retina = 2,
                        mathjax = "https://cdn.jsdelivr.net/npm/mathjax@4/tex-chtml.js",
                        pandoc_args = NULL, ...) {
  code_folding <- match.arg(code_folding)
  base <- function(..., number_sections = TRUE, pandoc_args = NULL) {
    args <- c(
      "--template", res_file("mainsub.html"),
      "--section-divs",
      "--highlight-style", res_file("mainsub.theme"),
      "--lua-filter", res_file("mainsub.lua"),
      "--lua-filter", res_file("mainsub-post.lua"),
      "--metadata", "abstract-title=Abstract",
      if (toc) c("--toc", "--toc-depth", "3"),
      if (number_sections) "--number-sections",
      if (!is.null(mathjax)) c("--mathjax", "--include-in-header", res_file("mathjax-config.html"),
                               "--variable", paste0("mainsub-mathjax-url=", mathjax)),
      pandoc_args
    )
    rmarkdown::output_format(
      knitr = rmarkdown::knitr_options(
        opts_chunk = list(
          echo = TRUE, fig.width = fig_width, fig.height = fig_height, dpi = dpi,
          fig.retina = fig_retina, fig.align = "center",
          dev = if (requireNamespace("ragg", quietly = TRUE)) "ragg_png" else "png"
        ),
        knit_hooks = list(source = fold_source_hook(code_folding))
      ),
      # html4 keeps <div class="section"> wrappers, which bookdown's reference resolver expects
      pandoc = rmarkdown::pandoc_options(to = "html4", from = rmarkdown::from_rmarkdown(), args = args),
      keep_md = FALSE,
      clean_supporting = self_contained,
      pre_knit = function(...) { set_bookdown_language(); use_mainsub_ggplot() },
      base_format = rmarkdown::html_document_base(
        theme = NULL, self_contained = self_contained, mathjax = NULL,
        css = res_file("mainsub.css"), template = res_file("mainsub.html"), ...
      )
    )
  }
  # global_numbering: Figure 1, 2, 3 (not 3.1), the same as the LaTeX, Typst and Quarto routes
  bookdown::html_document2(base_format = base, number_sections = number_sections,
                           global_numbering = TRUE, pandoc_args = pandoc_args)
}

chain <- function(f, g) {
  if (is.null(f)) return(g)
  function(...) { f(...); g(...) }
}
