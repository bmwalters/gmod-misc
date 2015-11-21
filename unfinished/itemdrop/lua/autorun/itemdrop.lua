ITEMDROP = {}

if SERVER then
	AddCSLuaFile("itemdrop/shared.lua")
	AddCSLuaFile("itemdrop/cl_init.lua")

	include("itemdrop/shared.lua")
	include("itemdrop/sv_init.lua")
else
	include("itemdrop/shared.lua")
	include("itemdrop/cl_init.lua")
end
