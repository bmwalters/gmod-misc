local pleasedo = true

local function convertpoints(ply)
	if not pleasedo then return end

	local filename = string.Replace(ply:SteamID(), ':', '_')
	local plypoints = ply:GetPData('PS_Points', 0)
	local plyitems = util.JSONToTable(ply:GetPData('PS_Items', '{}'))

	if plypoints ~= 0 then
		PS:SetPlayerData(ply, plypoints, plyitems)
		ply:RemovePData('PS_Points')
		ply:RemovePData('PS_Items')
	elseif file.Exists("pointshop/"..filename..".txt", "DATA") then
		local data = util.JSONToTable(file.Read("pointshop/"..filename..".txt", "DATA"))
		local plypoints = data.Points or 0
		local plyitems = data.Items or {}

		PS:SetPlayerData(ply, plypoints, plyitems)
		file.Delete("pointshop/"..filename..".txt")
	end
end

hook.Add("PlayerInitialSpawn", "PointshopConversion", convertpoints)
