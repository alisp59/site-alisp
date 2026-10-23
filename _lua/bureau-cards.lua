local DATA = "_resources/bureau.yml"
local FIELDS = { "photo", "nom", "fonction", "desc" }

local function warn(msg)
  if quarto and quarto.log and quarto.log.warning then
    quarto.log.warning("bureau-cards: " .. msg)
  else
    io.stderr:write("bureau-cards: " .. msg .. "\n")
  end
end

local project_dir = quarto and quarto.project and quarto.project.directory

local function in_project(path)
  if not project_dir then
    return path
  end
  return project_dir .. "/" .. path
end

local function protect_paths(text)
  local skipped = 0
  local out = text:gsub("(\n[ \t]*%-?[ \t]*photo:[ \t]*)([^\n]*)", function(key, value)
    local trimmed = value:match("^(.-)[ \t]*$")
    if trimmed == "" or trimmed:find('[`"\\]') then
      skipped = skipped + 1
      return key .. value
    end
    return key .. '"`' .. trimmed .. '`"'
  end)
  return out, skipped
end

---@return pandoc.MetaList|nil
local function read_members(path)
  local fh = io.open(path)
  if not fh then
    warn("file not found, no card rendered: " .. path)
    return nil
  end
  local text = fh:read("a")
  fh:close()
  local protected, skipped = protect_paths(text)
  if skipped > 0 then
    warn(skipped .. " photo path(s) left unprotected (empty or quoted value), the Markdown reader may alter them")
  end
  local ok, doc = pcall(pandoc.read, "---\n" .. protected .. "\n---\n", "markdown")
  if not ok then
    warn("cannot parse " .. path .. ": " .. tostring(doc))
    return nil
  end
  local members = doc.meta.bureau
  if members == nil or pandoc.utils.type(members) ~= "List" then
    warn(path .. ": no 'bureau' list, no card rendered")
    return nil
  end
  ---@cast members pandoc.MetaList
  return members
end

local ESCAPES = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;" }

local function escape(text)
  return (text:gsub('[&<>"]', ESCAPES))
end

---@param member pandoc.MetaValue
local function card(member, index)
  if pandoc.utils.type(member) ~= "table" then
    warn("entry " .. index .. " is not a mapping, card skipped")
    return nil
  end
  ---@cast member pandoc.MetaMap
  local value = {}
  local problems = {}
  for _, field in ipairs(FIELDS) do
    if member[field] == nil then
      problems[#problems + 1] = "missing '" .. field .. "'"
    else
      local text = pandoc.utils.stringify(member[field])
      if text:match("^%s*$") then
        problems[#problems + 1] = "empty '" .. field .. "'"
      else
        value[field] = escape(text)
      end
    end
  end
  if #problems > 0 then
    warn("entry " .. index .. ": " .. table.concat(problems, ", ") .. ", card skipped")
    return nil
  end
  return table.concat({
    '<div class="bureau-card">',
    '<img src="' .. value.photo .. '" alt="" class="bureau-photo">',
    '<div class="bureau-info">',
    '<h2 class="bureau-nom">',
    value.nom,
    "</h2>",
    '<p class="bureau-fonction">',
    value.fonction,
    "</p>",
    '<p class="bureau-desc">',
    value.desc,
    "</p>",
    "</div>",
    "</div>",
  }, "\n")
end

return {
  ["bureau-cards"] = function()
    local path = in_project(DATA)
    local members = read_members(path)
    if members == nil then
      return {}
    end
    local cards = {}
    for index, member in ipairs(members) do
      local html = card(member, index)
      if html ~= nil then
        cards[#cards + 1] = html
      end
    end
    if #cards == 0 then
      warn("no card rendered from " .. path)
      return {}
    end
    return pandoc.Div({ pandoc.RawBlock("html", table.concat(cards, "\n")) }, pandoc.Attr("", { "bureau-grid" }))
  end,
}
