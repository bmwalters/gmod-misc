-- TTT Karma Sync addon created by lithium_
-- Edits by Zerf

if not SERVER then return end

require("tmysql")

local update_time	= 120 -- Time in seconds between karma syncing. Syncing also happens on player disconnect.
local host			= "localhost" -- Database host IP
local port			= 3306 -- Database host port
local user			= "root" -- Database username
local password		= "root" -- Database password
local database		= "myserver_data" -- Database
local table_name	= "ttt_karma" -- Table in database

local function message(msg)
	print("[TTT Karma MySQL Sync] "..msg)
end

local db, err = tmysql.initialize(host, user, password, database, port)
if err then
	message("Connection to database failed: "..err)
	return
end

message("Connected to database.")

local function query(str, callback)
	db:Query(str, function(result)
		if not callback then return end
		result = result[1] -- multiple results = multiple queries; probably requires CLIENT_MULTI_STATEMENTS flag
		if not result.status then
			callback(false, result.error)
		else
			callback(result.data)
		end
	end)
end

query("CREATE TABLE IF NOT EXISTS " .. table_name .. " (id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT, steamid BIGINT UNSIGNED NOT NULL, karma SMALLINT UNSIGNED NOT NULL, PRIMARY KEY (id))")

local function UpdatePlayerKarma(ply, karma)
	karma = karma or ply:GetLiveKarma()
	if ply:IsPlayer() and not ply:IsBot() then
		query("UPDATE " .. table_name .. " SET karma = " .. karma .. " WHERE steamid = " .. ply:SteamID64())
	end
end

hook.Add("Initialize", "TTTKS_Initialize", function()
	db:connect()
end)

hook.Add("PlayerInitialSpawn", "TTTKS_PlayerInitialSpawn", function(ply)
	if not IsValid(ply) or ply:IsBot() then return end
	query("SELECT karma FROM " .. table_name .. " WHERE steamid = " .. ply:SteamID64(), function(data)
		if #data > 0 then
			local karma = data.karma
			message("Received karma for "..ply:Nick()..": "..karma) -- debug
			ply:SetLiveKarma(karma)
			ply:SetBaseKarma(karma)
		else
			query("INSERT INTO " .. table_name .. " ( steamid, karma ) VALUES ( " .. ply:SteamID64() .. ", " .. ply:GetLiveKarma() .. " )")
		end
	end)
end)

local karma_starting, karma_low, karma_max = GetConVar("ttt_karma_starting"), GetConVar("ttt_karma_low_amount"), GetConVar("ttt_karma_max")
hook.Add("PlayerDisconnected", "TTTKS_PlayerDisconnected", function(ply)
	if ply.karma_kicked then
		UpdatePlayerKarma(ply, math.Clamp(karma_starting:GetFloat() * 0.8, karma_low:GetFloat() * 1.1, karma_max:GetFloat())) -- math from TTT
	else
		UpdatePlayerKarma(ply)
	end
end)

timer.Create("TTTKS_UpdateAll", refresh_time, 0, function()
	for _, ply in pairs(player.GetAll()) do
		UpdatePlayerKarma(ply)
	end
end)
