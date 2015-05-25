hook.Add("CheckPassword", "Zerf_RefuseConnection", function(sid64, ip, serverpass, clpass, nick)
	SAPI.IsPlayingSharedGame(sid64,4000,function(lendersid)
		if lendersid and lendersid ~= sid64 then
			chat.AddText(true, color_red, nick .. " ("..util.SteamIDFrom64(sid64)..") attempted to join the server on a shared GMod copy.")
			return false, "You may not join this server on a shared copy!"
		end
	end)
end)

local COLOR_RED = COLOR_RED or color_red or Color(255, 0, 0)
local furrygroups = {
	"103582791429527670", -- https://steamcommunity.com/groups/furries
	"103582791429530109", -- https://steamcommunity.com/groups/furrehs
	"103582791429522274", -- https://steamcommunity.com/groups/FurriesUnited
	"103582791429523337", -- https://steamcommunity.com/groups/UKFur
	"103582791429606241", -- https://steamcommunity.com/groups/FurAffinityGamers
	"103582791429525408", -- https://steamcommunity.com/groups/fur
	"103582791433366073", -- https://steamcommunity.com/groups/AnFur
}

hook.Add("PlayerInitialSpawn", "Zerf_SteamBansAlert", function(ply)
	local msg = {color_white, "Player "..ply:Nick().." ("..ply:SteamID()..") ".."joined the server."}
	SAPI.GetPlayerBans(ply:SteamID64(), function(data)
		if (data.CommunityBanned) then
			msg[#msg+1] = COLOR_RED
			msg[#msg+1] = "(Community Banned)"
		end
		if (data.VACBanned) then
			msg[#msg+1] = COLOR_RED
			msg[#msg+1] = "(VAC Banned)"
		end
		if (data.NumberOfVACBans > 0) then
			msg[#msg+1] = COLOR_RED
			msg[#msg+1] = "(VAC Bans: "..data.NumberOfVACBans..")"
		end
		if (data.EconomyBan ~= "none") then
			msg[#msg+1] = COLOR_RED
			msg[#msg+1] = "(Economy Banned)"
		end
	end)
	SAPI.GetUserGroupList(ply:SteamID64(), function(groups)
		for i, g in pairs(furrygroups) do
			g = util.SteamIDFrom64(g)
			g = string.gsub(g, "STEAM_0:0:", "")
			g = string.gsub(g, "STEAM_0:1:", "")
			g = g*2
			g = tostring(g)
			if groups[g] then
				msg[#msg+1] = COLOR_RED
				msg[#msg+1] = "(Furry)"
				break
			end
		end
		chat.AddText(true, unpack(msg))
	end)
end)
