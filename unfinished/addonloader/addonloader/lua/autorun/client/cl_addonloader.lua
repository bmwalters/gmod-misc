AddonLoader = {}

function AddonLoader.InitAddons(files)
	for k, v in pairs(files) do
		include(v)
		print("AddonLoader: Loaded addon "..v.." clientside!")
	end
end

net.Receive("AddonLoader_InitAddons", function(len)
	local cnt = net.ReadUInt(8)
	local ret = {}
	for i = 1, cnt do
		ret[#ret + 1] = net.ReadString()
	end
	AddonLoader.InitAddons(ret)
end)
