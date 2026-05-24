-- ============================================================================
-- Neovim · Markdown & Note-Taking Configuration
-- Package manager: lazy.nvim (auto-bootstrapped on first run)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. LEADER KEY
-- Must be defined before lazy.nvim so all plugins inherit the correct leader.
-- ----------------------------------------------------------------------------
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ----------------------------------------------------------------------------
-- 2. EDITOR OPTIONS
-- Settings tuned for distraction-free prose and note writing.
-- ----------------------------------------------------------------------------
local opt = vim.opt

-- Display — minimal chrome, no line numbers to keep focus on content
opt.number         = false
opt.relativenumber = false
opt.signcolumn     = "yes"    -- fixed-width gutter prevents layout shifts
opt.colorcolumn    = ""       -- no ruler column in prose
opt.termguicolors  = true     -- 24-bit colour support
opt.scrolloff      = 8        -- keep context lines above/below cursor

-- Indentation
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true     -- spaces, not tabs

-- Search
opt.ignorecase     = true
opt.smartcase      = true     -- case-sensitive only when query contains uppercase

-- Windows & history
opt.splitbelow     = true
opt.splitright     = true
opt.undofile       = true     -- undo history persists across sessions
opt.updatetime     = 250      -- ms before CursorHold fires (LSP hover, etc.)
opt.timeoutlen     = 300      -- ms to wait for a mapped sequence to complete
opt.completeopt    = { "menu", "menuone", "noselect" }
opt.clipboard      = "unnamed,unnamedplus" -- sync with system clipboard

-- ----------------------------------------------------------------------------
-- 3. BOOTSTRAP LAZY.NVIM
-- Clones lazy.nvim automatically if it is not already present.
-- ----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.notify("Bootstrapping lazy.nvim...", vim.log.levels.INFO)
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ----------------------------------------------------------------------------
-- 4. PLUGINS
-- ----------------------------------------------------------------------------
require("lazy").setup({

  -- ── Colorscheme: Tokyonight ─────────────────────────────────────────────
  -- Loaded eagerly (priority 1000) so it applies before everything else.
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
      require("tokyonight").setup({
        style       = "night",
        transparent = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          sidebars = "transparent",
          floats   = "transparent",
        },
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- ── Icons ───────────────────────────────────────────────────────────────
  -- Provides file-type icons used by lualine, telescope, etc.
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Status bar: Lualine ─────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme                = "tokyonight",
        globalstatus         = true,
        component_separators = { left = "│", right = "│" },
        section_separators   = { left = "", right = "" },
      },
    },
  },

  -- ── Indent guides: indent-blankline ─────────────────────────────────────
  -- Draws vertical lines to show indentation scope.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope  = { enabled = true },
    },
  },

  -- ── Fuzzy finder: Telescope ─────────────────────────────────────────────
  -- Used for searching notes, files, and grep across the vault.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        prompt_prefix        = "   ",
        selection_caret      = "  ",
        file_ignore_patterns = { "%.git/", "node_modules/" },
      },
    },
  },

  -- ── Note management: Obsidian.nvim ──────────────────────────────────────
  -- Wiki-style linking, daily notes, backlinks, and tag navigation.
  -- Update `path` below to point to your notes vault directory.
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy    = true,
    ft      = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
      },
      completion = {
        nvim_cmp  = true,
        min_chars = 2,
      },
      -- Note IDs are prefixed with a Unix timestamp for chronological sorting.
      -- Example output: "1691234567-my-note-title"
      note_id_func = function(title)
        local suffix = title
          and title:gsub(" ", "-"):gsub("[^a-zA-Z0-9-]", ""):lower()
          or  tostring(math.random(1000, 9999))
        return tostring(os.time()) .. "-" .. suffix
      end,
      ui = {
        enable = true,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "",  hl_group = "ObsidianDone" },
        },
      },
    },
  },

  -- ── Markdown preview ────────────────────────────────────────────────────
  -- Renders the current Markdown file in the browser (requires npm).
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init  = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft    = { "markdown" },
  },

  -- ── Autocompletion: nvim-cmp ────────────────────────────────────────────
  -- Obsidian completion sources are ranked above generic ones so that
  -- wiki links and tags appear first when editing Markdown files.
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP symbols
      "hrsh7th/cmp-buffer",       -- words in open buffers
      "hrsh7th/cmp-path",         -- filesystem paths
      "L3MON4D3/LuaSnip",         -- snippet engine
      "saadparwaiz1/cmp_luasnip", -- LuaSnip source for cmp
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if     cmp.visible()                then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else   fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp",     priority = 1000 },
          { name = "obsidian",     priority = 900  }, -- [[wiki links]]
          { name = "obsidian_new", priority = 800  }, -- new note creation
          { name = "obsidian_tags",priority = 750  }, -- #tags
          { name = "luasnip",     priority = 700  },
          { name = "path",        priority = 500  },
          { name = "buffer",      priority = 250, keyword_length = 4 },
        }),
      })
    end,
  },

  -- ── LSP toolchain: Mason + mason-lspconfig + nvim-lspconfig ────────────
  -- Mason installs language servers; marksman provides Markdown LSP features:
  -- go-to-definition for links, hover on headings, and workspace-wide TOC.
  {
    "williamboman/mason.nvim",
    cmd  = "Mason",
    opts = { ui = { border = "rounded" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = { ensure_installed = { "marksman" } },
  },
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- vim.lsp.config is the current API (nvim-lspconfig v3 / nvim 0.11+).
      vim.lsp.config("marksman", { capabilities = capabilities })
      vim.lsp.enable("marksman")
    end,
  },
})

-- ----------------------------------------------------------------------------
-- 5. MARKDOWN AUTOCOMMANDS
-- Applied to markdown and plain-text buffers to optimise the writing experience.
-- ----------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "markdown", "text" },
  callback = function()
    local o = vim.opt_local
    o.wrap         = true   -- soft-wrap long lines
    o.linebreak    = true   -- wrap only at word boundaries
    o.spell        = true   -- enable spell checking
    o.spelllang    = "en_us"
    o.conceallevel = 2      -- conceal syntax markers (e.g. **bold** → bold)

    -- Move by visual line so wrapped prose feels natural
    vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })

    -- Show spelling suggestions for the word under the cursor
    vim.keymap.set("n", "<leader>s", "z=", { buffer = true, desc = "Spell suggestions" })
  end,
})

-- ----------------------------------------------------------------------------
-- 6. KEYMAPS
-- <leader> is Space. Mappings are grouped by category.
-- ----------------------------------------------------------------------------

-- General
vim.keymap.set("n", "<Esc>",     "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>",          { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>",          { desc = "Quit" })

-- File navigation (Telescope)
-- Wrapped in functions so telescope is required lazily on first use.
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep()  end, { desc = "Grep in files" })

-- Note management (Obsidian)
vim.keymap.set("n", "<leader>nn", "<cmd>ObsidianNew<CR>",       { desc = "New note" })
vim.keymap.set("n", "<leader>ns", "<cmd>ObsidianSearch<CR>",    { desc = "Search notes" })
vim.keymap.set("n", "<leader>nd", "<cmd>ObsidianToday<CR>",     { desc = "Today's daily note" })
vim.keymap.set("n", "<leader>nb", "<cmd>ObsidianBacklinks<CR>", { desc = "Note backlinks" })

-- Markdown preview
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown preview" })

-- Plugin managers
vim.keymap.set("n", "<leader>M", "<cmd>Mason<CR>", { desc = "Open Mason" })
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<CR>",  { desc = "Open Lazy" })
