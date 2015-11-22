if SERVER then
	AddCSLuaFile("esc/avatarmask.lua")
	AddCSLuaFile("esc/esc_main.lua")
	AddCSLuaFile("esc/esc_config.lua")
else
	if esc and IsValid(esc.Panel) then esc.Panel:Remove() end
	esc = {}
	esc.menus = {}
	esc.cfg = {}

	function esc.AddButton(btn)
		esc.menus[#esc.menus + 1] = btn
	end
	local spacer = {Spacer=true}
	function esc.AddSpacer()
		esc.menus[#esc.menus + 1] = spacer
	end

	include("esc/avatarmask.lua")
	include("esc/esc_main.lua")
	include("esc/esc_config.lua")

	print("Escape menu loaded.")
end
