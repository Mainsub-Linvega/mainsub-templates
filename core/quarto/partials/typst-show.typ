#show: doc => report(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: ($for(by-author)$[$it.name.literal$],$endfor$),
$endif$
$if(by-affiliation)$
  affiliation: [$for(by-affiliation)$$it.name$$sep$; $endfor$],
$endif$
$for(by-author)$
$if(it.email)$
  email: "$it.email$",
$endif$
$endfor$
$if(date)$
  date: [$date$],
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$
$if(keywords)$
  keywords: ($for(keywords)$[$keywords$],$endfor$),
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainsub.font)$
  font: "$mainsub.font$",
$endif$
$if(mainsub.review)$
  review: true,
$endif$
$if(mainsub.numbering)$
  numbering: "$mainsub.numbering$",
$endif$
$if(mainsub.short-title)$
  short-title: [$mainsub.short-title$],
$endif$
$if(toc)$
  toc: true,
$endif$
  doc,
)
