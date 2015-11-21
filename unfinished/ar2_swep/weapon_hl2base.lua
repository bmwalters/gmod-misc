DEFINE_BASECLASS("weapon_basecombatweapon")

function SWEP:IsPredicted()
	return true
end

function SWEP:WeaponSound(sound_type, soundtime)
	soundtime = soundtime or 0
	if CLIENT then
		-- If we have some sounds from the weapon classname.txt file, play a random one of them
		local shootsound = self:GetWpnData().aShootSounds[sound_type]
		if not (shootsound and shootsound[1]) then return end

		self:EmitSound(shootsound[math.random(1, #shootsound)])
	else
		BaseClass:WeaponSound(sound_type, soundtime)
	end
end

function SWEP:ClipPunchAngleOffset(ang_in, punch, clip)
	local final = ang_in + punch

	-- Clip each component
	for i = 1, 3 do
		local comp = (i == 1 and "x") or (i == 2 and "y") or "z"

		if final[comp] > clip[comp] then
			final[comp] = clip[comp]
		elseif final[comp] < -clip[comp] then
			final[comp] = -clip[comp]
		end

		-- Return the result
		ang_in[comp] = final[comp] - punch[comp]
	end

	return ang_in
end
