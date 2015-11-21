if SERVER then
	resource.AddFile("materials/models/spesscow/cow/cow_normal.vtf")
	resource.AddFile("materials/models/spesscow/cow/cow_uv.vmt")
	resource.AddFile("materials/models/spesscow/cow/cow_uv.vtf")

	resource.AddFile("materials/models/spesscow/shelmlens.vmt")
	resource.AddFile("materials/models/spesscow/shelmlens.vtf")
	resource.AddFile("materials/models/spesscow/shelmstuff.vmt")
	resource.AddFile("materials/models/spesscow/shelmstuff.vtf")

	resource.AddFile("models/spesscow/spesscow.mdl")
	resource.AddFile("models/spesscow/astrohelmet.mdl")

	resource.AddFile("sound/spesscow/moo.wav")
end

local spesscowmodel = "models/spesscow/spesscow.mdl"

hook.Add("PlayerTick", "SPESSCOW_MOVEMENT", function(ply, cmd)
	--if ply:GetModel() ~= spesscowmodel then return end
	if SERVER or (CLIENT and ply == LocalPlayer()) then ply:SetModel(spesscowmodel) end

	if SERVER then
		if not ply.NextMoo or ply.NextMoo < CurTime() then
			ply:EmitSound(ply.NextMoo and "spesscow/moo.wav" or "")
			ply.NextMoo = CurTime() + math.random(40, 80)
		end
	end

	for k, v in pairs(player.GetAll()) do
		if v:GetModel() == spesscowmodel then
			v:SetSequence(v:LookupSequence("soar"))
			v:SetPlaybackRate(0.001)
			v:SetCycle(v:GetCycle() + 0.001)
			if v:GetCycle() >= 1 then v:SetCycle(0) end
		end
	end
end)

hook.Add("PlayerFootstep", "SPESSCOW_NOFOOTSTEP", function(ply)
	if ply:GetModel() == spesscowmodel then
		return true
	end
end)

if CLIENT then
	hook.Add("InitPostEntity", "SPESSCOW_HELMET", function()
		spesscowhelmet = ClientsideModel("models/spesscow/astrohelmet.mdl", RENDERGROUP_TRANSLUCENT)
	end)

	local offsetmul = {forward = 10, up = -200, right = 1}

	hook.Add("PostPlayerDraw", "SPESSCOW_HELMET", function(ply)
		if not ply:Alive() then return end
		if ply:GetModel() ~= spesscowmodel then return end

		local model = spesscowhelmet
		if not IsValid(model) then return end

		local boneindex = ply:LookupBone("Bone06")
		if boneindex then
			local pos, ang = ply:GetBonePosition(boneindex)
			if pos and pos ~= ply:GetPos() then
				model:SetModelScale(2.5, 0)
				ang:RotateAroundAxis(ang:Forward(), 270)
				ang:RotateAroundAxis(ang:Right(), -24)
				model:SetAngles(ang)
				model:SetPos(pos + (ang:Forward() * offsetmul.forward) + (ang:Up() * offsetmul.up) + (ang:Right() * offsetmul.right))
				model:DrawModel()
			end
		end
	end)
end
