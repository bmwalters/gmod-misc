-- TODO: Autorefresh
AddonLoader = {}

AddonLoader.Addons = {}

function AddonLoader.LoadAddon(tbl)
	local msg = "AddonLoader: Registered "..tbl.Name.." (Version "..tbl.Version..")\t"
	if tbl.AddFiles then
		for k, v in pairs(tbl.AddFiles) do
			if tonumber(v) then
				resource.AddWorkshop(v)
			else
				resource.AddFile(v)
			end
		end
		msg = msg.."["..#tbl.AddFiles.." Downloadable Files]"
	end
	AddonLoader.Addons[tbl.Name] = tbl -- TODO: sequential?
	if tbl.VersionURL then
		http.Fetch(tbl.VersionURL, function(body, len, headers, code)
			if tonumber(body) > tonumber(tbl.Version) then
				local msg2 ="AddonLoader: Addon "..tbl.Name.." is out of date! Local: "..tbl.Version.."; Remote: "..body.."!"
				if tbl.DownloadLink then msg2 = msg2 .. " Download the newest version from "..tbl.DownloadLink end
				print(msg2)
			end
		end)
	end
	print(msg)
end

local function readfile(path)
	local f = file.Open(path, "r", "GAME")
	local contents = f:Read(f:Size())
	f:Close()
	return contents
end

function AddonLoader.Run()
	local files, folders = file.Find("addons/*", "GAME")
	for _, folder in pairs(folders) do
		local init = "addons/"..folder.."/load.txt"
		if file.Exists(init, "GAME") then
			local tbl = util.JSONToTable(readfile(init))
			tbl.Folder = folder
			AddonLoader.LoadAddon(tbl)
		end
	end
end

AddonLoader.LoaderFiles = {}
AddonLoader.AddonsInitialized = false
util.AddNetworkString("AddonLoader_InitAddons")
function AddonLoader.SendAddons(ply)
	local cnt = #AddonLoader.LoaderFiles
	net.Start("AddonLoader_InitAddons")
		net.WriteUInt(cnt, 8)
		for i = 1, cnt do
			net.WriteString(AddonLoader.LoaderFiles[i])
		end
	if ply then net.Send(ply) else net.Broadcast() end -- TODO: Will this work? Will it send multiple times to 1 ply because of the other call?
end
hook.Add("PlayerInitialSpawn", "AddonLoader_SendAddons", function(ply)
	if AddonLoader.AddonsInitialized then
		AddonLoader.SendAddons(ply)
	end
end)

function AddonLoader.InitAddons()
	local currentgm = string.lower(GetConVar("gamemode"):GetString())
	for k, v in pairs(AddonLoader.Addons) do
		local missing = {}
		if v.Gamemode and v.Gamemode ~= currentgm then
			missing[#missing + 1] = "gamemode"
		elseif v.Gamemodes then
			local found = false
			for k2, v2 in pairs(v.Gamemodes) do
				if string.lower(v2) == currentgm then
					found = true
					break
				end
			end
			if not found then missing[#missing + 1] = "gamemode" end
		end
		if v.Depencencies then
			for k2, v2 in pairs(v.Dependencies) do
				if not AddonLoader.Addons[v2] then
					missing[#missing + 1] = v2
				end
			end
		end
		if #missing == 0 then
			AddCSLuaFile(v.Loader)
			include(v.Loader) -- TODO: Client??
			AddonLoader.LoaderFiles[#AddonLoader.LoaderFiles + 1] = v.Loader
			print("AddonLoader: Loaded addon "..v.Name.." serverside!")
		else
			print("AddonLoader: Skipped loading addon "..v.Name.." (missing: "..table.concat(missing, ", ")..")")
		end
	end
	if #AddonLoader.LoaderFiles > 0 then
		AddonLoader.SendAddons()
	end
	AddonLoader.AddonsInitialized = true
end

hook.Add("Initialize", "AddonLoader_LoadAddons", function()
	AddonLoader.InitAddons()
end)

AddonLoader.Run()