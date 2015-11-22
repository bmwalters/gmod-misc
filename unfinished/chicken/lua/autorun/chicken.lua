list.Set("NPC", "Chicken", {
	Name = "Chicken",
	Class = "npc_chicken",
	Category = "CS:GO"
})

if SERVER then
	util.AddNetworkString("chicken_particles")

	hook.Add("EntityFireBullets", "chicken_shotsfired", function(ent, data)
		for k, v in pairs(ents.GetAll()) do
			if v:GetClass() == "npc_chicken" and ent:GetPos():Distance(v:GetPos()) < 1000 and not v:GetPanick() and not v.HasPanicked and v.Init < CurTime() then
				v.ShouldPanic = true
			end
		end
	end)

	resource.AddFile("materials/models/sirgibs/csgo_chicken/chicken_brown.vmt")
	resource.AddFile("materials/models/sirgibs/csgo_chicken/chicken_normal.vtf")
	resource.AddFile("materials/models/sirgibs/csgo_chicken/chicken_white.vmt")
	resource.AddFile("materials/models/sirgibs/csgo_chicken/chicken_zombie.vmt")

	resource.AddFile("materials/models/weapons/v_models/eggnade/egg.vmt")
	resource.AddFile("materials/models/weapons/w_models/eggnade/egg.vmt")
	resource.AddFile("materials/weapons/v_models/eggnade/egg.vmt")
	resource.AddFile("materials/weapons/w_models/eggnade/egg.vmt")

	resource.AddFile("materials/vgui/entities/egg.vtf")
	resource.AddFile("materials/vgui/entities/swep_chickennade.vmt")

	resource.AddFile("models/sirgibs/ragdolls/chicken.mdl")

	resource.AddFile("models/weapons/v_chickeneggnade.mdl")
	resource.AddFile("models/weapons/w_chickeneggnade.mdl")
	resource.AddFile("models/weapons/w_chickeneggnade_thrown.mdl")

	resource.AddFile("particles/achievement.pcf")
	resource.AddFile("particles/critters/chicken.pcf")

	resource.AddFile("sound/ambient/creatures/chicken_death_01.wav")
	resource.AddFile("sound/ambient/creatures/chicken_death_02.wav")
	resource.AddFile("sound/ambient/creatures/chicken_death_03.wav")
	resource.AddFile("sound/ambient/creatures/chicken_fly_long.wav")
	resource.AddFile("sound/ambient/creatures/chicken_idle_01.wav")
	resource.AddFile("sound/ambient/creatures/chicken_idle_02.wav")
	resource.AddFile("sound/ambient/creatures/chicken_idle_03.wav")
	resource.AddFile("sound/ambient/creatures/chicken_panic_01.wav")
	resource.AddFile("sound/ambient/creatures/chicken_panic_02.wav")
	resource.AddFile("sound/ambient/creatures/chicken_panic_03.wav")
	resource.AddFile("sound/ambient/creatures/chicken_panic_04.wav")
else
	game.AddParticles("particles/achievement.pcf")
	game.AddParticles("particles/critters/chicken.pcf")

	net.Receive("chicken_particles", function()
		local pos = net.ReadVector()

		local efx = EffectData()
		efx:SetStart(pos)
		efx:SetOrigin(pos)
		util.Effect("balloon_pop", efx)
	end)
end
