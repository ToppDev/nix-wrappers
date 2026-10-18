-- rust-analyzer's code lenses call commands the editor has to implement.
-- These client commands take precedence over the global ones nvim-lspconfig
-- registers, whose `run` blocks the editor until cargo exits.

-- One runner terminal at a time: a new run replaces the previous one
local runner_buf

---@param runnable { label: string, args: { cwd: string, cargoArgs: string[], executableArgs?: string[], environment?: table<string, string> } }
local function run_in_terminal(runnable)
  local args = runnable.args
  local cmd = { "cargo", unpack(args.cargoArgs) }
  if args.executableArgs and #args.executableArgs > 0 then
    vim.list_extend(cmd, { "--", unpack(args.executableArgs) })
  end

  if runner_buf and vim.api.nvim_buf_is_valid(runner_buf) then
    vim.api.nvim_buf_delete(runner_buf, { force = true })
  end
  vim.cmd "botright 15new"
  runner_buf = vim.api.nvim_get_current_buf()
  vim.fn.jobstart(cmd, { term = true, cwd = args.cwd, env = args.environment })
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = runner_buf, desc = "Close runner" })
  -- With the cursor on the last line the terminal keeps following the output
  vim.cmd "normal! G"
  vim.cmd.wincmd "p"
end

return {
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
      -- No debugger is set up, so the `debug` lens would only fail
      lens = { debug = { enable = false } },
    },
  },
  commands = {
    ["rust-analyzer.runSingle"] = function(command) run_in_terminal(command.arguments[1]) end,
    -- arguments: uri, position, locations
    ["rust-analyzer.showReferences"] = function(command, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      local locations = command.arguments[3] or {}
      if #locations == 0 then
        vim.notify "No references"
        return
      end
      vim.fn.setqflist({}, " ", {
        title = "References",
        items = vim.lsp.util.locations_to_items(locations, client.offset_encoding),
      })
      require("snacks").picker.qflist()
    end,
  },
}
