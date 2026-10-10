--[[
mainsub.lua — one pandoc Lua filter shared by the Quarto extension and the
R Markdown formats.

1. Maths macros. LaTeX output reads mainsub-macros.tex through mainsub.sty.
   Every other output (HTML, Typst, Word...) gets the macros expanded here, at
   build time, so MathJax and Typst only ever see plain TeX.
   A document can add its own file:   macros: my-macros.tex
2. Chinese defaults. With `lang: zh`, citations default to GB/T 7714-2015
   author-date (mixed-case names) unless the document sets `csl:` itself.
3. Small HTML. Figures that knitr/Jupyter wrote into *_files/ are squeezed with
   pngquant (if installed) before they are embedded. Your own images are never
   touched. Turn off with   mainsub-pngquant: false
--]]

local is_quarto = (quarto ~= nil and quarto.utils ~= nil)

local function resolve(file)
  if is_quarto then return quarto.utils.resolve_path(file) end
  return pandoc.path.join({ pandoc.path.directory(PANDOC_SCRIPT_FILE), file })
end

local function is_format(name)
  if is_quarto then return quarto.doc.is_format(name) end
  if name == "html" then return FORMAT:match("html") ~= nil end
  if name == "latex" then return FORMAT == "latex" or FORMAT == "beamer" end
  return FORMAT == name
end

local function read_file(path)
  local fh = io.open(path, "r")
  if not fh then return nil end
  local s = fh:read("a")
  fh:close()
  return s
end

local function stringify(x)
  if x == nil then return nil end
  return pandoc.utils.stringify(x)
end

-- ------------------------------------------------------------------ maths
-- A tiny TeX macro expander: understands \newcommand, \renewcommand,
-- \providecommand (with [n] arguments) and \DeclareMathOperator(*). It works on
-- plain strings, so it covers $...$, $$...$$ and raw \begin{equation} blocks alike.
local function read_group(s, i)
  -- s:sub(i, i) must be "{"; returns inner text and the index after "}"
  local depth, j = 0, i
  while j <= #s do
    local c = s:sub(j, j)
    if c == "\\" then j = j + 1
    elseif c == "{" then depth = depth + 1
    elseif c == "}" then
      depth = depth - 1
      if depth == 0 then return s:sub(i + 1, j - 1), j + 1 end
    end
    j = j + 1
  end
  return nil, i
end

local function parse_macros(src)
  local defs = {}
  src = src:gsub("([^\\])%%[^\n]*", "%1")
  local i = 1
  while true do
    local a, b, kind, star = src:find("\\(%a+)(%*?)", i)
    if not a then break end
    i = b + 1
    if kind == "newcommand" or kind == "renewcommand" or kind == "providecommand"
        or kind == "DeclareMathOperator" then
      local j = src:find("%S", i)
      local name
      if src:sub(j, j) == "{" then
        local inner; inner, i = read_group(src, j); name = inner and inner:match("^%s*\\(%a+)%s*$")
      else
        name = src:match("^\\(%a+)", j); i = j + (name and #name + 1 or 0)
      end
      local nargs = 0
      local k = src:find("%S", i)
      if kind ~= "DeclareMathOperator" and src:sub(k, k) == "[" then
        nargs = tonumber(src:match("^%[(%d)%]", k)) or 0
        i = src:find("]", k, true) + 1
        k = src:find("%S", i)
      end
      if name and src:sub(k, k) == "{" then
        local body; body, i = read_group(src, k)
        if kind == "DeclareMathOperator" then
          body = (star == "*" and "\\operatorname*{" or "\\operatorname{") .. body .. "}"
        end
        -- \providecommand never overrides; the others do
        if not (kind == "providecommand" and defs[name]) then defs[name] = { n = nargs, body = body } end
      end
    end
  end
  return defs
end

local function expand_tex(s, defs, depth)
  depth = depth or 0
  if depth > 8 or not s:find("\\", 1, true) then return s end
  local out, i, changed = {}, 1, false
  while i <= #s do
    local a, b, name = s:find("\\(%a+)", i)
    if not a then out[#out + 1] = s:sub(i); break end
    out[#out + 1] = s:sub(i, a - 1)
    local d = defs[name]
    if d then
      local args, j = {}, b + 1
      for n = 1, d.n do
        local k = s:find("%S", j)
        if k and s:sub(k, k) == "{" then
          local g; g, j = read_group(s, k); args[n] = g or ""
        elseif k then
          args[n] = s:sub(k, k); j = k + 1
        end
      end
      local body = d.body:gsub("#(%d)", function(m) return args[tonumber(m)] or "" end)
      -- keep "\E x" from turning into "\mathbb{E}x" with a lost space
      local nextc = s:sub(j, j)
      out[#out + 1] = body .. ((d.n == 0 and nextc:match("%a")) and " " or "")
      i = j
      changed = true
    else
      out[#out + 1] = s:sub(a, b)
      i = b + 1
    end
  end
  local r = table.concat(out)
  return changed and expand_tex(r, defs, depth + 1) or r
end

local function expand_math(doc, defs)
  local function raw(el)
    if (el.format == "tex" or el.format == "latex") and el.text:match("^%s*\\begin{") then
      el.text = expand_tex(el.text, defs); return el
    end
  end
  return doc:walk({
    Math = function(m) m.text = expand_tex(m.text, defs); return m end,
    RawInline = raw,
    RawBlock = raw,
  })
end

-- ------------------------------------------------------------------ pngquant
local pngquant_ok = nil
local function have_pngquant()
  if pngquant_ok == nil then
    local h = io.popen("command -v pngquant 2>/dev/null")
    local out = h and h:read("a") or ""
    if h then h:close() end
    pngquant_ok = out:match("%S") ~= nil
  end
  return pngquant_ok
end

local squeezed = {}
local function squeeze(img)
  local src = img.src
  if squeezed[src] or src:match("^%a+://") or src:match("^data:") then return end
  if not (src:match("%.png$") and src:match("_files/")) then return end
  local fh = io.open(src, "rb")
  if not fh then return end
  fh:close()
  squeezed[src] = true
  os.execute("pngquant --force --skip-if-larger --speed 1 --quality=65-92 --strip --ext .png '"
    .. src:gsub("'", "'\\''") .. "' >/dev/null 2>&1")
end

-- ------------------------------------------------------------------ CJK line breaks
-- A line break in the source between two Chinese characters is not a space.
-- (pandoc's east_asian_line_breaks, done here so it also covers metadata such
-- as the abstract and works the same in every route.)
local function cjk(cp)
  return cp and ((cp >= 0x3000 and cp <= 0x303F) or (cp >= 0x3400 and cp <= 0x9FFF)
    or (cp >= 0xF900 and cp <= 0xFAFF) or (cp >= 0xFF00 and cp <= 0xFFEF))
end
local function cjk_punct(cp)
  return cp and ((cp >= 0x3000 and cp <= 0x303F) or (cp >= 0xFF00 and cp <= 0xFF0F)
    or (cp >= 0xFF1A and cp <= 0xFF20) or (cp >= 0xFF3B and cp <= 0xFF40) or (cp >= 0xFF5B and cp <= 0xFF65))
end
local function edge_cp(el, last)
  if el == nil or el.t == "Math" or el.t == "RawInline" or el.t == "Note" then return nil end
  local text = el.t == "Str" and el.text or pandoc.utils.stringify(el)
  local cp
  for _, c in utf8.codes(text) do
    if not last then return c end
    cp = c
  end
  return cp
end
local cjk_breaks = {
  Inlines = function(inlines)
    local out = pandoc.Inlines({})
    for i, el in ipairs(inlines) do
      local drop = false
      if el.t == "SoftBreak" then
        local a, b = edge_cp(inlines[i - 1], true), edge_cp(inlines[i + 1], false)
        -- between two Chinese characters, or next to full-width punctuation
        drop = (cjk(a) and cjk(b)) or cjk_punct(a) or cjk_punct(b)
      end
      if not drop then out:insert(el) end
    end
    return out
  end,
}

-- ------------------------------------------------------------------ main
function Pandoc(doc)
  local meta = doc.meta
  local lang = stringify(meta.lang) or ""
  local zh = lang:sub(1, 2) == "zh"
  meta["mainsub-zh"] = zh
  if zh then
    doc.blocks = doc.blocks:walk(cjk_breaks)
    for k, v in pairs(meta) do
      if pandoc.utils.type(v) == "Inlines" or pandoc.utils.type(v) == "Blocks" then
        meta[k] = v:walk(cjk_breaks)
      end
    end
  end

  -- maths macros
  if not is_format("latex") then
    local src = read_file(resolve("mainsub-macros.tex")) or ""
    local user = stringify(meta.macros)
    if user and user ~= "" then src = src .. "\n" .. (read_file(user) or "") end
    doc = expand_math(doc, parse_macros(src))
    meta = doc.meta -- the walk also expanded maths in metadata (e.g. the abstract)
  elseif meta.macros then
    -- LaTeX: the shared macros come with mainsub.sty; add the document's own
    local user = stringify(meta.macros)
    local body = user and read_file(user)
    if body then
      local hi = meta["header-includes"] or pandoc.MetaList({})
      if pandoc.utils.type(hi) ~= "List" then hi = pandoc.MetaList({ hi }) end
      hi:insert(pandoc.MetaBlocks({ pandoc.RawBlock("latex", body) }))
      meta["header-includes"] = hi
    end
  end

  -- Chinese citation style (Typst handles this inside mainsub.typ)
  if zh and meta.csl == nil and not is_format("typst") then
    local csl = resolve("gb7714-author-date.csl")
    if read_file(csl) then meta.csl = csl end
  end

  -- Typst: put the bibliography where the ::: {#refs} div is, not at the very end
  if is_format("typst") and meta.bibliography then
    local bibs = meta.bibliography
    if pandoc.utils.type(bibs) ~= "List" then bibs = { bibs } end
    local paths = {}
    for _, b in ipairs(bibs) do paths[#paths + 1] = '"' .. stringify(b) .. '"' end
    local call = "#bibliography((" .. table.concat(paths, ", ") .. ",), title: none"
    if meta.csl then call = call .. ', style: "' .. stringify(meta.csl) .. '"' end
    call = call .. ")"
    doc.blocks = doc.blocks:walk({
      Div = function(d)
        if d.identifier == "refs" then
          meta["mainsub-bib-placed"] = true
          return pandoc.RawBlock("typst", call)
        end
      end,
    })
  end

  -- {.appendix} headers: lettered appendices in print (HTML handles them itself)
  local seen_appendix = false
  doc.blocks = doc.blocks:walk({
    Header = function(h)
      if seen_appendix or not h.classes:includes("appendix") then return nil end
      seen_appendix = true
      if is_format("latex") then
        return { pandoc.RawBlock("latex", "\\appendix"), h }
      elseif is_format("typst") then
        return { pandoc.RawBlock("typst", "#show: appendix"), h }
      end
    end,
  })

  -- smaller HTML
  if is_format("html") and meta["mainsub-pngquant"] ~= false and have_pngquant() then
    doc = doc:walk({ Image = function(img) squeeze(img) end })
  end

  doc.meta = meta
  return doc
end
