return {
	-- Detect tabstop and shiftwidth automatically
	"NMAC427/guess-indent.nvim",

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Smart window splitting and navigation
	{
		"mrjones2014/smart-splits.nvim",
		config = function()
			require("smart-splits").setup()

			-- Keymaps for resizing splits
			vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left, { desc = "Resize split left" })
			vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down, { desc = "Resize split down" })
			vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up, { desc = "Resize split up" })
			vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right, { desc = "Resize split right" })

			-- Keymaps for moving between splits
			vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Move to left split" })
			vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Move to below split" })
			vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Move to above split" })
			vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move to right split" })

			-- Keymaps for swapping buffers between windows
			vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
			vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
			vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
			vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
		end,
	},

	-- File explorer that lets you edit your filesystem like a buffer
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup()
		end,
		keys = {
			{ "<leader>e", "<cmd>Oil<cr>", desc = "Open oil file explorer" },
		},
	},
}