CRUSH.md — Neovim Lua config guide for agentic tools

Structure: init.lua loads lua/config/lazy.lua; plugins in lua/plugins/*.lua (each returns a lazy.nvim spec); custom in lua/custom/*

Headless boot: nvim --headless +"lua print('ok')" +qa
Sync plugins (lazy.nvim): nvim --headless +"lua require('lazy').sync()" +qa
Treesitter update: nvim --headless +TSUpdateSync +qa

Format (stylua): stylua .   | Single file: stylua path/to/file.lua
Lint (luacheck): luacheck . --codes   | Single file: luacheck path/to/file.lua
Syntax check: find lua -name '*.lua' -print0 | xargs -0 -n1 luac -p
Optional: selene . (if configured)
Suggested style (stylua): indent_width=4, column_width=100, quote_style=AutoPreferSingle

Tests (none present yet; suggested via plenary.nvim/busted):
All specs: nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }" -c qa
Single spec: nvim --headless -c "lua require('plenary.busted').run('tests/some_spec.lua')" -c qa
Single test filter: use { filter = 'pattern' } in run()

Code style:
- Lua modules: local M = {}; expose API on M; return M; avoid globals; prefer local
- Naming: snake_case funcs/vars; UPPER_SNAKE constants; PascalCase only for types
- Imports: local v = require('...'); order std/vim, third-party, local; group top-of-file
- Neovim API: use vim.keymap.set, vim.opt, vim.g; prefer desc on keymaps; vim.notify for user messages
- Plugin specs: return { 'repo/name', opts = {...} } or config=function(); avoid heavy work at top level
- Error handling: pcall(require, ...) for optional deps; validate inputs; avoid throwing on user ops

Rules: No Cursor or Copilot rules found; if added (.cursor/rules/* or .github/copilot-instructions.md), mirror essentials here.
