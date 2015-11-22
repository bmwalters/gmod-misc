esc.cfg.Hostname		= "ZerfTestServer"
esc.cfg.BackgroundURL	= ""

esc.cfg.Bar				= Color(59, 59, 59)
esc.cfg.Stats			= Color(40, 40, 40)
esc.cfg.Background		= Color(0,0,0,150)
esc.cfg.Button			= Color(64, 130, 109)
esc.cfg.ButtonHover		= Color(245, 245, 245)
esc.cfg.ButtonText		= Color(245, 245, 245)
esc.cfg.ButtonTextHover	= Color(0,0,0)

esc.AddButton({
	Name = "Website",
	DoClick = function()
		gui.OpenURL("http://zorf.me")
	end,
})
esc.AddButton({
	Name = "MOTD",
	DoClick = function()
		MOTD.Create()
		esc.ToggleMenu()
	end,
})
esc.AddSpacer()
esc.AddButton({
	Name = "Options",
	DoClick = function()
		gui.ActivateGameUI()
		RunConsoleCommand("gamemenucommand", "openoptionsdialog")
	end,
})
esc.AddSpacer()
esc.AddButton({
	Name = "Resume",
	DoClick = function()
		esc.ToggleMenu()
	end,
})
esc.AddSpacer()
esc.AddButton({
	Name = "Disconnect",
	DoClick = function()
		RunConsoleCommand("disconnect")
	end,
})

esc.cfg.PlayerStats = {
	{
		IconMat = Material("icon16/coins.png"),
		Name = "Pointshop Points",
		Func = function(ply)
			return ply:PS_GetPoints()
		end
	},
	{
		IconMat = Material("icon16/clock.png"),
		Name = "Playtime",
		Func = function(ply)
			return 2000
		end
	},
}