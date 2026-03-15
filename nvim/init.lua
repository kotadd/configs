-- 1. 基本設定 (Sane Defaults)
vim.g.mapleader = " " -- LeaderキーをSpaceに設定

vim.opt.number = true -- 現在の行番号を表示する
vim.opt.relativenumber = true -- 現在行以外の行番号を、現在行からの相対的な行数で表示する
vim.opt.termguicolors = true -- ターミナルでのTrue Color (24bit) 表示を有効にし、テーマの色を正確に再現する
vim.opt.ignorecase = true -- 検索時に大文字と小文字を区別しない
vim.opt.smartcase = true -- 検索語に大文字が含まれている場合のみ、大文字小文字を厳密に区別する
vim.opt.updatetime = 250 -- UIの更新やスワップ保存までの待機時間を短縮し、体感速度を上げる(デフォルト4000ms)
vim.opt.expandtab = true -- タブ入力を複数の空白（スペース）に置き換える
vim.opt.tabstop = 2 -- 画面上でタブ文字が占める幅（スペース2つ分）
vim.opt.shiftwidth = 2 -- 自動インデントや `<` `>` コマンドでずれる幅
vim.opt.smartindent = true -- 新しい行を開始したときに、前の行の構文に合わせて賢くインデントを下げる
vim.opt.clipboard = "unnamedplus" -- ヤンクや削除したテキストをシステムのクリップボードと同期する
vim.opt.signcolumn = "yes" -- 左側のサイン列を常に表示（ガタつき防止）
vim.opt.cursorline = true -- 現在の行をハイライト（視認性向上）
vim.opt.wrap = false -- 行を折り返さない（コードリーディング用、好みで変更）
vim.opt.scrolloff = 8 -- スクロール時にカーソルの上下に確保する最低行数（端まで行かず常に文脈が見える）
vim.opt.splitright = true -- 縦分割（vsplit）時に新しいウィンドウを右側に開く
vim.opt.splitbelow = true -- 横分割（split）時に新しいウィンドウを下側に開く

-- Treesitterの構文解析に基づいた折り畳み設定
vim.opt.foldcolumn = "1" -- 折り畳みの状態を左端に表示（任意）
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- 2. パッケージマネージャ (lazy.nvim のブートストラップ)
-- lazy.nvim がインストールされていない場合は自動で GitHub からダウンロードする
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
-- プラグインを読み込めるように Neovim の runtimepath の先頭に追加する
vim.opt.rtp:prepend(lazypath)

-- 3. プラグインのロードと設定
require("lazy").setup({
	-- UI・カラースキーム設定
	{
		"folke/tokyonight.nvim",
		lazy = false, -- 起動時に即座に読み込む
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
			require("mini.icons").setup() -- ファイルタイプに応じたアイコンを表示

			require("mini.statusline").setup() -- 画面下部のステータスラインを描画
			require("mini.pairs").setup() -- カッコやクオートなどのオートペアを自動入力

			require("mini.surround").setup() -- 囲み文字（クオートやカッコ）の追加・削除・変更を高速化(sa/sd/sr)
			require("mini.ai").setup() -- 関数の中身や引数など、賢い範囲選択（テキストオブジェクト）を拡張
			require("mini.indentscope").setup({
				symbol = "│",
			}) -- 現在いるインデントブロックを縦線とアニメーションで視覚的にハイライト
			require("mini.move").setup()
			require("mini.bufremove").setup() -- window layout を壊さず buffer を閉じる
			require("mini.files").setup({
				options = {
					use_as_default_explorer = true,
				},
			})
			-- ファイル検索
			vim.keymap.set("n", "-", function()
				require("mini.files").open(vim.api.nvim_buf_get_name(0))
			end, { desc = "Open file explorer" })

			-- レイアウトを崩さずにバッファを閉じる
			vim.keymap.set("n", "<leader>bd", function()
				require("mini.bufremove").delete()
			end, { desc = "Delete buffer" })

			-- which-key にキーグループの名前を登録し、ポップアップ表示を見やすくする
			require("which-key").add({
				{ "<leader>f", group = "find" }, -- <leader>f 系をまとめて「find」グループとして表示
				{ "<leader>b", group = "buffer" }, -- <leader>b 系をまとめて「buffer」グループとして表示
				{ "<leader>y", group = "yank path/name" }, -- コピー関連のグループ
				{ "<leader>r", group = "reference" }, -- 呼び出し元検索のグループ
			})
		end,
	},

	-- Neovim設定ファイル用の強力なLua開発環境 (lazydev.nvim)
	{
		"folke/lazydev.nvim",
		lazy = false,
		opts = {},
	},

	-- 次世代補完エンジン (blink.cmp)
	-- 非常に高速で、LSPやスニペットソースが最初から同梱されています
	{
		"saghen/blink.cmp",
		version = "*",
		opts = {
			keymap = { preset = "default" }, -- デフォルトの補完キーバインドを使用する
			appearance = {
				use_nvim_cmp_as_default = false, -- 従来の nvim-cmp の見た目をエミュレートしない
				nerd_font_variant = "mono", -- アイコンの表示に Nerd Font の等幅バリアントを使用する
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},
		},
	},

	-- プレビュー付きファジーファインダー (fzf-lua)
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			winopts = {
				preview = {
					default = "bat",
					layout = "vertical", -- 縦分割（右にプレビュー）
				},
			},
		},
		keys = {
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
			{
				"<leader>fF",
				function()
					-- ripgrepのデフォルトオプションに除外条件(-g '!*test*' など)を連結して実行
					require("fzf-lua").live_grep({
						rg_opts = "--column --line-number --no-heading --color=always --smart-case -g '!*.test.*' -g '!*.stories.*' -g '!__tests__/'",
					})
				end,
				desc = "Find files (Exclude tests)",
			},
			{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep project" },
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
			{
				"<leader>fG",
				function()
					-- ripgrepのデフォルトオプションに除外条件(-g '!*test*' など)を連結して実行
					require("fzf-lua").live_grep({
						rg_opts = "--column --line-number --no-heading --color=always --smart-case -g '!*.test.*' -g '!*.stories.*' -g '!__tests__/'",
					})
				end,
				desc = "Grep (Exclude tests)",
			},
		},
	},

	-- フォーマッタ (conform.nvim)
	-- PrettierなどをNeovimに統合し、<leader>cf で整形できるようにする
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
			},
			format_on_save = true,
		},
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format buffer (Conform)",
			},
		},
	},

	-- リンター (nvim-lint)
	-- ESLintなどを非同期で動かし、保存時などに画面上に警告を表示する
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
			}

			-- ファイル保存時やバッファを開いた時にLinterを実行
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
	-- LSPサーバー等の統合パッケージマネージャ (mason.nvim)
	-- Neovimの画面上からLSP、フォーマッタ、Linterなどをインストール・一元管理する
	{
		"williamboman/mason.nvim",
		opts = {
			PATH = "prepend",
		},
	},

	-- 新しいPCでもLSPサーバーを自動インストールしてくれる拡張
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"typescript-language-server",
				"prettier", -- JS/TS等のフォーマッタ
				"eslint_d", -- 高速なESLintラッパー
				"stylua", -- Luaフォーマッタ
			},
			auto_update = false,

			run_on_start = true,
		},
	},

	-- Git差分表示 (gitsigns.nvim)
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 100,
			},
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
			},
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- ナビゲーション: 変更箇所（Hunk）を次/前へジャンプ
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, { desc = "Next git hunk" })

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "Previous git hunk" })

				-- プレビューとDiff
				map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview git hunk" }) -- 変更前の状態をポップアップで確認
				map("n", "<leader>hd", gitsigns.diffthis, { desc = "Git diff against index" }) -- 画面分割で現在のファイルとインデックスを比較
				map("n", "<leader>hD", function()
					gitsigns.diffthis("~")
				end, { desc = "Git diff against last commit" }) -- 最後のコミットと比較

				-- トグル
				map("n", "<leader>hp", gitsigns.preview_hunk_inline, { desc = "Preview git hunk inline" }) -- 削除された行をインライン表示
			end,
		},
	},

	-- プロジェクト全体のGit差分・履歴ビューア (diffview.nvim)
	-- GitHubのPR画面のようなリッチな差分表示と、強力な履歴(log)確認機能を提供
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		-- 起動時間を早くするため、コマンドやキーマップが呼ばれた時だけ遅延ロードする

		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
		keys = {
			{ "<leader>do", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview (Git status)" },
			{ "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
			{ "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (Current)" },
			{ "<leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "Project History (Branch)" },
		},
		opts = {
			-- デフォルトで非常に使いやすいですが、お好みで設定を追加できます
			enhanced_diff_hl = true, -- より見やすい差分のハイライトを有効化
			view = {
				-- 差分表示のレイアウト設定
				default = {
					layout = "diff2_horizontal", -- 左右分割で差分を表示
				},
				merge_tool = {
					layout = "diff3_mixed", -- コンフリクト解消時は3ペイン表示
				},
			},
		},
	},

	-- シンタックスハイライト・インデント・テキストオブジェクトの基盤 (nvim-treesitter)
	-- パーサーをインストールして構文木ベースの高精度なハイライトを提供する
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		main = "nvim-treesitter",
		opts = {
			ensure_installed = { "lua", "javascript", "typescript", "python", "tsx", "json", "yaml", "markdown" },
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
			},
		},
	},

	-- 高性能な折り畳みエンジン (nvim-ufo)
	-- testブロックやReactコンポーネントを賢く閉じます
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufRead",
		opts = {
			provider_selector = function(bufnr, filetype, buftype)
				-- LSPを優先し、補助としてtreesitterを使用する設定
				return { "lsp", "indent" }
			end,
		},
		init = function()
			-- ufo 用のキーマップ
			vim.keymap.set("n", "zR", function()
				require("ufo").openAllFolds()
			end, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", function()
				require("ufo").closeAllFolds()
			end, { desc = "Close all folds" })
		end,
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
	},
})

-- 4. LSPアタッチ時のキーマップ設定
-- LSPがバッファにアタッチしたタイミングで自動的にキーマップを登録する
-- LspAttach イベントを使うことで、LSP未起動のバッファには影響しない
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
		-- カーソル下のシンボルの型定義へジャンプする
		vim.keymap.set(
			"n",
			"gD",
			vim.lsp.buf.type_definition,
			vim.tbl_extend("force", opts, { desc = "Go to type definition" })
		)
		-- カーソル下のシンボルのホバードキュメントをポップアップ表示する
		vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
		-- カーソル下のシンボルの参照箇所を一覧表示する
		vim.keymap.set("n", "gr", function()
			require("fzf-lua").lsp_references()
		end, vim.tbl_extend("force", opts, { desc = "参照を表示 (FzfLua)" }))

		vim.keymap.set("n", "gR", function()
			require("fzf-lua").lsp_references({
				fzf_opts = { ["--query"] = "!test !stories " }, -- 起動時に自動で除外ワードを入力
			})
		end, vim.tbl_extend("force", opts, { desc = "参照を表示 (テスト除外)" }))
		-- カーソル下のシンボルをプロジェクト全体でリネームする
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
		-- カーソル位置で使えるコードアクション（自動修正・リファクタリング等）を表示する
		vim.keymap.set(
			"n",
			"<leader>ca",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", opts, { desc = "Code action" })
		)
		-- 現在のバッファをLSPのフォーマッタで整形する
		vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
		-- 現在行の診断（エラー・警告）をフローティングウィンドウで表示する
		vim.keymap.set(
			"n",
			"<leader>e",
			vim.diagnostic.open_float,
			vim.tbl_extend("force", opts, { desc = "Show diagnostics" })
		)
		-- 前の診断箇所へジャンプする
		vim.keymap.set(
			"n",
			"[d",
			vim.diagnostic.goto_prev,
			vim.tbl_extend("force", opts, { desc = "Previous diagnostic" })
		)
		-- 次の診断箇所へジャンプする
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
	end,
})

-- 5. ネイティブLSP構成 (Neovim 0.11/0.12 方式)
-- LuaCATSアノテーションを活用して静的型チェックの恩恵を受けます
---@param server_name string
---@param cmd string[]
---@param filetypes string[]
---@param root_markers string[] プロジェクトルートを判定する基準ファイル・ディレクトリ名のリスト)
local function setup_lsp(server_name, cmd, filetypes, root_markers)
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	vim.lsp.config[server_name] = {
		cmd = cmd,
		filetypes = filetypes,
		root_markers = root_markers,
		capabilities = capabilities, -- LSPの頭脳とblink.cmpのUIを合体
	}
	vim.lsp.enable(server_name)
end

-- Lua言語サーバーの起動設定（Neovim専用のセッティングを追加）
setup_lsp("lua_ls", { "lua-language-server" }, { "lua" }, { ".luarc.json", ".git", "lazy-lock.json", "init.lua" })
-- TypeScript/JavaScript言語サーバーの起動設定
setup_lsp(
	"ts_ls",
	{ "typescript-language-server", "--stdio" },
	{ "typescript", "typescriptreact", "javascript", "javascriptreact" },
	{ "package.json", "tsconfig.json", ".git" }
)

-- ==========================================
-- 6. カスタムキーマップ
-- ==========================================

-- Space 2回で現在のブロックを折り畳み/展開 (zaの代替)
vim.keymap.set("n", "<leader><leader>", "za", { desc = "Toggle fold" })

-- コンポーネント名を取得するヘルパー関数
local function get_component_name()
	local basename = vim.fn.expand("%:t:r")
	if basename == "index" then
		return vim.fn.expand("%:h:t")
	end
	return basename
end

-- ------------------------------------------
-- ヤンク (コピー) 系: <leader>y...
-- ------------------------------------------
-- 拡張子ありのファイル名をコピー (例: Button.tsx)
vim.keymap.set("n", "<leader>yn", function()
	local filename = vim.fn.expand("%:t")
	vim.fn.setreg("+", filename)
	vim.notify("Copied: " .. filename, vim.log.levels.INFO)
end, { desc = "Yank file [n]ame" })

-- 拡張子なしのコンポーネント名を取得してコピー (ヘルパー関数を利用)
vim.keymap.set("n", "<leader>yc", function()
	local component_name = get_component_name()
	vim.fn.setreg("+", component_name)
	vim.notify("Copied Component: " .. component_name, vim.log.levels.INFO)
end, { desc = "Yank [c]omponent name" })

-- プロジェクトルートからの相対パスをコピー (例: src/components/Button.tsx)
vim.keymap.set("n", "<leader>yp", function()
	local relpath = vim.fn.expand("%")
	vim.fn.setreg("+", relpath)
	vim.notify("Copied: " .. relpath, vim.log.levels.INFO)
end, { desc = "Yank relative [p]ath" })

-- フルパスをコピー (例: /Users/name/project/src/components/Button.tsx)
vim.keymap.set("n", "<leader>yP", function()
	local fullpath = vim.fn.expand("%:p")
	vim.fn.setreg("+", fullpath)
	vim.notify("Copied: " .. fullpath, vim.log.levels.INFO)
end, { desc = "Yank full [P]ath" })

-- ------------------------------------------
-- 呼び出し元検索系: <leader>r...
-- ------------------------------------------
-- <leader>rc: 現在のコンポーネントの呼び出し元（例: <Button）を全体検索
vim.keymap.set("n", "<leader>rc", function()
	local component_name = get_component_name()
	require("fzf-lua").live_grep({
		search = "<" .. component_name,
	})
end, { desc = "Find [r]eference of [c]omponent" })

-- <leader>rC: 現在のコンポーネントの呼び出し元を全体検索（テストファイル等を除外）
vim.keymap.set("n", "<leader>rC", function()
	local component_name = get_component_name()
	require("fzf-lua").live_grep({
		search = "<" .. component_name,
		rg_opts = "--column --line-number --no-heading --color=always --smart-case -g '!*.test.*' -g '!*.stories.*' -g '!__tests__/'",
	})
end, { desc = "Find [r]eference of [C]omponent (Exclude tests)" })
