-- 1. 基本設定 (Sane Defaults)
vim.g.mapleader = " "             -- LeaderキーをSpaceに設定

vim.opt.number = true             -- 現在の行番号を表示する
vim.opt.relativenumber = true     -- 現在行以外の行番号を、現在行からの相対的な行数で表示する
vim.opt.termguicolors = true      -- ターミナルでのTrue Color (24bit) 表示を有効にし、テーマの色を正確に再現する
vim.opt.ignorecase = true         -- 検索時に大文字と小文字を区別しない
vim.opt.smartcase = true          -- 検索語に大文字が含まれている場合のみ、大文字小文字を厳密に区別する
vim.opt.updatetime = 250          -- UIの更新やスワップ保存までの待機時間を短縮し、体感速度を上げる(デフォルト4000ms)
vim.opt.expandtab = true          -- タブ入力を複数の空白（スペース）に置き換える
vim.opt.tabstop = 2               -- 画面上でタブ文字が占める幅（スペース2つ分）
vim.opt.shiftwidth = 2            -- 自動インデントや `<` `>` コマンドでずれる幅
vim.opt.smartindent = true        -- 新しい行を開始したときに、前の行の構文に合わせて賢くインデントを下げる
vim.opt.clipboard = "unnamedplus" -- ヤンクや削除したテキストをシステムのクリップボードと同期する
vim.opt.signcolumn = "yes"        -- 左側のサイン列を常に表示（ガタつき防止）
vim.opt.cursorline = true         -- 現在の行をハイライト（視認性向上）
vim.opt.wrap = false              -- 行を折り返さない（コードリーディング用、好みで変更）
vim.opt.scrolloff = 8             -- スクロール時にカーソルの上下に確保する最低行数（端まで行かず常に文脈が見える）
vim.opt.splitright = true         -- 縦分割（vsplit）時に新しいウィンドウを右側に開く
vim.opt.splitbelow = true         -- 横分割（split）時に新しいウィンドウを下側に開く

-- 2. パッケージマネージャ (lazy.nvim のブートストラップ)
-- lazy.nvim がインストールされていない場合は自動で GitHub からダウンロードする
local lazypath = vim.fn.stdpath("data").. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
-- プラグインを読み込めるように Neovim の runtimepath の先頭に追加する
vim.opt.rtp:prepend(lazypath)

-- 3. プラグインのロードと設定
require("lazy").setup({
  -- UI・カラースキーム設定
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- 起動時に即座に読み込む
    priority = 1000, -- 他のプラグインより最優先で読み込み、UIの描画崩れを防ぐ
    config = function()
      vim.cmd([[colorscheme tokyonight]]) -- カラースキームを適用
    end,
  },

  -- エコシステムの統合 (mini.nvim)
  -- 多数の単機能プラグインをこれ一つで高速に代替します
  {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
      require("mini.icons").setup()       -- ファイルタイプに応じたアイコンを表示
      require("mini.statusline").setup()  -- 画面下部のステータスラインを描画
      require("mini.pairs").setup()       -- カッコやクオートなどのオートペアを自動入力
      require("mini.comment").setup()     -- gccでコメントトグル
      require("mini.surround").setup()    -- 囲み文字（クオートやカッコ）の追加・削除・変更を高速化(sa/sd/sr)
      require("mini.ai").setup()          -- 関数の中身や引数など、賢い範囲選択（テキストオブジェクト）を拡張
      require("mini.indentscope").setup({
        symbol = "│"
      }) -- 現在いるインデントブロックを縦線とアニメーションで視覚的にハイライト
      require("mini.move").setup()
      require("mini.pick").setup()        -- fuzzy finder
      require("mini.bufremove").setup()   -- window layout を壊さず buffer を閉じる

      require("mini.files").setup({
        options = {
          use_as_default_explorer = true
        }
      })       -- シンプルで強力なファイルシステム操作 (ファイラー)

      -- ファイル検索
      vim.keymap.set("n", "-", function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0))
      end, { desc = "Open file explorer" })
      vim.keymap.set("n", "<leader>ff", function()
        require("mini.pick").builtin.files()
      end, { desc = "File search"})
      -- プロジェクト全文検索 (ripgrep)
      vim.keymap.set("n", "<leader>fg", function()
        require("mini.pick").builtin.grep_live()
      end, { desc = "Grep project" })

      -- buffer一覧
      vim.keymap.set("n", "<leader>fb", function()
        require("mini.pick").builtin.buffers()
      end, { desc = "Buffers" })

      -- レイアウトを崩さずにバッファを閉じる
      vim.keymap.set("n", "<leader>bd", function()
        require("mini.bufremove").delete()
      end, { desc = "Delete buffer" })

      -- which-key にキーグループの名前を登録し、ポップアップ表示を見やすくする
      require("which-key").add({
        { "<leader>f", group = "find" },   -- <leader>f 系をまとめて「find」グループとして表示
        { "<leader>b", group = "buffer" }, -- <leader>b 系をまとめて「buffer」グループとして表示
      })
    end
  },

  -- 次世代補完エンジン (blink.cmp)
  -- 非常に高速で、LSPやスニペットソースが最初から同梱されています
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = { preset = 'default' }, -- デフォルトの補完キーバインドを使用する
      appearance = {
        use_nvim_cmp_as_default = false, -- 従来の nvim-cmp の見た目をエミュレートしない
        nerd_font_variant = 'mono'       -- アイコンの表示に Nerd Font の等幅バリアントを使用する
      },
    }
  },

  -- Git差分表示 (gitsigns.nvim)
  -- 変更された行をサイドバーに表示し、hunk単位のstageやblame確認などが可能
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true, -- 起動時に自動表示したい場合
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 行末に表示
        delay = 100,
      },
      signs = {
        add    = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
      },
    },
  },

  -- シンタックスハイライト・インデント・テキストオブジェクトの基盤 (nvim-treesitter)
  -- パーサーをインストールして構文木ベースの高精度なハイライトを提供する
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    main = 'nvim-treesitter',
    opts = {
      ensure_installed = { 'lua', 'javascript', 'typescript', 'python', 'tsx', 'json', 'yaml', 'markdown' },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  }
})

-- 4. LSPアタッチ時のキーマップ設定
-- LSPがバッファにアタッチしたタイミングで自動的にキーマップを登録する
-- LspAttach イベントを使うことで、LSP未起動のバッファには影響しない
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    -- カーソル下のシンボルの定義へジャンプする
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
    -- カーソル下のシンボルの型定義へジャンプする
    vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Go to type definition' }))
    -- カーソル下のシンボルのホバードキュメントをポップアップ表示する
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
    -- カーソル下のシンボルの参照箇所を一覧表示する
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Go to references' }))
    -- カーソル下のシンボルをプロジェクト全体でリネームする
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
    -- カーソル位置で使えるコードアクション（自動修正・リファクタリング等）を表示する
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
    -- 現在のバッファをLSPのフォーマッタで整形する
    vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format, vim.tbl_extend('force', opts, { desc = 'Format buffer' }))
    -- 現在行の診断（エラー・警告）をフローティングウィンドウで表示する
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'Show diagnostics' }))
    -- 前の診断箇所へジャンプする
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
    -- 次の診断箇所へジャンプする
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
  end,
})

-- 5. ネイティブLSP構成 (Neovim 0.11/0.12 方式)
-- LuaCATSアノテーションを活用して静的型チェックの恩恵を受けます
---@param server_name string
---@param cmd string[]
---@param filetypes string[]
---@param root_markers string[] プロジェクトルートを判定する基準ファイル・ディレクトリ名のリスト
-- LSPを登録して有効化するためのヘルパー関数
local function setup_lsp(server_name, cmd, filetypes, root_markers)
  vim.lsp.config[server_name] = {
    cmd = cmd,
    filetypes = filetypes,
    -- 言語サーバーごとに適切なルートマーカーを個別指定することで、誤検知を防ぐ
    root_markers = root_markers,
  }
  vim.lsp.enable(server_name) -- サーバーを起動
end

-- 例: Lua言語サーバーの起動設定
setup_lsp('lua_ls', { 'lua-language-server' }, { 'lua' }, { '.luarc.json', '.git' })
