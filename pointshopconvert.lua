-- Script to convert Pointshop PData or flatfile storage to your new data provider (probably SQL)

local function convertpoints(ply)
	local filename = string.gsub(ply:SteamID(), ":", "_")
	local plypoints = ply:GetPData("PS_Points", false)
	local plyitems = util.JSONToTable(ply:GetPData("PS_Items", "{}"))

	if plypoints then -- convert from PData
		PS:SetPlayerData(ply, plypoints, plyitems)
		ply:RemovePData("PS_Points")
		ply:RemovePData("PS_Items")
	elseif file.Exists("pointshop/"..filename..".txt", "DATA") then -- convert from flatfile
		local data = util.JSONToTable(file.Read("pointshop/"..filename..".txt", "DATA"))
		local plypoints = data.Points or 0
		local plyitems = data.Items or {}

		PS:SetPlayerData(ply, plypoints, plyitems)
		file.Delete("pointshop/"..filename..".txt")
	end
end

hook.Add("PlayerInitialSpawn", "PointshopConversion", convertpoints)
