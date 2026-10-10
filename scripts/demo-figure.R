# Regenerates the static figure used by the LaTeX and Typst example documents.
library(ggplot2)
# run from the repository root:  Rscript scripts/demo-figure.R
source("r/R/theme.R")
use_mainsub_ggplot(base_family = "Noto Sans CJK SC")
set.seed(2026)
n <- 120; p <- 6
Sigma <- 0.6^abs(outer(1:p, 1:p, "-"))
X <- matrix(rnorm(n * p), n) %*% chol(Sigma)
beta <- c(2, -1.5, 1, 0, 0, 0.5)
y <- X %*% beta + rnorm(n, sd = 2)
lam <- exp(seq(log(0.05), log(2000), length.out = 120))
B <- sapply(lam, function(l) solve(crossprod(X) + l * diag(p), crossprod(X, y)))
df <- data.frame(loglam = rep(log(lam), each = p), coef = as.vector(B),
                 j = factor(rep(paste0("β", 1:p), times = length(lam))))
g <- ggplot(df, aes(loglam, coef, colour = j)) +
  geom_hline(yintercept = 0, colour = "#9A9A9A", linewidth = 0.3) +
  geom_line(linewidth = 0.6) +
  labs(x = expression(log~lambda), y = "系数估计", colour = NULL) +
  guides(colour = guide_legend(nrow = 1))
for (d in c("latex/template/figures", "typst/template/figures")) {
  ggsave(file.path(d, "ridge-path.pdf"), g, width = 6.2, height = 3.2, device = cairo_pdf)
}
