-- Git merge conflict resolution: highlights the blocks git leaves in a file,
-- jumps between them and replaces one with ours, theirs, both or neither.
--
--   <<<<<<< ours          start
--   …                     ours
--   ||||||| base          base   (only with merge.conflictStyle diff3/zdiff3)
--   …
--   =======               sep
--   …                     theirs
--   >>>>>>> theirs        finish

local ns = vim.api.nvim_create_namespace "user.conflict"

---@class Conflict
---@field start integer 0-based row of <<<<<<<
---@field base? integer row of |||||||
---@field sep integer row of =======
---@field finish integer row of >>>>>>>

---@return Conflict[]
local function parse(bufnr)
  local conflicts, current = {}, nil
  for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local row = i - 1
    if line:match "^<<<<<<<" then
      current = { start = row }
    elseif current and not current.sep and line:match "^|||||||" then
      current.base = row
    elseif current and not current.sep and line:match "^=======%s*$" then
      current.sep = row
    elseif current and current.sep and line:match "^>>>>>>>" then
      current.finish = row
      table.insert(conflicts, current)
      current = nil
    end
  end
  return conflicts
end

local function highlight(bufnr, from, to, group)
  if to < from then return end
  vim.api.nvim_buf_set_extmark(bufnr, ns, from, 0, {
    end_row = to + 1,
    hl_group = group,
    hl_eol = true,
    priority = 90,
  })
end

local function label(bufnr, row, text)
  vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
    virt_text = { { text, "ConflictLabel" } },
    hl_group = "ConflictMarker",
    end_row = row + 1,
    hl_eol = true,
    priority = 91,
  })
end

local function refresh(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local conflicts = parse(bufnr)
  for _, c in ipairs(conflicts) do
    local ours_end = (c.base or c.sep) - 1
    label(bufnr, c.start, "  current")
    highlight(bufnr, c.start + 1, ours_end, "ConflictOurs")
    if c.base then
      label(bufnr, c.base, "  base")
      highlight(bufnr, c.base + 1, c.sep - 1, "ConflictBase")
    end
    label(bufnr, c.sep, "")
    highlight(bufnr, c.sep + 1, c.finish - 1, "ConflictTheirs")
    label(bufnr, c.finish, "  incoming")
  end

  -- Language servers cannot parse a file full of markers; hide their noise
  -- until the last conflict is resolved
  local had = (vim.b[bufnr].conflict_count or 0) > 0
  -- Once set, the count keeps the buffer watched, so an undo that brings
  -- markers back is picked up too
  if #conflicts > 0 or vim.b[bufnr].conflict_count then vim.b[bufnr].conflict_count = #conflicts end
  if #conflicts > 0 and not had then
    vim.diagnostic.enable(false, { bufnr = bufnr })
  elseif #conflicts == 0 and had then
    vim.diagnostic.enable(true, { bufnr = bufnr })
  end
end

---@return Conflict?
local function conflict_at_cursor()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  for _, c in ipairs(parse(0)) do
    if row >= c.start and row <= c.finish then return c end
  end
end

---@param side "ours"|"theirs"|"both"|"none"
local function choose(side)
  local c = conflict_at_cursor()
  if not c then
    vim.notify("No conflict under the cursor", vim.log.levels.WARN)
    return
  end
  local function lines(from, to) return vim.api.nvim_buf_get_lines(0, from, to + 1, false) end
  local ours = lines(c.start + 1, (c.base or c.sep) - 1)
  local theirs = lines(c.sep + 1, c.finish - 1)
  local replacement = ({
    ours = ours,
    theirs = theirs,
    both = vim.list_extend(vim.list_extend({}, ours), theirs),
    none = {},
  })[side]
  vim.api.nvim_buf_set_lines(0, c.start, c.finish + 1, false, replacement)
  vim.api.nvim_win_set_cursor(0, { math.min(c.start + 1, vim.api.nvim_buf_line_count(0)), 0 })
  refresh(vim.api.nvim_get_current_buf())
end

---@param dir 1|-1
local function jump(dir)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local conflicts = parse(0)
  for i = dir > 0 and 1 or #conflicts, dir > 0 and #conflicts or 1, dir do
    if (conflicts[i].start - row) * dir > 0 then
      vim.api.nvim_win_set_cursor(0, { conflicts[i].start + 1, 0 })
      return
    end
  end
  vim.notify(dir > 0 and "No next conflict" or "No previous conflict")
end

-- Every conflict in the repository, from the files git reports as unmerged
local function list()
  local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local out = vim.system({ "git", "diff", "--name-only", "--diff-filter=U" }, { cwd = root, text = true }):wait()
  local items = {}
  for file in vim.gsplit(out.stdout or "", "\n", { trimempty = true }) do
    local path = vim.fs.joinpath(root, file)
    for i, line in ipairs(vim.fn.readfile(path)) do
      if line:match "^<<<<<<<" then table.insert(items, { filename = path, lnum = i, text = line }) end
    end
  end
  if #items == 0 then
    vim.notify "No merge conflicts"
    return
  end
  vim.fn.setqflist({}, " ", { title = "Merge conflicts", items = items })
  require("snacks").picker.qflist()
end

local group = vim.api.nvim_create_augroup("UserConflict", { clear = true })
-- On read, and when git rewrites a loaded file during a merge
vim.api.nvim_create_autocmd({ "BufReadPost", "FileChangedShellPost" }, {
  group = group,
  callback = function(args) refresh(args.buf) end,
})
-- Edits are rescanned only in files that had conflicts when read
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
  group = group,
  callback = function(args)
    if vim.b[args.buf].conflict_count then refresh(args.buf) end
  end,
})

vim.keymap.set("n", "]x", function() jump(1) end, { desc = "Next conflict" })
vim.keymap.set("n", "[x", function() jump(-1) end, { desc = "Previous conflict" })
vim.keymap.set("n", "<leader>co", function() choose "ours" end, { desc = "Choose ours (current)" })
vim.keymap.set("n", "<leader>ct", function() choose "theirs" end, { desc = "Choose theirs (incoming)" })
vim.keymap.set("n", "<leader>cb", function() choose "both" end, { desc = "Choose both" })
vim.keymap.set("n", "<leader>c0", function() choose "none" end, { desc = "Choose none" })
vim.keymap.set("n", "<leader>cq", list, { desc = "List conflicts in repo" })
