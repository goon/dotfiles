return {
	{
		"snacks.nvim",
		opts = {
			dashboard = {
				width = 50,
				sections = function()
					local header = [[
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]]

          -- stylua: ignore
          return {
            { padding = 2, align = "center", text = { header, hl = "header" } },
            { padding = 1, key = "f", desc = "Find File",       action = ":lua Snacks.dashboard.pick('files')" },
            { padding = 1, key = "n", desc = "New File",        action = ":ene | startinsert" },
            { padding = 1, key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('recent')" },
            { padding = 1, key = "p", desc = "Recent Projects", action = ":lua Snacks.dashboard.pick('projects')" },
            { padding = 1, key = "s", desc = "Restore Session", section = "session" },
            { padding = 1, key = "c", desc = "Config",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { padding = 1, key = "l", desc = "Lazy",            action = ":Lazy" },
            { padding = 1, key = "x", desc = "Lazy Extras",     action = ":LazyExtras" },
            { padding = 1, key = "q", desc = "Quit",            action = ":qa" },
            { section = "startup" },
          }
				end,
			},
		},
	},
}
