-- Serversided chat.AddText
if SERVER then util.AddNetworkString("MessageC") end

if CLIENT then
	net.Receive("MessageC", function(len)
		local msglen = net.ReadUInt(8)
		local msg = {}
		for i = 1, items do
			local ic = net.ReadBool()
			local f = ic and net.ReadColor or net.ReadString
			msg[#msg + 1] = f()
		end
		chat.AddText(msg)
	end)
end

local translate = {
	Player = function(ply)
		return team.GetColor(ply:Team()), ply:GetName()
	end,
	Entity = function(ent)
		return ent:GetColor(), ent:GetClass()
	end,
}

local function _MessageC(ply, ...)
	local msg = {color_white}
	for i, v in ipairs({...}) do
		local t = type(v)
		if translate[t] then
			local ret = {translate[type(v)](v)}
			for i2, v2 in ipairs(ret) do
				msg[#msg + 1] = v2
			end
		else
			msg[#msg + 1] = tostring(v)
		end
	end
	if SERVER then
		net.Start("MessageC")
			net.WriteUInt(#msg, 8)
			for i, v in ipairs(msg) do
				local ic = IsColor(v)
				net.WriteBool(ic)
				local f = ic and net.WriteColor or net.WriteString
				f(v)
			end
		if ply then net.Send(ply) else net.Broadcast() end
	else
		chat.AddText(msg)
	end
end

function MessageC(...)
	_MessageC(false, ...)
end

local meta_player = meta_player or META_PLAYER or FindMetaTable("Player")
meta_player.MessageC = meta_player.MessageC or function(self, ...)
	_MessageC(self, ...)
end
