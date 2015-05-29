-- include("echonestapi.lua")

local ColorRand = ColorRand or function() return Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255) end

local model_color = Material("model_color")

local vlv
sound.PlayURL("http://zorf.me/s/vlv.mp3", "noplay", function(snd, errid, err)
	if IsValid(snd) then
		vlv = snd
	else
		print("Couldn't load sound: "..errid.." ("..err..")")
	end
end)

local validclasses = {
	prop_physics = true,
	prop_physics_multiplayer = true,
	prop_dynamic = true,
	func_door = true,
	func_door_rotating = true,
	player = true,
	viewmodel = true,
}

local function begin(bpm)
	vlv:Play()

	local muhcolor = color_white

	hook.Add("SetupSkyboxFog", "ExampleHook", function()
		render.FogMode(MATERIAL_FOG_LINEAR)
		render.FogMaxDensity(1)
		render.FogStart(1)
		render.FogEnd(1)
		render.FogColor(muhcolor.r, muhcolor.g, muhcolor.b)

		return true
	end)

	hook.Add("PostDrawOpaqueRenderables", "test", function()
		for k, v in pairs(ents.GetAll()) do
			if validclasses[string.lower(v:GetClass())] or v:IsWeapon() then
				-- render.ClearStencil()
				render.MaterialOverride(model_color)
				v:DrawModel()
			end
		end
	end)

	local lasttimer = SysTime()
	timer.Create("Coldplay", 60/bpm, 0, function()
		muhcolor = ColorRand()
		-- surface.PlaySound("player/footsteps/concrete1.wav")
		print(SysTime() - lasttimer)
		lasttimer = SysTime()
		for k, v in pairs(ents.GetAll()) do
			if validclasses[v:GetClass()] or v:IsWeapon() then
				v:SetColor(muhcolor)
			end
		end
	end)
end

concommand.Add("coldplay", function()
	if not IsValid(vlv) then
		print("Not loaded yet. Try again.")
		return
	else
		echonest.GetSongData("Coldplay", "Viva La Vida", function(data)
			begin(data.audio_summary.tempo)
		end)
	end
end)

hook.Add("InitPostEntity", "coldplay_welcome", function()
	chat.AddText("Type 'coldplay' in console for a fun time.")
end)
