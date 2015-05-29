local color_red = COLOR_RED or color_red or Color(255, 0, 0)

local furrygroups = {
	"103582791429527670", -- https://steamcommunity.com/groups/furries
	"103582791429530109", -- https://steamcommunity.com/groups/furrehs
	"103582791429522274", -- https://steamcommunity.com/groups/FurriesUnited
	"103582791429523337", -- https://steamcommunity.com/groups/UKFur
	"103582791429606241", -- https://steamcommunity.com/groups/FurAffinityGamers
	"103582791429525408", -- https://steamcommunity.com/groups/fur
	"103582791433366073", -- https://steamcommunity.com/groups/AnFur
}

hook.Add("PlayerInitialSpawn", "GSAPI_JoinNotices", function(ply)
	local msg = {color_white, "Player "..ply:Nick().." ("..ply:SteamID()..") ".."joined the server."}
	SAPI.GetPlayerBans(ply:SteamID64(), function(data)
		if data.CommunityBanned then
			msg[#msg+1] = color_red
			msg[#msg+1] = "(Community Banned)"
		end
		if data.VACBanned then
			msg[#msg+1] = color_red
			msg[#msg+1] = "(VAC Banned)"
		end
		if data.NumberOfVACBans > 0 then
			msg[#msg+1] = color_red
			msg[#msg+1] = "(VAC Bans: "..data.NumberOfVACBans..")"
		end
		if data.EconomyBan ~= "none" then
			msg[#msg+1] = color_red
			msg[#msg+1] = "(Economy Banned)"
		end
		SAPI.GetUserGroupList(ply:SteamID64(), function(groups)
			for i, g in pairs(furrygroups) do
				g = util.SteamIDFrom64(g)
				g = string.gsub(g, "STEAM_0:[01]:", "")
				g = g*2
				if groups[tostring(g)] then
					msg[#msg+1] = color_red
					msg[#msg+1] = "(Furry)"
					break
				end
			end
			chat.AddText(unpack(msg))
		end)
	end)
end)
