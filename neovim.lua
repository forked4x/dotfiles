--[[ Options ]]-- {{{
vim.g.mapleader = " "

vim.o.cmdheight = 0
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.formatoptions = "crqnlj"
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.linebreak = true
vim.o.pumheight = 7
vim.o.shada = "!,'1000,<50,s10,h"
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.textwidth = 88
vim.o.title = true
vim.o.titlestring = "(%{hostname()}) %{fnamemodify(getcwd(), ':t')}"
vim.o.wrap = false
-- }}}

--[[ Plugins ]]-- {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "https://github.com/folke/lazy.nvim.git",
    "--filter=blob:none", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)
-- }}}
require("lazy").setup({
  { "sainnhe/gruvbox-material", -- {{{
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_foreground = "mix"
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
      vim.g.gruvbox_material_better_performance = 1
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          if vim.g.colors_name ~= "gruvbox-material" then return end
          vim.api.nvim_set_hl(0, "@function.builtin", { link = "YellowBold" })
          vim.api.nvim_set_hl(0, "@markup.heading", { bold = true })
          vim.api.nvim_set_hl(0, "@markup.link.label.html", { link = "Underlined" })
          vim.api.nvim_set_hl(0, "@property", { link = "Fg" })
          vim.api.nvim_set_hl(0, "@punctuation.special.htmldjango", { link = "Purple" })
          vim.api.nvim_set_hl(0, "@tag.attribute.html", { link = "Yellow" })
          vim.api.nvim_set_hl(0, "@tag.delimiter.html", { link = "Ignore" })
          vim.api.nvim_set_hl(0, "@tag.html", { link = "Red" })
          vim.api.nvim_set_hl(0, "@variable.builtin", { italic = true })
          vim.api.nvim_set_hl(0, "@variable.member", { link = "Fg" })
          vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { link = "DiagnosticUnderlineHint" })
          vim.api.nvim_set_hl(0, "MatchParen", { link = "FloatTitle" })
          vim.api.nvim_set_hl(0, "NeogitHunkHeaderCursor", { link = "TabLine" })
          vim.api.nvim_set_hl(0, "SnacksDiffContext", { link = "Normal" })
          vim.api.nvim_set_hl(0, "SnacksDiffContextLineNr", { link = "LineNr" })
          vim.api.nvim_set_hl(0, "TabLineFill", { link = "PmenuExtra" })
        end,
      })
      vim.cmd.colorscheme("gruvbox-material")
    end,
  }, -- }}}
  { "nvim-lualine/lualine.nvim", -- {{{
    opts = {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_b = { "branch", "diff" },
        lualine_x = {
          { "macro-recording",
            fmt = function()
              if vim.fn.reg_recording() == "" then return "" end
              return "Recording @" .. vim.fn.reg_recording()
            end,
          },
          "selectioncount",
          "searchcount",
          "diagnostics",
        },
        lualine_y = { "filetype" },
        lualine_z = {
          { "location",
            fmt = function() return "%l/%L:%v/%{virtcol('$') - 1}" end,
          },
        },
      },
    },
  }, -- }}}
  { "folke/snacks.nvim", -- {{{
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      image = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = {
        layout = {
          preset = "vertical",
          layout = { min_height = 3, width = 0.8 },
        },
        matcher = { frecency = true },
        sources = {
          explorer = {
            layout = { layout = { width = 40 } },
          },
          git_log_file = {
            layout = {
              preset = "default",
              layout = { height = 0.99, width = 0.99 },
            },
            confirm = function(picker, item)
              picker:close()
              vim.cmd("Gedit " .. item.commit)
            end,
          },
        },
        actions = {
          open_neogit = function(_, item)
            vim.fn.chdir(item.cwd or item.file)
            vim.cmd("Neogit kind=replace cwd=" .. (item.cwd or item.file))
          end,
          live_grep = function(_, item)
            Snacks.picker.grep({ cwd = item.dir and item.file or item.cwd })
          end,
        },
        win = {
          input = {
            keys = {
              ["<C-->"] = { "jump", mode = { "n", "i" } },
              ["<C-/>"] = { "live_grep", mode = { "n", "i" } },
              ["<D-g>"] = { "open_neogit", mode = { "n", "i" } },
              ["<esc>"] = { "close", mode = { "n", "i" } },
            },
          },
        },
      },
      scroll = { enabled = true },
      styles = {
        notification_history = {
          height = 0.8, width = 0.8,
          wo = { wrap = true },
        },
      },
    },
    keys = {
      { "<leader>S",     function() Snacks.picker() end },
      { "<leader>f",     function() Snacks.picker.files() end },
      { "<leader>e",     function() Snacks.explorer() end },
      { "<leader>p",     function() Snacks.picker.zoxide() end },
      { "<leader><tab>", function() Snacks.picker.buffers({ current = false }) end },
      { "<leader>*",     function() Snacks.picker.grep_word() end },
      { "<leader>/",     function() Snacks.picker.grep() end },
      { "<leader>\\",    function() Snacks.picker.lines() end },
      { "<leader>gf",    function() Snacks.picker.git_log_file() end },
      { "gd",            function() Snacks.picker.lsp_definitions() end },
      { "grr",           function() Snacks.picker.lsp_references() end },
      { "gro",           function() Snacks.picker.lsp_symbols() end },
      { "grw",           function() Snacks.picker.lsp_workspace_symbols() end },
      { "<leader>h",     function() Snacks.picker.help() end },
      { "<leader>r",     function() Snacks.picker.resume() end },
      { "z=",            function() Snacks.picker.spelling() end },
      { "<leader>n",     function() Snacks.notifier.show_history() end },
      { "<leader>z",     function() Snacks.zen.zoom() end },
    }
  }, -- }}}
  { "nvim-mini/mini.nvim", -- {{{
    config = function()
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      require("mini.ai").setup({
        custom_textobjects = {
          g = gen_ai_spec.buffer(),
          i = gen_ai_spec.indent(),
          l = gen_ai_spec.line(),
          n = gen_ai_spec.number(),
        },
        mappings = {
          around_next = "",
          inside_next = "",
          around_last = "",
          inside_last = "",
        },
        n_lines = 5000,
      })

      require("mini.align").setup({
        mappings = {
          start_with_preview = "ga",
        },
        -- Align only first column of "=" by default
        modifiers = {
          ["="] = function(steps, opts)
            opts.split_pattern = "%p*=+[<>~]*"
            table.insert(steps.pre_justify, MiniAlign.gen_step.trim())
            table.insert(steps.pre_justify, MiniAlign.gen_step.filter("n==1"))
            opts.merge_delimiter = " "
          end,
        },
      })

      require("mini.bracketed").setup({
        comment = { suffix = "" },    -- treesitter Class/conditional
        file = { suffix = "" },       -- treesitter function
        location = { suffix = "" },   -- treesitter loop
      })

      require("mini.diff").setup({
        mappings = {
          goto_prev = "[g",
          goto_next = "]g",
          textobject = "ig",
        },
        view = {
          signs = { add = "┃", change = "┃", delete = "┃" },
        },
      })
      vim.keymap.set("n", "<leader>gs", "ghig", { remap = true })
      vim.keymap.set("x", "<leader>gs", "gh", { remap = true })
      vim.keymap.set("n", "<leader>gr", "gHig", { remap = true })
      vim.keymap.set("x", "<leader>gr", "gH", { remap = true })
      vim.keymap.set("n", "<leader>gd", require("mini.diff").toggle_overlay)

      require("mini.icons").setup()

      local np = "[^\\][^%a%d]"
      require("mini.pairs").setup({
        mappings = {
          ["("] = { neigh_pattern = np },
          ["["] = { neigh_pattern = np },
          ["{"] = { neigh_pattern = np },
          ['"'] = { neigh_pattern = np },
          ["'"] = { neigh_pattern = "[^\\%a][^%a%d]" },
          ["`"] = { neigh_pattern = np },
        },
      })
      -- Fix <cr> between tags indenting properly
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "htmldjango", "phtml", "templ", "xml" },
        callback = function()
          vim.keymap.set("i", "<cr>", "<cr><esc>O", { buffer = vim.api.nvim_get_current_buf() })
        end,
      })
      -- Disable mini.pairs when inserting from visual block mode
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "\x16:i",
        callback = function() vim.b.minipairs_disable = true end,
      })
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "i:n",
        callback = function() vim.b.minipairs_disable = false end,
      })

      require("mini.snippets").setup({
        snippets = {
          function(context)
            if context.lang == "go" then
              return {
                { prefix="ie", body="if err != nil {\n\t${1:panic(err)}\n}" },
                { prefix="iee", body="if err := $1; err != nil{\n\t${2:panic(err)}\n}" },
              }
            elseif context.lang == "lua" then
              return {
                { prefix="fe", body="function()\n\t$1\nend" },
                { prefix="ff", body="function() $1 end" },
              }
            end
          end
        },
      })
      vim.keymap.set("i", "<Tab>", function()
        if MiniSnippets.session.get() ~= nil then
          MiniSnippets.session.jump("next")
          return ""
        end
        return "\t"
      end, { expr = true })

      require("mini.surround").setup({ n_lines = 1000, respect_selection_type = true })
    end,
  }, -- }}}
  { "airblade/vim-rooter", -- {{{
    init = function()
      vim.g.rooter_change_directory_for_non_project_files = "current"
      vim.g.rooter_silent_chdir = 1
    end,
  }, -- }}}
  { "tpope/vim-sleuth", -- {{{
    config = function()
      for _, ft in pairs({ "css", "html", "javascript", "lua" }) do
        vim.g["sleuth_" .. ft .. "_defaults"] = "shiftwidth=2 tabstop=2"
      end
      for _, ft in pairs({ "go", "php" }) do
        vim.g["sleuth_" .. ft .. "_defaults"] = "noexpandtab"
      end
    end,
  }, -- }}}
  { "lambdalisue/vim-suda", -- {{{
  init = function()
  vim.g.suda_smart_edit = 1
  vim.keymap.set({ "n", "x" }, "<leader>w", [[<cmd>silent! wall<cr><cmd>redraw<cr>]])
  end
  }, -- }}}
  { "nvim-treesitter/nvim-treesitter", -- {{{
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.log").Logger.info = function(_, m, ...)
        vim.notify(m:format(...))
      end
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        callback = function(event)
          if not vim.tbl_contains(
            require("nvim-treesitter").get_available(),
            vim.bo[event.buf].filetype
          ) then return end
          require("nvim-treesitter").install(vim.bo[event.buf].filetype):wait(60000)
          vim.treesitter.language.add(vim.bo[event.buf].filetype)
          vim.treesitter.start(event.buf, vim.bo[event.buf].filetype)
          vim.bo[event.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end,
      })
      vim.keymap.set("n", "<leader>i", [[<cmd>Inspect<cr>]])
    end,
  }, -- }}}
  { "nvim-treesitter/nvim-treesitter-context", -- {{{
    config = function()
      require("treesitter-context").setup({ enable = false })
      vim.keymap.set("n", "[`", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end)
    end,
    keys = {{ "<leader>`", ":TSContext toggle<cr>" }},
  }, -- }}}
  { "nvim-treesitter/nvim-treesitter-textobjects", -- {{{
    branch = "main",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = false },
      })

      local move = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")

      local keys = {
        a = "@parameter",
        C = "@class",
        c = "@conditional",
        f = "@function",
        L = "@loop",
      }

      for key, capture in pairs(keys) do
        vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
          move.goto_next_start(capture .. ".outer")
        end)
        vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
          move.goto_previous_start(capture .. ".outer")
        end)
        vim.keymap.set({ "x", "o" }, "i" .. key, function()
          select.select_textobject(capture .. ".inner")
        end)
        vim.keymap.set({ "x", "o" }, "a" .. key, function()
          select.select_textobject(capture .. ".outer")
        end)
      end

      vim.keymap.set("n", "<leader>al", function()
        swap.swap_next("@parameter.inner")
      end)
      vim.keymap.set("n", "<leader>ah", function()
        swap.swap_previous("@parameter.inner")
      end)
    end,
  }, -- }}}
  { "Wansmer/treesj", -- {{{
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("treesj").setup({
        use_default_keymaps = false,
        langs = {
          htmldjango = require("treesj.langs.html"),
        },
      })
    end,
    keys = {
      { "<leader>j", [[:TSJSplit<cr>]] },
      { "<leader>J", [[:TSJJoin<cr>]] },
    }
  }, -- }}}
  { "neovim/nvim-lspconfig", -- {{{
    ft = { "go", "lua", "php", "python" },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = {
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })

      vim.lsp.enable({
        "basedpyright",
        "gopls",
        "intelephense", -- npm install -g intelephense
        "lua_ls",
        "ruff",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          client.server_capabilities.semanticTokensProvider = nil
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        signs = false,
        virtual_text = true,
      })

      vim.keymap.set("n", "ge", vim.diagnostic.open_float)
      vim.keymap.set({ "n", "i" }, "<C-s>", function() vim.lsp.buf.signature_help() end)
      vim.keymap.set("n", "<leader>dd", vim.diagnostic.setqflist)
    end
  }, -- }}}
  { "folke/lazydev.nvim", -- {{{
    ft = "lua",
    opts = {
      library = {
        "mini.nvim",
        "snacks.nvim",
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "~/.config/hammerspoon/Spoons/EmmyLua.spoon/annotations" },
      },
    },
  }, -- }}}
  { "saghen/blink.cmp", -- {{{
    version = '1.*',
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      require("blink-cmp").setup({
        keymap = {
          preset = "super-tab",
          ["<C-k>"] = {},
          ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback' },
        },
        completion = {
          accept = {
            auto_brackets = {
              enabled = true,
            },
          },
          documentation = { auto_show = true },
        },
        enabled = function()
          return next(require("mini.snippets").session.get() or {}) == nil
        end,
        signature = { enabled = true },
        sources = {
          default = { "lazydev", "lsp", "path", "snippets", "buffer" },
          providers = {
            buffer = { score_offset = -7 },
            lsp = { fallbacks = {} }, -- Always show buffer items
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        },
        snippets = { preset = "mini_snippets" },
        cmdline = {
          completion = {
            menu = { auto_show = function() return vim.fn.getcmdtype() == ":" end },
          },
          keymap = { preset = "inherit" },
        },
      })
    end,
  }, -- }}}
  { "stevearc/conform.nvim", -- {{{
    opts = {
      formatters = {
        xmlformatter = {
          command = "uvx",
          args = { "--from", "xmlformatter", "xmlformat", "-" },
        },
      },
      formatters_by_ft = {
        go = { "gofmt" },
        json = { "jq" },
        python = { "ruff_format" },
        xml = { "xmlformatter" },
      },
    },
    keys = {{
      "<leader>=", mode = { "n", "x" }, function()
        require("conform").format({ lsp_format = "fallback", timeout_ms = 2000 })
      end,
    }},
  }, -- }}}
  { "NeogitOrg/neogit", -- {{{
    dependencies = "nvim-lua/plenary.nvim",
    init = function()
      vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
          if vim.bo.filetype == "NeogitCommitMessage" or vim.bo.filetype == "gitcommit" then
            vim.opt_local.spell = true
          end
        end,
      })
    end,
    config = function()
      require("neogit").setup({
        disable_hint = true,
        disable_insert_on_commit = true,
        console_timeout = 5000,
        graph_style = "kitty",
        sections = {
          untracked = { folded = true, hidden = false },
        },
      })
    end,
    cmd = "Neogit",
    keys = {{ "<D-g>", mode = { "n", "i", "x" },
      [[<cmd>silent! wall<cr><cmd>Neogit kind=replace<cr>]]
    }},
  }, -- }}}
  { "tpope/vim-fugitive", -- {{{
    cmd = { "Gedit" },
    keys = {{ "<leader>gb", [[<cmd>Git blame<cr>]] }},
  }, -- }}}
  { "stevearc/oil.nvim", -- {{{
    init = function()
      vim.g.loaded_netrwPlugin = 1
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = vim.schedule_wrap(function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if vim.fn.isdirectory(bufname) == 1 then
            vim.cmd("Oil " .. bufname)
          end
        end),
      })
    end,
    config = function()
      require("oil").setup({
        delete_to_trash = vim.fn.has("mac") == 1,
        skip_confirm_for_simple_edits = true,
        columns = {
          { "mtime", highlight = "Comment" },
          { "size", highlight = "Blue" },
          { "icon" },
        },
        keymaps = {
          ["<esc>"] = { "actions.close", mode = "n" },
          ["<C-h>"] = false,
          ["<C-l>"] = false,
          ["<C-p>"] = "actions.preview",
          ["<C-r>"] = "actions.refresh",
          ["<D-c>"] = { "", mode = "o" }, -- Disable default cmd+c omap
          ["<D-c><D-c>"] = {
            function()
              vim.fn.setreg("+", require("oil").get_current_dir() .. require("oil").get_cursor_entry().name)
            end, mode = "n", desc = "Copy full file path to clipboard",
          },
          ["~"] = {
            function() require("oil").open(vim.fn.expand("~")) end,
            desc = "Jump to home directory",
          },
        },
        win_options = { winbar = "%{v:lua.require('oil').get_current_dir()}" },
      })
      vim.api.nvim_set_hl(0, "WinBar", { link = "Title" })
    end,
    cmd = "Oil",
    keys = {{"-", [[<cmd>Oil<cr>]] }},
  }, -- }}}
  { "stevearc/quicker.nvim", -- {{{
    ft = "qf",
    opts = {
      keys = {
        { "<Tab>", "<cr><C-w>w" },
        { ">", function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end },
        { "<", function() require("quicker").collapse() end },
      },
    },
    keys = {{ "<leader>q", function() require("quicker").toggle() end }},
  }, -- }}}
  { "https://codeberg.org/andyg/leap.nvim.git", -- {{{
    config = function()
      vim.keymap.set("n", "<leader><leader>", [[<Plug>(leap-anywhere)]])
      vim.keymap.set({ "x", "o" }, "<leader><leader>", [[<Plug>(leap)]])
    end,
  }, -- }}}
  { "chrishrb/gx.nvim", -- {{{
    submodules = false,
    opts = {},
    keys = { { "gx", mode = { "n", "x" }, [[<cmd>Browse<cr>]] } },
  }, -- }}}
  { "brenoprata10/nvim-highlight-colors", -- {{{
    opts = { exclude_filetypes = { "bigfile" } },
  }, -- }}}
  { "hat0uma/csvview.nvim", -- {{{
    opts = {
      view = { display_mode = "border" },
      keymaps = {
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    keys = {{ "<leader>,", [[<cmd>CsvViewToggle<cr>]] }},
  }, -- }}}
  { "iamcco/markdown-preview.nvim", -- {{{
    enabled = vim.fn.has("mac") == 1,
    ft = "markdown",
    build = [[cd app && npm install && git restore .]],
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.wrap = true
        end,
      })
    end,
    keys = {{ "<leader>m", "<cmd>MarkdownPreviewToggle<cr>" }},
  }, -- }}}
  { "olimorris/codecompanion.nvim", -- {{{
    enabled = vim.fn.has("mac") == 1,
    build = ":TSInstall yaml",
    config = function()
      require("codecompanion").setup({
        adapters = {
          http = {
            openrouter = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                url = "https://openrouter.ai/api/v1/chat/completions",
                env = { api_key = "cmd:cat ~/.dotfiles/openrouter_work.key" },
                headers = { ["X-Title"] = "Neovim", ["HTTP-Referer"] = "https://neovim.io" },
                schema = { model = { default = "anthropic/claude-sonnet-4.6" } },
              })
            end
          }
        },
        strategies = {
          chat = { adapter = "openrouter" },
          inline = { adapter = "openrouter" },
          cmd = { adapter = "openrouter" },
        },
      })
    end,
    keys = {
      { "<leader>ai", mode = "n", ":CodeCompanion<cr>" },
      { "<leader>ai", mode = "x", ":<C-u>'<,'>CodeCompanion " },
      { "<leader>an", mode = "n", ":CodeCompanionChat<cr>" },
      { "<leader>av", mode = "n", ":CodeCompanionChat Toggle<cr>" },
      { "<leader>ap", mode = "x", ":CodeCompanionChat Add<cr>" },
    },
  }, -- }}}
  { "mistweaverco/kulala.nvim", -- {{{
    ft = "http",
    opts = {
      global_keymaps = true,
      additional_curl_options = { "-L" },
    },
  }, -- }}}
  { "mikesmithgh/kitty-scrollback.nvim", -- {{{
    enabled = vim.fn.has("mac") == 1,
    config = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
  }, -- }}}
  { "mrjones2014/smart-splits.nvim", -- {{{
    enabled = vim.fn.has("mac") == 1,
    build = "mkdir -p ~/.config/kitty && ./kitty/install-kittens.bash",
    config = function()
      require("smart-splits").setup()
      local modes = { "n", "i", "x", "c" }
      vim.keymap.set(modes, "<C-h>", require("smart-splits").move_cursor_left)
      vim.keymap.set(modes, "<C-j>", require("smart-splits").move_cursor_down)
      vim.keymap.set(modes, "<C-k>", require("smart-splits").move_cursor_up)
      vim.keymap.set(modes, "<C-l>", require("smart-splits").move_cursor_right)
      vim.keymap.set(modes, "<C-A-h>", require("smart-splits").resize_left)
      vim.keymap.set(modes, "<C-A-j>", require("smart-splits").resize_down)
      vim.keymap.set(modes, "<C-A-k>", require("smart-splits").resize_up)
      vim.keymap.set(modes, "<C-A-l>", require("smart-splits").resize_right)
    end,
  }, -- }}}
  { "fladson/vim-kitty", -- {{{ Can be removed in Neovim v0.12
    ft = "kitty",
  }, -- }}}
  { dir = "~/Code/hackernews.nvim", -- {{{
    enabled = vim.fn.has("mac") == 1,
    cmd = "HackerNews",
  }, -- }}}
})

--[[ Keymaps ]]-- {{{
vim.keymap.set("n", "<leader>L", [[<cmd>Lazy<cr>]])

-- Exit insert mode
vim.keymap.set("i", "jk", "<esc>")

-- Clear search highlights
vim.keymap.set("n", "<esc>", [[<cmd>nohlsearch<cr>]])

-- Search in visual selection
vim.keymap.set("x", "//", "<Esc>/\\%V")

-- Copy to clipboard and highlight yanks
vim.keymap.set({ "n", "x" }, "<D-c>", [["+y]])
vim.keymap.set("o", "<D-c>", [[il]], { remap = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Substitute", timeout = 200, on_visual = true })
  end,
})

-- Select last changed or pasted region
vim.keymap.set("n", "gp", [[ "`[" . getregtype() . "`]" ]], { expr = true, })

-- Move to first character and end of lines with homerow
vim.keymap.set({ "n", "o", "x" }, "H", "_")
vim.keymap.set({ "n", "o", "x" }, "L", "g_")

-- Easier `%`
vim.keymap.set({ "n", "o", "x" }, "M", "%", { remap = true })

-- Fix j/k movements in wrapped lines
vim.keymap.set({"n", "x"}, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({"n", "x"}, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Delete buffer without saving/prompt
vim.keymap.set("n", "<leader>k", [[<cmd>bw!<cr>]]) -- close split
vim.keymap.set("n", "<leader>K", [[<cmd>b#|bw! #<cr>]]) -- keep split

-- Keep splits equal
vim.api.nvim_create_autocmd("VimResized", { command = "wincmd =", })

-- Send to terminal
vim.keymap.set({ "n", "x" }, "<leader><cr>", function()
  local view = vim.fn.winsaveview()
  if vim.fn.mode() == "n" then vim.cmd([[normal V]]) end
  vim.cmd([[normal "vy]])
  local data = vim.fn.shellescape("\x1b[200~" .. vim.fn.getreg("v") .. "\x1b[201~\n")
  os.execute("printf '%s' " .. data .. " | kitty @ send-text --match recent:1 --stdin")
  vim.fn.winrestview(view)
end)

-- Exit quickly without prompts
vim.keymap.set({ "n", "x" }, "Q", [[<cmd>qa!<cr>]]) -- Without saving
vim.keymap.set({ "n", "x" }, "Z", [[<cmd>silent! xa!<cr><cmd>qa!<cr>]]) -- Save if modified
-- }}}

-- vim: foldmethod=marker foldlevel=0
