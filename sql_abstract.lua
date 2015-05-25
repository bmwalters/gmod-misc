-- SQL Abstract by Zerf

local sqlite = {
	LastError = sql.LastError,
	Query = sql.Query,
	Escape = sql.SQLStr,
}

local config = {
	hostname,
	username,
	password,
	database,
	port,
}

local provider = "SQLite"
local dbobj

local function dberror(msg)
	error("[SQL][provider="..provider.."] "..msg)
end

if provider == "MySQL" then
	require("tmysql")
	local db, err = tmysql.initialize(config.hostname, config.username, config.password, config.database, config.port)
	if err then
		dberror(err)
	else
		dbobj = db
	end
end

local function escape(str)
	if provider == "SQLite" then
		return sqlite.Escape(str)
	elseif provider == "MySQL" then
		return dbobj:Escape(str)
	end
end

local function query(query, callback)
	if provider == "SQLite" then
		local result = sqlite.Query(query)
		if result then
			callback(result)
		else
			callback(false, sqlite.LastError())
		end
	elseif provider == "MySQL" then
		dbobj:Query(query, function(result)
			result = result[1] -- multiple results = multiple queries; probably requires CLIENT_MULTI_STATEMENTS flag
			if not result.status then
				callback(false, result.error)
			else
				callback(result.data)
			end
		end)
	end
end

sqla = {
	GetProvider = function() return provider end,
	Query = query,
	Escape = escape,
}
