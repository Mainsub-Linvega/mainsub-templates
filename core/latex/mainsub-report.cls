%% mainsub-report.cls -- plain-LaTeX entry point to the mainsub design.
%%
%%   \documentclass[lang=zh]{mainsub-report}      % or lang=en (default)
%%
%% Class options are passed straight to mainsub.sty (lang, font, review, paper,
%% numbering, macros) plus:  bib = true | false   (biblatex, default true)
%% Compile with:  latexmk -xelatex main.tex
\NeedsTeXFormat{LaTeX2e}[2022/06/01]
\ProvidesClass{mainsub-report}[2026/10/10 v0.1.0 Mainsub report class]

\ExplSyntaxOn
\bool_new:N \l__mainsubcls_bib_bool
\keys_define:nn { mainsub-report }
  {
    bib     .bool_set:N = \l__mainsubcls_bib_bool ,
    bib     .default:n  = true ,
    bib     .initial:n  = true ,
    unknown .code:n     =
      {
        \tl_if_blank:nTF {#1}
          { \use:e { \exp_not:N \PassOptionsToPackage { \l_keys_key_str } { mainsub } } }
          { \use:e { \exp_not:N \PassOptionsToPackage { \l_keys_key_str = \exp_not:n {#1} } { mainsub } } }
      } ,
  }
\ProcessKeyOptions [ mainsub-report ]
\ExplSyntaxOff

\LoadClass[11pt]{article}
\RequirePackage{mainsub}

%% ---------------------------------------------------------------- bibliography
\ExplSyntaxOn
\bool_if:NT \l__mainsubcls_bib_bool
  {
    \mainsub_if_zh:TF
      {
        % GB/T 7714-2015 author-year: the Chinese national standard
        \RequirePackage[backend=biber, style=gb7714-2015ay, gbpub=false, gbnamefmt=lowercase]{biblatex}
      }
      {
        \RequirePackage[backend=biber, style=authoryear, maxcitenames=2, maxbibnames=10,
          giveninits=true, uniquename=false, uniquelist=false, dashed=false,
          doi=true, url=false, isbn=false, eprint=false]{biblatex}
        \DeclareFieldFormat[article,inbook,incollection,inproceedings,thesis,unpublished]{title}{#1}
        \renewbibmacro{in:}{\ifentrytype{article}{}{\printtext{\bibstring{in}\intitlepunct}}}
      }
    \setlength\bibitemsep{.35\baselineskip}
    \AtBeginBibliography{\small}
  }
\ExplSyntaxOff

%% ---------------------------------------------------------------- references
\RequirePackage[unicode, pdfusetitle]{hyperref}
% In Chinese the link covers only the number: xeCJK then spaces "图 1" correctly.
\MainsubIfZh{\RequirePackage[noabbrev]{cleveref}}{\RequirePackage[capitalise, noabbrev, nameinlink]{cleveref}}
\MainsubIfZh{%
  \AtBeginDocument{\def\crefpairconjunction{与}\def\crefmiddleconjunction{、}%
    \def\creflastconjunction{与}\def\crefrangeconjunction{至}}%
  \crefname{figure}{图}{图}\crefname{table}{表}{表}%
  \crefformat{section}{第~#2#1#3~节}\crefformat{subsection}{第~#2#1#3~节}\crefformat{appendix}{附录#2#1#3}%
  \crefname{equation}{式}{式}\creflabelformat{equation}{#2(#1)#3}%
  \crefname{theorem}{定理}{定理}\crefname{lemma}{引理}{引理}%
  \crefname{proposition}{命题}{命题}\crefname{corollary}{推论}{推论}%
  \crefname{definition}{定义}{定义}\crefname{assumption}{假设}{假设}%
  \crefname{example}{例}{例}\crefname{remark}{注}{注}\crefname{appendix}{附录}{附录}%
}{%
  \crefname{assumption}{Assumption}{Assumptions}%
  \crefname{equation}{Equation}{Equations}%
}

%% ---------------------------------------------------------------- code (listings)
\RequirePackage{listings}
\definecolor{mainsubcodebg}{HTML}{F6F5F1}
\definecolor{mainsubstring}{HTML}{3F5E3A}
\definecolor{mainsubnumber}{HTML}{6A4A2F}
\lstset{
  basicstyle=\small\ttfamily, columns=fullflexible, keepspaces=true,
  keywordstyle=\bfseries, commentstyle=\itshape\color{mainsubgray},
  stringstyle=\color{mainsubstring}, showstringspaces=false,
  backgroundcolor=\color{mainsubcodebg}, frame=single, rulecolor=\color{mainsubcodebg},
  framesep=5pt, xleftmargin=5pt, xrightmargin=5pt, aboveskip=.8\baselineskip,
  belowskip=.6\baselineskip, breaklines=true, tabsize=2, upquote=true,
}

\endinput
