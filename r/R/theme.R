#' Colours of the mainsub design
#'
#' `ink` is the text colour, `muted` the secondary grey, `rule` the colour of
#' hairlines and grids, `accent` the single accent (links, highlights).
#' `palette` is Paul Tol's colour-blind-safe "muted" scheme, reordered so that
#' the first two or three colours are the most distinguishable in print.
#' @export
mainsub_colors <- list(
  ink    = "#1A1A1A",
  muted  = "#6B6B6B",
  rule   = "#E2E0DA",
  accent = "#7B2D26",
  palette = c("#332288", "#CC6677", "#117733", "#882255", "#44AA99",
              "#999933", "#AA4499", "#88CCEE", "#DDCC77")
)

#' A quiet ggplot2 theme that matches the documents
#'
#' No grey panel, no box, hairline grid on one axis only, left-aligned titles,
#' legend on top. Sized for figures that are 6-7 inches wide in the document.
#'
#' @param base_size Base font size in points.
#' @param base_family Font family. `""` uses the graphics device default; with
#'   ragg / svglite / cairo_pdf any installed family (including CJK) works.
#' @param grid Which major grid lines to draw: `"y"`, `"x"`, `"xy"` or `"none"`.
#' @export
theme_mainsub <- function(base_size = 10, base_family = "", grid = "y") {
  col <- mainsub_colors
  gridline <- ggplot2::element_line(colour = col$rule, linewidth = 0.3)
  blank <- ggplot2::element_blank()
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = col$ink),
      axis.text = ggplot2::element_text(colour = col$muted, size = ggplot2::rel(0.85)),
      axis.title = ggplot2::element_text(colour = col$ink, size = ggplot2::rel(0.9)),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 6)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 6)),
      axis.line.x = ggplot2::element_line(colour = col$ink, linewidth = 0.3),
      axis.ticks = ggplot2::element_line(colour = col$muted, linewidth = 0.3),
      axis.ticks.length = ggplot2::unit(2.5, "pt"),
      panel.grid.minor = blank,
      panel.grid.major.x = if (grepl("x", grid)) gridline else blank,
      panel.grid.major.y = if (grepl("y", grid)) gridline else blank,
      plot.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.05),
                                         hjust = 0, margin = ggplot2::margin(b = 4)),
      plot.subtitle = ggplot2::element_text(colour = col$muted, hjust = 0,
                                            margin = ggplot2::margin(b = 8)),
      plot.caption = ggplot2::element_text(colour = col$muted, size = ggplot2::rel(0.8),
                                           hjust = 0, margin = ggplot2::margin(t = 6)),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      legend.position = "top",
      legend.justification = "left",
      legend.title = ggplot2::element_text(colour = col$muted, size = ggplot2::rel(0.85)),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.85)),
      legend.key.size = ggplot2::unit(10, "pt"),
      legend.margin = ggplot2::margin(0, 0, 0, 0),
      legend.box.spacing = ggplot2::unit(4, "pt"),
      strip.text = ggplot2::element_text(face = "bold", hjust = 0, size = ggplot2::rel(0.9),
                                         margin = ggplot2::margin(b = 4)),
      panel.spacing = ggplot2::unit(10, "pt"),
      plot.margin = ggplot2::margin(4, 8, 4, 4)
    )
}

#' Discrete colour / fill scales with the mainsub palette
#' @param ... Passed to [ggplot2::discrete_scale()].
#' @export
scale_colour_mainsub <- function(...) {
  ggplot2::discrete_scale("colour", palette = function(n) mainsub_colors$palette[seq_len(n)], ...)
}
#' @rdname scale_colour_mainsub
#' @export
scale_color_mainsub <- scale_colour_mainsub
#' @rdname scale_colour_mainsub
#' @export
scale_fill_mainsub <- function(...) {
  ggplot2::discrete_scale("fill", palette = function(n) mainsub_colors$palette[seq_len(n)], ...)
}

#' Make the mainsub look the ggplot2 default for this session
#'
#' Sets [theme_mainsub()] as the default theme, the mainsub palette as the
#' default discrete scale, and dark-ink defaults for single-series geoms.
#' Called automatically by [pdf_report()] and [html_report()]; call it yourself
#' in a Quarto document's setup chunk.
#' @inheritParams theme_mainsub
#' @export
use_mainsub_ggplot <- function(base_size = 10, base_family = "") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) return(invisible(FALSE))
  ggplot2::theme_set(theme_mainsub(base_size = base_size, base_family = base_family))
  options(
    ggplot2.discrete.colour = mainsub_colors$palette,
    ggplot2.discrete.fill   = mainsub_colors$palette
  )
  ink <- "#2B2B2B"
  for (g in c("point", "line", "path", "step", "segment", "abline", "hline", "vline", "smooth"))
    try(ggplot2::update_geom_defaults(g, list(colour = ink)), silent = TRUE)
  try(ggplot2::update_geom_defaults("smooth", list(fill = "#C9C6BF")), silent = TRUE)
  for (g in c("bar", "col", "histogram", "area", "density", "boxplot", "violin"))
    try(ggplot2::update_geom_defaults(g, list(fill = "#B9B6AE", colour = NA)), silent = TRUE)
  try(ggplot2::update_geom_defaults("boxplot", list(colour = ink, fill = "#E9E7E1")), silent = TRUE)
  try(ggplot2::update_geom_defaults("violin", list(colour = ink, fill = "#E9E7E1")), silent = TRUE)
  invisible(TRUE)
}
