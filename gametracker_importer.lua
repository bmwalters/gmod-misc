-- Gametracker importer by Zerf (STEAM_0:0:46161927)
--[[ Example:
concommand.Add("gametracker_try", function(srvcon, cmd, args)
	GTImport.Run("66.150.188.121:27015", 8, 1, function(mastertbl)
		PrintTable(mastertbl)
		file.Write("gametracker_0-400.txt", util.TableToJSON(mastertbl))
	end)
end)
--]]
local function printerr(str)
	MsgC(Color(255, 0, 0), "[GAMETRACKER ERR]: "..str.."\n")
end

local GTImport = {}

function GTImport.Run(srvip, pagecount, startpage, callback)
	startpage = startpage or 1
	local ret = {}
	for i = 0, pagecount-1 do
		local page = startpage + i
		local url = "http://www.gametracker.com/server_info/"..srvip.."/top_players/?searchipp=50&searchpge="..page
		http.Fetch(url, function(html, len, headers, code)
			for i,data in pairs(GTImport.ProcessHTML(html)) do
				ret[#ret + 1] = data
			end
			if page == pagecount then
				callback(ret)
				return
			end
		end, function(err)
			printerr("HTTP Fetch error: "..err)
		end)
	end
end

function GTImport.Clean(data) -- I tried using regex. I really did. ;(
	local validlines = {}
	for i,line in pairs(string.Explode("\n", data)) do
		if string.find(line, "</td>") or string.find(line, "</tr>") or string.find(line, "<td>") or string.find(line, "<tr>") or string.find(line, "<table")
			or string.find(line, "a href") or string.find(line, "</a>") or string.find(line, "td class=\"c03\"") or string.find(line, "td class=\"c01\"")
			or string.find(line, "td class=\"c06\"")
			or #string.Trim(line) <= 0 then continue end
		line = string.Trim(line)
		validlines[#validlines+1] = line
	end

	local ret = {
		names = {},
		scores = {},
		playtimes = {},
	}
	for i, line in pairs(validlines) do
		if string.find(line, "<td class=\"c02\">") then
			ret.names[#ret.names + 1] = validlines[i + 1]
		elseif string.find(line, "<td class=\"c04\">") then
			ret.scores[#ret.scores + 1] = validlines[i + 1]
		elseif string.find(line, "<td class=\"c05\">") then
			ret.playtimes[#ret.playtimes + 1] = validlines[i + 1]
		end
	end

	local ret2 = {}
	for i = 1, #ret.names do
		ret2[#ret2+1] = {name=ret.names[i], score=ret.scores[i], playtime=ret.playtimes[i]}
	end
	return ret2
end

function GTImport.ProcessHTML(rawhtml)
	local tblstart = string.find(rawhtml, "<table class=\"table_lst table_lst_spn\">")
	local tblend = string.find(rawhtml, "</table>")
	if (not tblstart) or (not tblend) then printerr("Couldn't find table of data in HTML!") return end

	local data = string.sub(rawhtml, tblstart, tblend)

	return GTImport.Clean(data)
end
