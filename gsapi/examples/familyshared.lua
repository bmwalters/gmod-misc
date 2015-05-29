local color_red = COLOR_RED or color_red or Color(255, 0, 0)

hook.Add("CheckPassword", "GSAPI_RefuseConnection", function(sid64, ip, serverpass, clpass, nick)
	SAPI.IsPlayingSharedGame(sid64, 4000, function(lendersid)
		if lendersid and lendersid ~= sid64 then
			chat.AddText(color_red, nick .. " ("..util.SteamIDFrom64(sid64)..") attempted to join the server on a shared GMod copy.")
			return false, "You may not join this server on a shared GMod copy!"
		end
	end)
end)
