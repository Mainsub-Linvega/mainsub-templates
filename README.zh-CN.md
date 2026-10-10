# mainsub-templates

[English](README.md)

一套克制的报告设计，落在六条路线上：

| 路线 | 输出 | 入口 |
|---|---|---|
| LaTeX | PDF | `\documentclass{mainsub-report}` |
| Typst | PDF | `#import "@local/mainsub-report:0.1.0": *` |
| R Markdown | PDF | `output: mainsub::pdf_report` |
| R Markdown | HTML | `output: mainsub::html_report` |
| Quarto | PDF | `format: mainsub-pdf`（XeLaTeX）或 `mainsub-typst` |
| Quarto | HTML | `format: mainsub-html` |

同一份示例文档经每条路线的输出都在 [`gallery/`](gallery/) 里：
[LaTeX](gallery/latex-zh.pdf) ·
[LaTeX 英文](gallery/latex-en.pdf) ·
[Typst](gallery/typst-zh.pdf) ·
[Quarto → PDF](gallery/quarto-latex.pdf) ·
[Quarto → Typst](gallery/quarto-typst.pdf) ·
[Quarto → HTML](gallery/quarto.html) ·
[R Markdown → PDF](gallery/rmd.pdf) ·
[R Markdown → HTML](gallery/rmd.html)

## 设计思路：两档，一个身份

**PDF 是印刷品。** 给导师看、批注、存档。版面固定，所以按 LaTeX 讲义的规矩排：
New Computer Modern 的 *Book* 字重（比常规字重更“实”，能和思源宋体 / Noto Serif CJK 站在一起），
中文强调用楷体，节号悬挂在左边距，三线表，默认不显示代码。

**HTML 是屏幕。** 给同学在手机或电脑上打开。文字要重排，所以用各系统自带的无衬线字体
（不下载、不嵌入任何网络字体），代码显示但默认折叠，有目录，文件尽量小。

两档之间延续的是结构而不是字体：同样的标题层级、同样的编号（图 1、式 (2)、定理 1——
不会出现一条路线是 3.1、另一条是 1）、同样的三线表、同样的数学字体（MathJax 4 渲染的
也是 New Computer Modern）、同样的六种颜色。全套只有一个强调色——深酒红，只用于网址和草稿标记。

## 快速开始

### Quarto（一份 `.qmd` 同时出 HTML 与 PDF）

```bash
quarto use template Mainsub-Linvega/mainsub-templates   # 用示例新建文档
quarto add Mainsub-Linvega/mainsub-templates            # 或：加到已有项目
```

```yaml
lang: zh
format:
  mainsub-html: default    # 一个自包含的 .html，发给同学
  mainsub-pdf: default     # XeLaTeX，发给导师
  # mainsub-typst: default # 或者：同样的设计，Typst 编译，约一秒（都输出 .pdf，二选一）
```

### R Markdown

```r
remotes::install_github("Mainsub-Linvega/mainsub-templates", subdir = "r")
rmarkdown::draft("report.Rmd", template = "report", package = "mainsub")
```

```yaml
output:
  mainsub::html_report: default
  mainsub::pdf_report:
    review: true         # 行号 + “草稿”标记，方便导师批注
```

R 包还提供 `theme_mainsub()`、`scale_colour_mainsub()` 和 `use_mainsub_ggplot()`
（两个格式会自动调用；在 Quarto 的 setup 代码块里手动调用即可），让图和正文是一套风格。

### LaTeX 与 Typst

```bash
git clone https://github.com/Mainsub-Linvega/mainsub-templates
cd mainsub-templates && ./install.sh        # 建软链接；以后 git pull 即全部更新

cp -r latex/template my-report && cd my-report && latexmk main.tex
typst init @local/mainsub-report:0.1.0 my-report && cd my-report && typst watch main.typ
```

`./install.sh --fonts` 会把 TeX Live 自带的 OpenType 字体登记给 fontconfig，
这样 Typst、R 图形、matplotlib 也能用 New Computer Modern Book、STIX Two、Inconsolata。

### matplotlib

```python
plt.style.use("path/to/mainsub-templates/python/mainsub.mplstyle")
```

## 选项

| | LaTeX 类选项 | Typst `report()` | Quarto YAML | R Markdown |
|---|---|---|---|---|
| 语言 | `lang=zh` | `lang: "zh"` | `lang: zh` | `lang: zh` |
| 字体方案 | `font=stix` | `font: "stix"` | `mainsub: {font: stix}` | `pdf_report(font = "stix")` |
| 审阅稿 | `review` | `review: true` | `mainsub: {review: true}` | `pdf_report(review = TRUE)` |
| 按节编号 2.1 | `numbering=section` | `numbering: "section"` | `mainsub: {numbering: section}` | `pdf_report(numbering = "section")` |
| 纸张 | `paper=letter` | `paper: "us-letter"` | `papersize: letter` | `papersize: letter` |

字体方案：`newcm`（默认，New Computer Modern Book + Math）、`libertinus`、`stix`（STIX Two）。

## 写作提示

* **数学宏**：`\E`、`\Prob`、`\Var`、`\Cov`、`\Bias`、`\MSE`、`\Normal`、`\iid`、`\indep`、
  `\R`、`\tr`、`\diag`、`\argmin`、`\argmax`、`\norm{}`、`\abs{}`、`\inner{}{}` 等在所有路线通用，
  定义在 [`core/latex/mainsub-macros.tex`](core/latex/mainsub-macros.tex)。LaTeX 直接读这个文件；
  HTML 与 Typst 在编译时就把宏展开，MathJax 不需要知道它们。单个文档可以用
  `macros: my-macros.tex` 追加。Typst 里用包提供的 `EE`、`PP`、`Var`、`argmin` 等。
* **只有带标签的公式才编号**（Quarto 的规则，Typst 也照此处理）。
* **中文交叉引用**：Quarto 里 `第 -@sec-model 节` 得到“第 2 节”；`由 @eq-x 及` 得到“由式 (1) 及”——
  源文件里必须留的空格，输出时会被去掉。LaTeX 里写 `由\cref{eq:x} 及`，其余交给 xeCJK。
* **参考文献**：中文文档默认 GB/T 7714-2015 著者-出版年制（英文姓名不全大写）；英文文档默认作者-年份制。
  用 `csl:` 覆盖。
* **中文字体**按名称依次查找：Noto / 思源 → 宋体类 → Fandol（TeX Live 自带）。装上
  [霞鹜文楷](https://github.com/lxgw/LxgwWenKai) 后，中文强调会变成楷体；没有楷体时退回黑体。

## 为什么之前的 HTML 有 10 MB，这里怎么做

`dpi: 200` 加 `fig.retina: 2` 加 `fig-width: 9`，每张 PNG 宽 3600 像素——是视网膜屏能显示的四倍；
几千个半透明点的散点图在这个尺寸下约 1 MB 一张。`self-contained-math: true` 又塞进 1.3 MB 的
MathJax，可数学字体*仍然*要从 CDN 下载。

这里的 HTML 格式用 96 dpi × retina 2（清晰，约 1300 像素宽），装了 `pngquant` 就自动压缩生成的
PNG（再小约 60%），从不嵌入 MathJax，也不嵌入网络字体。R Markdown 的 HTML 完全不用 Bootstrap 和
jQuery：示例文档 110 kB。Quarto 自带的 Bootstrap 给它的 HTML 垫了约 1.2 MB 的底。

## 仓库结构

```
core/         唯一的“源头”——改这里
  latex/      mainsub.sty（设计本身）、mainsub-report.cls、mainsub-macros.tex
  html/       base.css（两条 HTML 路线共用）、quarto.css、rmd.css、MathJax 配置
  filters/    Quarto 与 R Markdown 共用的 pandoc Lua 过滤器
  quarto/     扩展的清单与模板片段
  rmd/        R Markdown 格式背后的 pandoc 模板
typst/        Typst 包（mainsub.typ 是同一设计的 Typst 实现）
_extensions/  Quarto 扩展——由脚本生成，放在根目录以便 quarto add 找到
r/            R 包——inst/ 由脚本生成
latex/        LaTeX 起步文档
python/       matplotlib 样式
gallery/      示例文档经各路线的输出
scripts/      sync.sh（core/ → 各副本）、gallery.sh（全部重编）、demo-figure.R
```

改完 `core/` 里的任何东西，运行 `make sync`（复制到 `_extensions/`、`typst/`、`r/inst/`），
再 `make gallery` 重编所有路线、逐一看一遍。副本没同步时 CI 会报错。

## 依赖

* LaTeX 路线：XeLaTeX，以及 `ctex`、`newcomputermodern`、`unicode-math`、`biblatex-gb7714-2015`、`biber`
  （Debian：`texlive-xetex texlive-lang-chinese texlive-fonts-extra texlive-latex-extra texlive-science
  texlive-bibtex-extra biber`），外加 `fonts-noto-cjk`。
* Typst ≥ 0.14（在 0.15 上测试）。Quarto ≥ 1.6（在 1.10 上测试）。
* R ≥ 4.1，rmarkdown、bookdown、knitr；建议 ggplot2、ragg。
* 可选：`pngquant`，让 HTML 更小。

## 许可

MIT。`gb7714-author-date.csl` 改编自 Citation Style Language 项目，遵循 CC BY-SA 3.0。不附带任何字体。
