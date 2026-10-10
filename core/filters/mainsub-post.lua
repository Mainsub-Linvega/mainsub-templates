--[[
mainsub-post.lua — runs after cross-references have been resolved
(Quarto: `at: post-render`; R Markdown: after bookdown's own processing).

* Equation references read "Equation (2)" / 式 (2) — with parentheses — in every
  output, as they do in mainsub.sty and mainsub.typ.
* Chinese: no full stop after 证明 / 注记 headings, and no stray space between
  two Chinese characters when one side is a cross-reference ("由 @eq-x 及" in
  the source still prints 由式 (1) 及), which is what xeCJK does in the PDF.
--]]

local zh = false

local function is_cjk(cp)
  return cp and ((cp >= 0x3000 and cp <= 0x303F) or (cp >= 0x3400 and cp <= 0x9FFF)
    or (cp >= 0xF900 and cp <= 0xFAFF) or (cp >= 0xFF00 and cp <= 0xFFEF))
end

-- first / last code point of whatever an inline will display as
local function edge(el, last)
  local text
  if el.t == "RawInline" then
    if el.format == "typst" then text = el.text:match("supplement:%s*%[(.-)%]") end
    if text == nil then return nil end
  else
    text = pandoc.utils.stringify(el)
  end
  if text == nil or text == "" then return nil end
  local cps = {}
  for _, c in utf8.codes(text) do cps[#cps + 1] = c end
  return last and cps[#cps] or cps[1]
end

local function paren_number(inlines)
  for i = #inlines, 1, -1 do
    local el = inlines[i]
    if el.t == "Str" then
      local pre, num, post = el.text:match("^(.-)(%d[%d%.]*)(.-)$")
      if num and not el.text:match("^%(") then
        inlines[i] = pandoc.Str(pre .. "(" .. num .. ")" .. post)
      end
      return inlines
    end
  end
  return inlines
end

local function is_ref(el)
  return (el.t == "Link" and el.target:match("^#")) or el.t == "Cite"
    or (el.t == "RawInline" and el.text:match("^#ref%(") ~= nil)
    or (el.t == "RawInline" and el.text:match("^\\[a-z]*ref{") ~= nil)
end

return {
  {
    Meta = function(meta)
      zh = (pandoc.utils.stringify(meta.lang or "")):sub(1, 2) == "zh"
    end,
  },
  {
    RawInline = function(el)
      if el.format == "latex" and el.text:match("^\\ref{eq%-") then
        return pandoc.RawInline("latex", (el.text:gsub("^\\ref{", "\\eqref{")))
      end
    end,
    Link = function(link)
      if link.target:match("^#eq%-") then
        link.content = paren_number(link.content)
        return link
      end
    end,
    Span = function(sp)
      if zh and sp.classes:includes("proof-title") then
        local c = sp.content
        while #c > 0 and (c[#c].t == "Space" or (c[#c].t == "Str" and c[#c].text:match("^[%.:]%s*$"))) do
          c:remove(#c)
        end
        -- 证明 in bold, as in the PDF, followed by a one-em gap
        c = c:walk({ Emph = function(e) return pandoc.Strong(e.content) end })
        if FORMAT:match("typst") then c:insert(pandoc.RawInline("typst", "#h(1em)")) end
        sp.content = c
        return sp
      end
    end,
  },
  {
    Inlines = function(inlines)
      if not zh then return nil end
      local out = pandoc.Inlines({})
      for i, el in ipairs(inlines) do
        local drop = false
        if el.t == "Space" or el.t == "SoftBreak" then
          local prev, nxt = inlines[i - 1], inlines[i + 1]
          if prev and nxt and (is_ref(prev) or is_ref(nxt)) then
            drop = is_cjk(edge(prev, true)) and is_cjk(edge(nxt, false))
          end
        end
        if not drop then out:insert(el) end
      end
      return out
    end,
  },
}
