-- TODO: Clientside indicator
-- SetCollisionGroup(COLLISION_GROUP_WORLD) should also be clientside?
-- Should clientside indicator have name spinning above or just drawn on grave like progress bar?

local folder = "revive"
local function load(name)
	local realm = string.sub(name, 1, 2)
	local path = folder .. "/" .. name
	if realm == "sv" and SERVER then
		include(path)
	elseif realm == "cl" then
		if SERVER then
			AddCSLuaFile(path)
		else
			include(path)
		end
	elseif realm == "sh" then
		if SERVER then
			AddCSLuaFile(path)
		end
		include(path)
	end
end

load("sv_revive.lua")
load("cl_revive.lua")
