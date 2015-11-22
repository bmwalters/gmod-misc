surface.CreateFont("esc.20", {font = "roboto", size = 20, weight = 400})

local function draw_Box(x, y, w, h, col)
	surface.SetDrawColor(col)
	surface.DrawRect(x, y, w, h)
end

local function draw_OutlinedBox(x, y, w, h, col, bordercol)
	surface.SetDrawColor(col)
	surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
	surface.SetDrawColor(bordercol)
	surface.DrawOutlinedRect(x, y, w, h)
end

local blur = Material("pp/blurscreen")
local function draw_Blur(panel, amount) -- Thanks nutscript
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

hook.Add("PreRender", "esc.PreRender", function()
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
		gui.HideGameUI()
		esc.ToggleMenu()
	end
end)

function esc.ToggleMenu()
	if IsValid(esc.Panel) then
		esc.Panel.Open = not esc.Panel.Open
		esc.Panel:SetVisible(esc.Panel.Open)
		return
	end

	esc.Panel = vgui.Create("DPanel")
	esc.Panel:SetSize(ScrW(), ScrH())
	esc.Panel:MakePopup()
	esc.Panel.Paint = function(self, w, h)
		draw_Blur(self, 10)
		draw_Box(0, 0, w, h, esc.cfg.Background)
	end
	esc.Panel.Open = true

	local html
	if esc.cfg.Background then
		html = vgui.Create("DHTML", esc.Panel)
		html:SetSize(ScrW(), ScrH())
		html:SetHTML([[
			<body style="margin:0; height:100%; overflow:hidden;">
	 			<img style="min-height:100%; min-width:100%; height:auto; width:auto; position:absolute; top:-50%; bottom:-50%; left:-50%; right:-50%; margin:auto;"" src="]] .. esc.cfg.BackgroundURL .. [[" alt="">
	 		</body>
		]])
	end

	local topbar = vgui.Create("DPanel", html)
	topbar:SetPos(20, 30)
	topbar:SetSize(ScrW() - 40, 30)
	topbar.Paint = function(self, w, h)
		draw_Box(0, 0, w, h, esc.cfg.Bar)
		draw.SimpleText(esc.cfg.Hostname , "esc.20", 5, self:GetTall() * .5, esc.cfg.ButtonText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(GAMEMODE.Name or "Unknown GM", "esc.20", self:GetWide() - 5, self:GetTall() * .5, esc.cfg.ButtonText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	local welcome = vgui.Create("DPanel", html)
	welcome:SetPos(20, 90)
	welcome:SetSize(ScrW() * .25, 30)
	welcome.Paint = function(self, w, h)
		draw_Box(0, 0, w, h, esc.cfg.Bar)
		draw.SimpleText("WELCOME!", "esc.20", 5, self:GetTall() * .5, esc.cfg.ButtonText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(LocalPlayer():Nick(), "esc.20", self:GetWide() - 5, self:GetTall() * .5, esc.cfg.ButtonText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	for i, v in ipairs(esc.menus) do
		if v.Spacer then continue end
		local btn = vgui.Create("DButton", html)
		btn:SetPos(20, 135 + ((i - 1) * 30))
		btn:SetSize(ScrW() * .25, 27)
		btn:SetText("")
		btn.Name = string.upper(v.Name)
		btn.DoClick = v.DoClick
		function btn:Paint(w, h)
			draw_Box(0, 0, w, h, self.Hovered and esc.cfg.ButtonHover or esc.cfg.Button)
			draw.SimpleText(self.Name, "esc.20", 5, self:GetTall() * .5, self.Hovered and esc.cfg.ButtonTextHover or esc.cfg.ButtonText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	local playerinfo = vgui.Create("DPanel", html) -- DFrame
	playerinfo:SetPos(20 + ScrW() * .25 + 20, 90)
	playerinfo:SetSize(ScrW() - 20 - (20 + ScrW() * .25 + 20), ScrH() - 30 - 90)
	playerinfo.Paint = function(self, w, h)
		draw_Box(0, 0, w, h, esc.cfg.Bar)
	end
	local pw, ph = playerinfo:GetSize()

	local avatar = vgui.Create("AvatarImage", playerinfo)
	avatar:SetSize(128, 128)
	avatar:SetPlayer(LocalPlayer(), 128)
	avatar:SetPos(20, 15)

	local nick = vgui.Create("DLabel", playerinfo)
	nick:SetText(LocalPlayer():Nick())
	nick:SetFont("DermaLarge")
	nick:SizeToContents()
	nick:SetPos(0, 150)
	nick:CenterHorizontal()

	local stats = vgui.Create("DPanel", playerinfo)
	stats:SetPos(20, 180)
	stats:SetSize(pw - 40, ph - 210)
	stats.Paint = function(self, w, h)
		draw_Box(0, 0, w, h, esc.cfg.Stats)
		draw.SimpleText("Player Information", "DermaLarge", 20, 20, esc.cfg.ButtonText)
		surface.SetDrawColor(esc.cfg.ButtonText)
		surface.DrawLine(20, 55, w - 20, 55)
		for i, v in pairs(esc.cfg.PlayerStats) do
			surface.SetMaterial(v.IconMat)
			local iconx, icony = 20, 70 + ((i - 1) * 50)
			surface.DrawTexturedRect(iconx, icony, 40, 40)
			surface.SetFont("esc.20")
			surface.SetTextColor(esc.cfg.ButtonText)
			local textw, texth = surface.GetTextSize(v.Name)
			surface.SetTextPos(iconx + 40 + 10, icony + 20 - texth/2)
			surface.DrawText(v.Name)
			--surface.SetTextPos(iconx, icony + 40 + 10)
			--surface.DrawText(v.Name)
		end
	end
end
