return {
  "folke/noice.nvim",
  keys = {
    { "<leader>sn", false },
    { "<leader>snl", false },
    { "<leader>snh", false },
    { "<leader>sna", false },
    { "<leader>snd", false },
    { "<leader>snt", false },
    { "<leader>nh", function() require("noice").cmd("history") end, desc = "Notification History" },
    { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Dismiss Notifications" },
  },
}