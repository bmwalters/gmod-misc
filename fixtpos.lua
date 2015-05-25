if (GAMEMODE_NAME ~= "terrortown") then return end

local tposmaps = {
	["ttt_giant_daycare_v2"] = true,
}

-- Setting GAMEMODE.force_plymodel = '' doesn't work
hook.Add("PlayerSetModel", "TTT_FixTPos", function(ply)
	if not tposmaps[string.lower(game.GetMap())] then return end

	if ply:GetModel() == GAMEMODE.force_plymodel then
		ply:SetModel("models/player/leet.mdl")
		return "models/player/leet.mdl" -- stop ttt default from running
	end
	timer.Simple(0.5, function()
		if ply:GetModel() == GAMEMODE.force_plymodel then
			ply:SetModel("models/player/leet.mdl")
			return "models/player/leet.mdl" -- stop ttt default from running
		end
	end)
end)
