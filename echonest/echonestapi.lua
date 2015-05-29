local apikey = ""

local function httpescape(s) -- http://www.lua.org/pil/20.3.html
	s = string.gsub(s, "([&=+%c])", function (c)
		return string.format("%%%02X", string.byte(c))
	end)
	s = string.gsub(s, " ", "+")
	return s
end

local function makeparams(params)
	local ret = ""
	for k, v in pairs(params) do
		ret = ret .. "&" .. httpescape(k) .. "=" .. httpescape(v)
	end
	return ret
end

local function query(method, params, callback)
	local url = "http://developer.echonest.com/api/v4/"..method.."?format=json&api_key="..apikey..makeparams(params)
	http.Fetch(url, function(body)
		local data = util.JSONToTable(body)
		if not (data and data.response) then callback(false, "Unknown (no data)") return end
		data = data.response
		if data.status.code ~= 0 then callback(false, data.status.message) return end

		callback(data)
	end, function(err)
		callback(false, err)
	end)
end

echonest = {}

function echonest.GetSongData(artist, title, callback)
	artist, title = string.lower(artist), string.lower(title)
	query("song/search", {artist=artist, title=title}, function(data, err)
		if not data then print("Echonest GetSongData error: "..err) return end
		local songid
		for k, v in pairs(data.songs) do
			if string.lower(v.artist_name) == artist and string.lower(v.title) == title then -- search for exact match
				songid = v.id
				break
			end
		end
		if not songid then return end
		query("song/profile", {id=songid, bucket="audio_summary"}, function(data, err)
			if not data then print("Echonest GetSongData error: "..err) return end
			callback(data.songs[1])
		end)
	end)
end

function echonest.SetKey(key)
	apikey = key
end
