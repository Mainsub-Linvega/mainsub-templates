// mainsub.typ — the mainsub report design for Typst (>= 0.14).
//
//   #import "@local/mainsub-report:0.1.0": *
//   #show: report.with(title: [...], lang: "zh")
//
// Same rules as the LaTeX version: one ink colour, one muted accent for URLs,
// hanging section numbers, three-line tables, no boxes.

// ---------------------------------------------------------------- palette
#let ink = rgb("#1A1A1A")
#let muted = rgb("#6B6B6B")
#let rule-color = rgb("#9A9A9A")
#let accent = rgb("#7B2D26")
#let code-bg = rgb("#F6F5F1")

// ---------------------------------------------------------------- fonts
// Latin + maths presets. Typst ships New Computer Modern (text and maths) and
// Libertinus Serif; STIX Two and Libertinus Math must be installed or reachable
// through --font-path (TeX Live's opentype directory works).
#let _presets = (
  newcm: (serif: "New Computer Modern", sans: "New Computer Modern Sans", math: "New Computer Modern Math", math-weight: 450),
  libertinus: (serif: "Libertinus Serif", sans: "Libertinus Sans", math: "Libertinus Math", math-weight: "regular"),
  stix: (serif: "STIX Two Text", sans: "New Computer Modern Sans", math: "STIX Two Math", math-weight: "regular"),
)
// CJK and code fonts. Typst warns about every listed family that is not
// installed, so the defaults name only what a Linux box with Noto CJK has;
// anything missing still renders through Typst's automatic glyph fallback.
// Override per document, e.g. on macOS:
//   #show: report.with(fonts: (cjk-serif: ("Songti SC",), cjk-kai: ("Kaiti SC",)))
#let default-fonts = (
  cjk-serif: ("Noto Serif CJK SC",),
  cjk-sans: ("Noto Sans CJK SC",),
  cjk-kai: (),                       // e.g. ("LXGW WenKai",): Chinese emphasis in Kai instead of Hei
  mono: ("DejaVu Sans Mono",),       // e.g. ("Inconsolatazi4",) with TeX Live fonts on the font path
)

// ---------------------------------------------------------------- words
#let _words = (
  en: (abstract: "Abstract", keywords: "Keywords", proof: "Proof", draft: "Draft",
       figure: "Figure", table: "Table", equation: "Equation", appendix: "Appendix", contents: "Contents"),
  zh: (abstract: "摘要", keywords: "关键词", proof: "证明", draft: "草稿",
       figure: "图", table: "表", equation: "式", appendix: "附录", contents: "目录"),
)
#let _thm-kinds = (
  theorem: (en: "Theorem", zh: "定理", style: "plain"),
  lemma: (en: "Lemma", zh: "引理", style: "plain"),
  proposition: (en: "Proposition", zh: "命题", style: "plain"),
  corollary: (en: "Corollary", zh: "推论", style: "plain"),
  conjecture: (en: "Conjecture", zh: "猜想", style: "plain"),
  definition: (en: "Definition", zh: "定义", style: "definition"),
  assumption: (en: "Assumption", zh: "假设", style: "definition"),
  example: (en: "Example", zh: "例", style: "definition"),
  exercise: (en: "Exercise", zh: "习题", style: "definition"),
  remark: (en: "Remark", zh: "注", style: "remark"),
)
#let _is-zh() = text.lang == "zh"
// Drop the stray spaces that markup like `[ \n  text \n ]` leaves at either end.
#let _trim(c) = {
  if type(c) == content and c.has("children") {
    let ch = c.children
    while ch.len() > 0 and (ch.first() == [ ] or ch.first() == parbreak()) { ch = ch.slice(1) }
    while ch.len() > 0 and (ch.last() == [ ] or ch.last() == parbreak()) { ch = ch.slice(0, -1) }
    ch.join()
  } else { c }
}
#let _numbering-mode = state("mainsub-numbering", "plain")
#let _within-section(n) = context {
  if _numbering-mode.get() == "section" {
    let s = counter(heading).get().first()
    [#s.#n]
  } else { str(n) }
}
#let _word(key) = context _words.at(if _is-zh() { "zh" } else { "en" }).at(key)

// ---------------------------------------------------------------- theorems
// Theorem-like environments are figures of their own kind: that gives them a
// counter, a supplement and @references for free.
#let _thm(kind, title: none, body) = figure(
  kind: "mainsub-" + kind,
  supplement: context _thm-kinds.at(kind).at(if _is-zh() { "zh" } else { "en" }),
  numbering: _within-section,
  outlined: false,
  caption: if title != none { figure.caption(title) },
  body,
)
#let theorem = _thm.with("theorem")
#let lemma = _thm.with("lemma")
#let proposition = _thm.with("proposition")
#let corollary = _thm.with("corollary")
#let conjecture = _thm.with("conjecture")
#let definition = _thm.with("definition")
#let assumption = _thm.with("assumption")
#let example = _thm.with("example")
#let exercise = _thm.with("exercise")
#let remark = _thm.with("remark")

#let qed = box(width: 0.62em, height: 0.62em, stroke: 0.5pt + ink, baseline: 0.02em)
#let proof(title: none, body) = context {
  let zh = _is-zh()
  let head = if title != none { title } else { _words.at(if zh { "zh" } else { "en" }).proof }
  block(above: 0.9em, below: 0.9em, breakable: true, width: 100%)[
    #set par(first-line-indent: 0pt)
    #if zh { strong(head); h(1em) } else { emph[#head.]; h(0.5em) }#_trim(body)#h(1fr)#qed
  ]
}

// ---------------------------------------------------------------- appendix
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  body
}

// ---------------------------------------------------------------- maths shorthands
// Typst counterparts of mainsub-macros.tex: $EE[X]$, $Var(X)$, $argmin_x f$, $X iid Normal(0, 1)$.
// Single letters are plain letters in Typst maths, so expectation is EE (RR, NN, ZZ, QQ are built in).
#let EE = math.bb("E")
#let PP = math.bb("P")
#let Var = math.op("Var")
#let Cov = math.op("Cov")
#let Corr = math.op("Corr")
#let Bias = math.op("Bias")
#let MSE = math.op("MSE")
#let Normal = math.cal("N")
#let iid = math.attach(math.tilde, t: text(size: 0.7em, "iid"))
#let indep = math.class("relation", $perp #h(-0.55em) perp$)
#let argmin = math.op("arg min", limits: true)
#let argmax = math.op("arg max", limits: true)
#let tr = math.op("tr")
#let diag = math.op("diag")
#let rank = math.op("rank")

// ---------------------------------------------------------------- the template
#let report(
  title: none,
  subtitle: none,
  authors: (),
  affiliation: none,
  email: none,
  date: auto,
  abstract: none,
  keywords: (),
  short-title: none,
  lang: "en",
  font: "newcm",
  font-size: 11pt,
  paper: "a4",
  review: false,
  numbering: "plain", // or "section": theorems and equations numbered 2.1, 2.2, ...
  toc: false,
  fonts: (:),
  body,
) = {
  let f = default-fonts + fonts
  let (cjk-serif, cjk-sans, cjk-kai, mono) = (f.cjk-serif, f.cjk-sans, f.cjk-kai, f.mono)
  let zh = lang.starts-with("zh")
  let paper = if paper == "letter" { "us-letter" } else { paper }
  let lang = if zh { "zh" } else { "en" }
  let w = _words.at(lang)
  let preset = _presets.at(font)
  let authors = if type(authors) == array { authors } else { (authors,) }
  let keywords = if type(keywords) == array { keywords } else { (keywords,) }
  let date = if date == auto { datetime.today() } else { date }
  let date-text = if type(date) == datetime {
    if zh { date.display("[year] 年 [month padding:none] 月 [day padding:none] 日") }
    else { date.display("[month repr:long] [day padding:none], [year]") }
  } else { date }

  // Vertical rhythm: one "pitch" is the distance between two baselines.
  let pitch = if zh { 1.55 * font-size } else { 1.31 * font-size }
  let leading = pitch - 0.68 * font-size

  set document(
    title: title,
    author: authors.map(a => if type(a) == str { a } else { "" }),
    keywords: keywords.map(k => if type(k) == str { k } else { "" }),
  )
  let latin = if zh { (name: preset.serif, covers: "latin-in-cjk") } else { preset.serif }
  set text(font: (latin, ..cjk-serif), size: font-size, lang: lang, region: if zh { "cn" } else { none },
           fill: ink, number-type: "lining")
  set par(justify: true, leading: leading, spacing: leading,
          first-line-indent: (amount: if zh { 2em } else { 1.4em }, all: zh))
  show math.equation: set text(font: preset.math, weight: preset.math-weight)
  set math.equation(numbering: "(1)", supplement: w.equation)
  show raw: set text(font: (..mono, ..cjk-sans), size: 1em)
  set raw(theme: "mainsub.tmTheme")
  show raw.where(block: true): it => block(fill: code-bg, inset: (x: 7pt, y: 6pt), width: 100%,
                                           breakable: true, above: 1em, below: 1em, it)
  show ref: it => {
    let el = it.element
    if el == none { return it }
    // Numbers are rebuilt at the element's own location, so "section" numbering
    // reads the section the element lives in, not the one the reference is in.
    let sec = counter(heading).at(el.location()).first()
    let prefix = if numbering == "section" { str(sec) + "." } else { "" }
    // `-@label` in Quarto (or an explicit empty supplement) asks for the bare number
    let bare = it.supplement == [] or it.supplement == none
    if el.func() == math.equation and el.numbering != none {
      let n = counter(math.equation).at(el.location()).first()
      link(el.location(), if bare [(#prefix#n)] else [#w.equation~(#prefix#n)])
    } else if el.func() == figure and type(el.kind) == str and el.kind.starts-with("mainsub-") {
      let n = counter(figure.where(kind: el.kind)).at(el.location()).first()
      link(el.location(), if bare [#prefix#n] else [#el.supplement~#prefix#n])
    } else if el.func() == heading and el.numbering != none {
      let n = std.numbering(el.numbering, ..counter(heading).at(el.location()))
      if bare { link(el.location(), n) }
      else if zh { link(el.location(), [第~#n~节]) }
      else { link(el.location(), [#if el.level == 1 and n.starts-with(regex("[A-Z]")) [Appendix] else [Section]~#n]) }
    } else { it }
  }
  // As in Quarto and pandoc: only labelled display equations get a number.
  show math.equation: it => {
    if it.block and not it.has("label") and it.numbering != none {
      counter(math.equation).update(v => v - 1)
      math.equation(it.body, block: true, numbering: none)
    } else { it }
  }
  show emph: it => {
    // Chinese has no italic: emphasis switches to Kai, or to Hei when no Kai is installed.
    if zh { set text(font: (latin, ..cjk-kai, ..cjk-sans)); it } else { it }
  }
  show link: it => if type(it.dest) == str { text(fill: accent, it) } else { it }
  show strong: set text(weight: "bold")

  // ---- page
  let stamp = if review { text(fill: accent)[#w.draft · #date-text] }
  let head-title = if short-title != none { short-title } else { title }
  let page-width = if paper == "a4" { 210mm } else { 215.9mm }
  set page(
    paper: paper,
    margin: (x: (page-width - 138mm) / 2, top: 30mm, bottom: 33mm),
    header-ascent: 35%,
    header: context {
      set text(size: 0.82em)
      if here().page() > 1 {
        text(fill: muted, if zh { head-title } else { emph(head-title) })
        h(1fr)
        if review { stamp; h(1em) }
        text(fill: muted, counter(page).display())
      } else if review { h(1fr); stamp }
    },
    footer: context if here().page() == 1 {
      set text(size: 0.82em, fill: muted)
      align(center, counter(page).display())
    },
  )
  set par.line(numbering: if review { n => text(size: 6.5pt, fill: rule-color, str(n)) },
               number-margin: right, number-clearance: 1.2em) if review

  // ---- headings: numbers hang in the margin, text starts on the text edge
  set heading(numbering: "1.1")
  show heading: it => {
    let size = if it.level == 1 { 1.09 * font-size } else { font-size }
    let style = if it.level >= 3 and not zh { "italic" } else { "normal" }
    let weight = if it.level >= 3 { "regular" } else { "bold" }
    let (above, below) = if it.level == 1 { (1.9 * pitch, 0.75 * pitch) }
      else if it.level == 2 { (1.35 * pitch, 0.5 * pitch) }
      else { (1.1 * pitch, 0.4 * pitch) }
    set text(size: size, style: style, weight: weight,
             font: if it.level >= 3 and zh { (preset.sans, ..cjk-sans) } else { (latin, ..cjk-serif) })
    set par(first-line-indent: 0pt, justify: false)
    block(above: above, below: below, sticky: true, {
      if it.numbering != none {
        context {
          let n = counter(heading).display(it.numbering)
          h(-measure(n).width - 0.85em)
          n
          h(0.85em)
        }
      }
      it.body
    })
  }

  // ---- figures, captions, tables
  set figure(gap: 0.7em)
  show figure: set block(above: 1.3 * pitch, below: 1.3 * pitch)
  set figure.caption(separator: if zh { h(1em) } else { [. ] })
  show figure.caption: it => {
    set text(size: 0.91em)
    set par(justify: true, first-line-indent: 0pt)
    let label = [#it.supplement~#context it.counter.display(it.numbering)]
    let content = [*#label*#it.separator#it.body]
    // Like LaTeX's caption package: one-line captions are centred, longer ones justified.
    layout(size => if measure(content).width <= size.width { align(center, content) } else { content })
  }
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure(supplement: w.figure)
  show figure.where(kind: table): set figure(supplement: w.table)
  // Three-line table: heavy top and bottom rules, a light rule under the header.
  set table(stroke: (x, y) => if y == 0 { (bottom: 0.5pt + ink) }, inset: (x: 0.55em, y: 0.42em))
  show table: it => block(stroke: (top: 0.8pt + ink, bottom: 0.8pt + ink), it)
  show table: set text(size: 0.92em, number-width: "tabular")

  // ---- theorems
  for (kind, spec) in _thm-kinds {
    let k = "mainsub-" + kind
    body = {
      show figure.where(kind: k): set block(breakable: true)
      show figure.where(kind: k): it => {
        set align(left)
        set par(first-line-indent: 0pt)
        let head = [#it.supplement #it.counter.display(it.numbering)]
        let note = if it.caption != none { it.caption.body }
        let body-font = if spec.style == "plain" and not zh { (style: "italic") } else { (:) }
        block(width: 100%, above: 0.9 * pitch, below: 0.9 * pitch, {
          if zh {
            strong(if note != none [#head (#note)] else { head })
            h(1em)
          } else {
            if spec.style == "remark" { emph(head) } else { strong(head) }
            if note != none [ (#note)]
            [.]
            h(0.5em)
          }
          text(..body-font, _trim(it.body))
        })
      }
      body
    }
  }

  // ---- theorem frames made by Quarto (theorion): flush-left like ours, and in
  // Chinese no Kai/Hei switch for the whole body (theorion emphasises it)
  for k in ("theorem", "lemma", "corollary", "proposition", "conjecture", "definition",
            "example", "exercise", "algorithm") {
    body = {
      show figure.where(kind: k): set par(first-line-indent: 0pt)
      show figure.where(kind: k): it => { show emph: e => if zh { e.body } else { e }; it }
      body
    }
  }

  // ---- numbering within sections (optional)
  _numbering-mode.update(numbering)
  set math.equation(numbering: n => [(#_within-section(n))]) if numbering == "section"
  show heading.where(level: 1): it => {
    if numbering == "section" {
      counter(math.equation).update(0)
      for kind in _thm-kinds.keys() { counter(figure.where(kind: "mainsub-" + kind)).update(0) }
    }
    it
  }

  // ---- lists, footnotes, bibliography
  set list(indent: if zh { 0.5em } else { 0.4em }, body-indent: 0.55em, marker: ([•], [–]),
           spacing: leading + 0.12em)
  set enum(indent: if zh { 0.5em } else { 0.4em }, body-indent: 0.55em, spacing: leading + 0.12em)
  show list: set block(above: leading + 0.35em, below: leading + 0.35em)
  show enum: set block(above: leading + 0.35em, below: leading + 0.35em)
  set footnote.entry(separator: line(length: 4em, stroke: 0.4pt + rule-color), gap: 0.45em, clearance: 1em)
  show footnote.entry: set text(size: 0.85em)
  set bibliography(style: if zh { "gb7714-author-date.csl" } else { "chicago-author-date" }, title: auto)
  show bibliography: set text(size: 0.92em)
  show bibliography: set par(first-line-indent: 0pt, spacing: 0.6em, justify: false)
  set outline(indent: auto)

  // ---- title block
  {
    set par(first-line-indent: 0pt, justify: false)
    v(-0.6 * pitch)
    block(text(size: 19pt, weight: "bold", title))
    if subtitle != none {
      v(0.25em)
      block(text(size: 1.09 * font-size, style: if zh { "normal" } else { "italic" }, subtitle))
    }
    v(0.9 * pitch)
    block({
      authors.map(a => if type(a) == dictionary { a.name } else { a }).join(", ")
      linebreak()
      text(size: 0.91em, fill: muted, {
        if affiliation != none { affiliation; linebreak() }
        if email != none { raw(email); linebreak() }
        date-text
      })
    })
    if abstract != none {
      v(0.9 * pitch)
      block(text(size: 0.91em, {
        if zh { strong(w.abstract); h(1em) } else { smallcaps(lower(w.abstract)); h(0.5em) }
        _trim(abstract)
      }))
    }
    if keywords.len() > 0 and keywords.first() != none {
      v(0.2em)
      block(text(size: 0.91em, {
        if zh { strong(w.keywords); h(1em) } else { emph(w.keywords); h(0.5em) }
        keywords.join(if zh { "；" } else { "; " })
      }))
    }
    v(0.4 * pitch)
    line(length: 100%, stroke: 0.4pt + rule-color)
    v(-0.3 * pitch)
  }
  if toc {
    outline(title: w.contents)
  }
  body
}
