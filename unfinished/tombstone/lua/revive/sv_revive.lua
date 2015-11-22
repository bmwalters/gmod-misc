util.AddNetworkString("GravestoneReady")

local animtime = 5 -- seconds; time it takes for grave to rise from ground/drop into ground
local removetime = 5 -- seconds; time after grave is up before it is removed and player cannot be revived
local screenshake = true -- shake the screen while the gravestone rises/drops

local gravestones = {
	{model="models/props_c17/gravestone002a.mdl"},
	{model="models/props_c17/gravestone003a.mdl"},
	{model="models/props_c17/gravestone004a.mdl"},
}

local function GravestoneAnim(ply, grave, direction, callback)
	local frac = (grave:OBBMaxs().z / animtime) * direction -- idk why animtime is doubled (more like not halved) here for the frac
	local i = 0
	timer.Create("GravestoneMove_"..grave:EntIndex(), 0.5, animtime * 2, function()
		i = i + 1
		if not IsValid(grave) then return end
		local pos = grave:GetPos()
		pos.z = pos.z + frac
		grave:SetPos(pos)
		if i == animtime * 2 then callback(ply, grave) end
	end)

	if screenshake then
		util.ScreenShake(grave:GetPos(), 10, 10, animtime * 1.5, 30)
	end
end

local function RemoveGravestone(ply, grave)
	GravestoneAnim(ply, grave, -1, function()
		if IsValid(grave) then
			grave:Remove()
		end
	end)
end

local function GravestoneReady(ply, grave)
	-- net.Start("GravestoneReady")
	-- net.Send(ply)
	local i = 0
	timer.Create("GravestoneRemove_"..grave:EntIndex(), 1, removetime, function()
		i = i + 1
		if not IsValid(grave) then return end
		if i == removetime then RemoveGravestone(ply, grave) end
	end)
end

local function CreateGravestone(ply)
	local gravestone = gravestones[math.random(1, #gravestones)]

	local plypos = ply:GetPos()
	local tr = {
		start = plypos,
		endpos = plypos - Vector(0, 0, 10000),
		filter = ply,
	}
	tr = util.TraceLine(tr)

	local grave = ents.Create("prop_physics")
	grave:SetModel(gravestone.model)
	grave:Spawn()
	local height = grave:OBBMaxs().z
	-- grave:SetPos(ply:GetPos() + Vector(0, 0, height)) -- set bottom level with player's feet
	grave:SetPos(tr.HitPos - Vector(0, 0, height)) -- set to just below ground below player
	grave:SetAngles(ply:GetAngles())
	grave:PhysWake()
	grave:SetMoveType(MOVETYPE_NONE)
	grave:SetCollisionGroup(COLLISION_GROUP_WORLD)
	grave.IsGravestone = true

	GravestoneAnim(ply, grave, 1, GravestoneReady)
end

hook.Add("DoPlayerDeath", "Gravestone_Create", CreateGravestone)

hook.Add("PhysgunPickup", "Gravestone_PreventPhysgun", function(ply, ent)
	if ent.IsGravestone then return false end
end)
