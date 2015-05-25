SAPI = {}
SAPI.Version = "Zerf_1.1"

--Found here: http://facepunch.com/showthread.php?t=1400043
--Modified based on version "Hotel 1"

local apikey = "B3F64334ECCCD57B25C0DA37D6E86078"
local apiurl = "http://api.steampowered.com/"
local jdec = util.JSONToTable
local jenc = util.TableToJSON
local fetch = http.Fetch
local assert = assert

local function checkkey()
	assert(#apikey > 1, "No API key is defined. Change the 'apikey' line in this file.")
end

local function callbackCheck(code)
	assert(code~=401, "Authorization error (Is your key valid?)")
	assert(code~=500, "It seems the steam servers are having a hard time.")
	assert(code~=404, "Not found.")
	assert(code~=400, "Bad module request.")
end

local function steamid_verify(id)
	if string.find(id,"STEAM_") then
		id = util.SteamIDTo64(tostring(id))
	end
	assert(#id == 17, "Invalid SteamID passed to GSAPI! (Use Steam32 or Steam64)")
	return id
end

local function GenericAPIQuery(method, steamid, callback, exargs)
	checkkey()
	steamid = steamid_verify(steamid)

	local fetchstr = apiurl .. method .. "?key=" .. apikey .. "&steamid=" .. steamid .. "&steamids=" .. steamid .. "&format=json"
	if exargs then
		for k, v in pairs(exargs) do
			fetchstr = fetchstr.."&"..k.."="..v
		end
	end

	fetch(fetchstr,
		function(body, _, _, code)
			callbackCheck(code)
			local data = jdec(body)
			data = (data.response) and data.response or data
			callback(data)
		end,
		function(err)
			assert(false, "GSAPI HTTP error: "..err)
		end
	)
end

function SAPI.GetPlayerSummaries(steamid,callback)
	GenericAPIQuery("ISteamUser/GetPlayerSummaries/v0002/", steamid, function(data)
		callback(data.players)
	end)
end

function SAPI.GetFriendList(steamid,callback)
	GenericAPIQuery("ISteamUser/GetFriendList/v0001/", steamid, function(data)
		local flist = (data.friendslist) and data.friendslist.friends or false
		callback(flist)
	end)
end

function SAPI.GetUserGroupList(steamid,callback)
	GenericAPIQuery("ISteamUser/GetUserGroupList/v1/", steamid, function(data)
		if data.success == true then
			local ret = {}
			for i, g in pairs(data.groups) do
				ret[g.gid] = true
			end
			callback(ret)
		end
	end)
end

function SAPI.GetPlayerBans(steamid,callback)
	GenericAPIQuery("ISteamUser/GetPlayerBans/v1/", steamid, function(data)
		callback(data.players[1])
	end)
end

function SAPI.GetSteamLevel(steamid,callback)
	GenericAPIQuery("IPlayerService/GetSteamLevel/v1/", steamid, function(data)
		callback(data.player_level)
	end)
end

function SAPI.IsPlayingSharedGame(steamid,appid,callback)
	appid = appid or 4000
	GenericAPIQuery("IPlayerService/IsPlayingSharedGame/v0001/", steamid, function(data)
		local sid = (data.lender_steamid == 0) and false or data.lender_steamid
		callback(sid)
	end, {appid_playing = appid})
end
