// Compile:  typst compile main.typ        (watch: typst watch main.typ)
// Options of report(): lang "zh" | "en", font "newcm" | "libertinus" | "stix",
//                      review: true (line numbers + draft stamp), numbering: "section", toc: true,
//                      fonts: (cjk-serif: (...), cjk-kai: ("LXGW WenKai",), mono: (...))
// Citations: @key gives (Author, 2020); #cite(<key>, form: "prose") gives Author (2020).
// Only labelled display equations are numbered, as in Quarto.
#import "@local/mainsub-report:0.1.0": *

#show: report.with(
  title: [岭回归中的偏差—方差权衡],
  subtitle: [一份模板演示：数学、图表、代码与交叉引用],
  authors: ("Mainsub",),
  affiliation: [中国科学技术大学],
  abstract: [
    本文以岭回归为例演示模板的排版效果。我们在高斯线性模型下推导岭估计量的偏差与方差，
    说明适度的收缩如何以少量偏差换取方差的显著下降，并用一个模拟实验验证这一结论。
  ],
  keywords: ("岭回归", "偏差—方差分解", "收缩估计"),
  lang: "zh",
)

= 引言

当设计矩阵 $X$ 的列高度相关时，最小二乘估计 $hat(beta) = (X^top X)^(-1) X^top y$ 的方差会急剧膨胀。
#cite(<hoerl1970ridge>, form: "prose") 提出在 $X^top X$ 的对角线上加入一个正常数，以_牺牲无偏性为代价_换取更稳定的估计；
这一思想后来成为收缩估计（shrinkage estimation）的基石 @hastie2009elements。
关于线性模型的经典理论，可参考 #cite(<chen1999advanced>, form: "prose")。#footnote[本文所有数值结果均可由附录中的代码复现。]

本文的结构如下：@sec-model 给出模型与估计量，@sec-sim 给出数值示例。

= 模型与估计量 <sec-model>

== 设定

#assumption(title: [高斯线性模型])[
  观测满足 $y = X beta + epsilon$，其中 $X in RR^(n times p)$ 为固定设计，$epsilon tilde Normal(0, sigma^2 I_n)$。
] <asm-gauss>

#definition(title: [岭估计量])[
  对给定的 $lambda > 0$，岭估计量定义为
  $ hat(beta)_lambda
    = argmin_(b in RR^p) {norm(y - X b)_2^2 + lambda norm(b)_2^2}
    = (X^top X + lambda I_p)^(-1) X^top y. $ <eq-ridge>
]

== 偏差与方差

记 $X = U D V^top$ 为奇异值分解，$d_1 >= dots.c >= d_p > 0$ 为奇异值。

#proposition[
  在 @asm-gauss 下，岭估计量的偏差与协方差分别为
  $ Bias(hat(beta)_lambda) = -lambda (X^top X + lambda I_p)^(-1) beta, $ <eq-bias>
  $ Var(hat(beta)_lambda) = sigma^2 sum_(j=1)^p d_j^2 / (d_j^2 + lambda)^2 v_j v_j^top. $ <eq-var>
  因此 $tr Var(hat(beta)_lambda)$ 关于 $lambda$ 严格递减，而当 $beta != 0$ 时 $norm(Bias(hat(beta)_lambda))_2^2$ 严格递增。
] <prop-bv>

#proof[
  由 @eq-ridge 及 $EE y = X beta$ 得 $EE hat(beta)_lambda = (X^top X + lambda I)^(-1) X^top X beta$，
  两边减去 $beta$ 即得 @eq-bias。又 $Var(y) = sigma^2 I_n$，代入奇异值分解
  $(X^top X + lambda I)^(-1) X^top = V diag(d_j \/ (d_j^2 + lambda)) U^top$ 即得 @eq-var。
]

#remark[
  当 $lambda -> 0$ 时 $hat(beta)_lambda$ 收敛到最小二乘估计；当 $lambda -> infinity$ 时 $hat(beta)_lambda -> 0$。
  均方误差 $MSE(lambda) = norm(Bias)_2^2 + tr Var$ 在两者之间取得最小值。
]

= 数值示例 <sec-sim>

我们取 $n = 120$、$p = 6$，设计矩阵的行独立服从 $Normal(0, Sigma)$，其中 $Sigma_(i j) = 0.6^abs(i - j)$，
真实系数 $beta = (2, -1.5, 1, 0, 0, 0.5)^top$，$sigma = 2$。@fig-path 给出系数随 $lambda$ 的收缩路径，
@tab-mse 给出由 @eq-bias 与 @eq-var 精确计算的风险分解。

#figure(
  image("figures/ridge-path.pdf", width: 100%),
  caption: [岭回归的系数路径。随着 $lambda$ 增大，所有系数被连续地压向零。],
) <fig-path>

#figure(
  table(
    columns: 4,
    align: right,
    table.header[$lambda$][$norm(Bias)_2^2$][$tr Var$][$MSE$],
    [0], [0.000], [0.449], [0.449],
    [1], [0.008], [0.424], [0.432],
    [2], [0.029], [0.402], [*0.430*],
    [5], [0.148], [0.345], [0.493],
    [20], [1.110], [0.195], [1.305],
    [100], [4.030], [0.048], [4.078],
  ),
  caption: [不同 $lambda$ 下的偏差、方差与均方误差],
) <tab-mse>

从 @tab-mse 可以读出三点：
+ 方差随 $lambda$ 单调下降，偏差单调上升，与 @prop-bv 一致；
+ 在 $lambda = 2$ 附近，MSE 低于最小二乘（$lambda = 0$）；
+ 过度收缩（$lambda = 100$）使偏差主导风险。

计算岭估计量只需要一行线性代数：

```r
ridge <- function(X, y, lambda) {
  p <- ncol(X)
  solve(crossprod(X) + lambda * diag(p), crossprod(X, y))  # 求解正规方程
}
```

= 结论

岭回归说明了统计学中一个反复出现的主题：_无偏并不等于好_。在实践中，$lambda$ 通常由交叉验证选取。

#bibliography("references.bib")

#show: appendix

= 补充推导 <app-extra>

在正交设计 $X^top X = I_p$ 下，岭估计量是最小二乘估计的简单缩放：
$ hat(beta)_lambda = 1 / (1 + lambda) hat(beta)^"OLS", quad
  MSE(lambda) = (p sigma^2 + lambda^2 norm(beta)_2^2) / (1 + lambda)^2, $
其最小值在 $lambda^star = p sigma^2 \/ norm(beta)_2^2$ 处取得。
