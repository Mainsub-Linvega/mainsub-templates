# mainsub-templates

[English](README.md)

一套简洁的学术报告模板，支持 LaTeX、Typst、Quarto 和 R Markdown。
PDF 适合打印和批注，HTML 适合在屏幕上阅读；各路线的标题层级、编号、表格和数学字体保持一致。

| 路线 | 输出 | 入口 | 示例 |
|---|---|---|---|
| LaTeX | PDF | `\documentclass{mainsub-report}` | [中文](gallery/latex-zh.pdf) · [英文](gallery/latex-en.pdf) |
| Typst | PDF | `#import "@local/mainsub-report:0.1.0": *` | [PDF](gallery/typst-zh.pdf) |
| Quarto | HTML、PDF | `format: mainsub-html` / `mainsub-pdf` / `mainsub-typst` | [HTML](gallery/quarto.html) · [PDF](gallery/quarto-latex.pdf) · [PDF（Typst）](gallery/quarto-typst.pdf) |
| R Markdown | HTML、PDF | `output: mainsub::html_report` / `mainsub::pdf_report` | [HTML](gallery/rmd.html) · [PDF](gallery/rmd.pdf) |

* **PDF**：New Computer Modern 字体，三线表，默认不显示代码。
* **HTML**：系统自带的无衬线字体，代码默认折叠，带目录，单个自包含文件。
* **编号**：所有路线统一为“图 1、式 (2)、定理 1”。

## 快速开始

### Quarto

```bash
quarto use template Mainsub-Linvega/mainsub-templates   # 用示例文档新建
quarto add Mainsub-Linvega/mainsub-templates            # 或：加到已有项目
```

```yaml
lang: zh
format:
  mainsub-html: default
  mainsub-pdf: default     # XeLaTeX；也可换成 mainsub-typst（两者都输出 .pdf，二选一）
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

R 包还提供与正文风格一致的 ggplot2 主题和配色（`theme_mainsub()`、`scale_colour_mainsub()`），
两个格式会自动启用。在 Quarto 中使用时，在 setup 代码块里调用 `mainsub::use_mainsub_ggplot()`。

### LaTeX 与 Typst

```bash
git clone https://github.com/Mainsub-Linvega/mainsub-templates
cd mainsub-templates && ./install.sh     # 以软链接安装，之后 git pull 即可更新

cp -r latex/template my-report && cd my-report && latexmk main.tex
typst init @local/mainsub-report:0.1.0 my-report && cd my-report && typst watch main.typ
```

运行 `./install.sh --fonts`，可让 Typst、R 图形和 matplotlib 使用 TeX Live 自带的字体
（New Computer Modern、STIX Two 等）。

### matplotlib

```python
plt.style.use("path/to/mainsub-templates/python/mainsub.mplstyle")
```

## 选项

| | LaTeX 类选项 | Typst `report()` | Quarto YAML | R Markdown |
|---|---|---|---|---|
| 语言 | `lang=zh` | `lang: "zh"` | `lang: zh` | `lang: zh` |
| 字体方案 | `font=stix` | `font: "stix"` | `mainsub: {font: stix}` | `pdf_report(font = "stix")` |
| 审阅稿（行号 + 草稿标记） | `review` | `review: true` | `mainsub: {review: true}` | `pdf_report(review = TRUE)` |
| 按节编号（2.1） | `numbering=section` | `numbering: "section"` | `mainsub: {numbering: section}` | `pdf_report(numbering = "section")` |
| 纸张 | `paper=letter` | `paper: "us-letter"` | `papersize: letter` | `papersize: letter` |

字体方案：`newcm`（默认，New Computer Modern）、`libertinus`、`stix`（STIX Two）。

## 写作提示

* **数学宏**：`\E`、`\Var`、`\Normal`、`\argmin`、`\norm{}` 等常用宏在所有路线中通用，完整列表见
  [`core/latex/mainsub-macros.tex`](core/latex/mainsub-macros.tex)。Quarto 和 R Markdown 中可用 `macros: my-macros.tex` 为单个文档追加；
  Typst 中使用包提供的 `EE`、`PP`、`Var`、`argmin` 等。
* **公式编号**：只有带标签的公式才编号。
* **中文交叉引用**：Quarto 中 `第 -@sec-model 节` 输出“第 2 节”，`由 @eq-x 及` 输出“由式 (1) 及”；
  LaTeX 中写 `由\cref{eq:x} 及`。
* **参考文献**：中文默认 GB/T 7714-2015 著者-出版年制，英文默认作者-年份制；可用 `csl:` 替换。
* **中文字体**：依次查找 Noto / 思源、宋体、Fandol。安装[霞鹜文楷](https://github.com/lxgw/LxgwWenKai)后，
  中文强调使用楷体，否则使用黑体。

## 依赖

* **LaTeX**：XeLaTeX、biber，以及 `ctex`、`newcomputermodern`、`unicode-math`、`biblatex-gb7714-2015` 等宏包。
  * Debian / Ubuntu：`sudo apt install texlive-xetex texlive-lang-chinese texlive-fonts-extra texlive-latex-extra texlive-science texlive-bibtex-extra biber fonts-noto-cjk`
  * TinyTeX：缺少的宏包用 `tlmgr install` 补装（Quarto 路线会自动补装）。
* **Typst** ≥ 0.14（在 0.15 上测试）。
* **Quarto** ≥ 1.6（在 1.10 上测试）。
* **R** ≥ 4.1，需要 rmarkdown、bookdown、knitr；建议安装 ggplot2、ragg。
* 可选：`pngquant`，用于压缩 HTML 中的图片。

## 开发

源文件在 `core/` 和 `typst/`。`_extensions/`（Quarto 扩展）、`r/inst/`（R 包资源）以及 `typst/` 中的 CSL 文件
由脚本复制生成，不要直接修改。

```bash
make sync      # 把 core/ 复制到各处
make gallery   # 重新编译 gallery/ 中的所有示例
```

CI 会检查各处副本是否与 `core/` 同步。

```
core/          设计源文件：LaTeX 样式、HTML 样式、pandoc 过滤器、Quarto 与 R Markdown 模板
typst/         Typst 包
_extensions/   Quarto 扩展（生成）
r/             R 包（inst/ 为生成）
latex/         LaTeX 起步文档
python/        matplotlib 样式
gallery/       示例输出
scripts/       同步与构建脚本
```

## 许可

MIT。`gb7714-author-date.csl` 改编自 Citation Style Language 项目，采用 CC BY-SA 3.0 许可。仓库不包含字体文件。
