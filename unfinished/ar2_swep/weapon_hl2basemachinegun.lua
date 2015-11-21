DEFINE_BASECLASS("weapon_hl2base")

local KICK_MIN_X = 0.2 -- Degrees
local KICK_MIN_Y = 0.2 -- Degrees
local KICK_MIN_Z = 0.1 -- Degrees

function SWEP:GetBulletSpread()
	return VECTOR_CONE_3DEGREES
end

function SWEP:PrimaryAttack()
	-- Only the player fires this way so we can cast
	local owner = self:GetOwner()

	if not (IsValid(owner) and owner:IsPlayer()) then return end

	-- Abort here to handle burst and auto fire modes
	if (self:UsesClipsForAmmo1() and self.m_iClip1 == 0) or (not self:UsesClipsForAmmo1() and not owner:GetAmmoCount(m_iPrimaryAmmoType)) then return end

	self.m_nShotsFired = self.m_nShotsFired + 1

	owner:MuzzleFlash()

	-- To make the firing framerate independent, we may have to fire more than one bullet here on low-framerate systems,
	-- especially if the weapon we're firing has a really fast rate of fire.
	local iBulletsToFire = 0
	local fireRate = self:GetFireRate()

	while self.m_flNextPrimaryAttack <= CurTime() do
		-- MUST call sound before removing a round from the clip of a CHLMachineGun
		self:WeaponSound("single", self.m_flNextPrimaryAttack)
		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + fireRate
		iBulletsToFire = iBulletsToFire + 1
	end

	-- Make sure we don't fire more than the amount in the clip, if this weapon uses clips
	if self:UsesClipsForAmmo1() then
		if iBulletsToFire > self.m_iClip1 then
			iBulletsToFire = self.m_iClip1
		end
		self.m_iClip1 = self.m_iClip1 - iBulletsToFire
	end

	-- Fire the bullets
	local info = {}
	info.m_iShots = iBulletsToFire
	info.m_vecSrc = owner:GetShootPos()
	info.m_vecDirShooting = owner:GetAimVector()
	info.m_vecSpread = owner:GetAttackSpread(self)
	info.m_flDistance = MAX_TRACE_LENGTH
	info.m_iAmmoType = self.m_iPrimaryAmmoType
	info.m_iTracerFreq = 2
	owner:FireBullets(info)

	-- Factor in the view kick
	self:AddViewKick()

	self:SendWeaponAnim(self:GetPrimaryAttackActivity())
	owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:DoMachineGunKick(ply, dampEasy, maxVerticleKickAngle, fireDurationTime, slideLimitTime)
	-- Find how far into our accuracy degradation we are
	local duration = (fireDurationTime > slideLimitTime) and slideLimitTime or fireDurationTime
	local kickPerc = duration / slideLimitTime

	-- do this to get a hard discontinuity, clear out anything under 10 degrees punch
	ply:ViewPunchReset(10)

	-- Apply this to the view angles as well
	local vecScratch = Angle()
	vecScratch.x = -(KICK_MIN_X + (maxVerticleKickAngle * kickPerc))
	vecScratch.y = -(KICK_MIN_Y + (maxVerticleKickAngle * kickPerc)) / 3
	vecScratch.z = KICK_MIN_Z + (maxVerticleKickAngle * kickPerc) / 8

	local iSeed = bit.band(BaseEntity:GetPredictionRandomSeed(), 255)
	math.randomseed(iSeed)

	-- Wibble left and right
	if math.random(-1, 1) >= 0 then
		vecScratch.y = -vecScratch.y
	end

	iSeed = iSeed + 1

	-- Wobble up and down
	if math.random(-1, 1) >= 0 then
		vecScratch.z = -vecScratch.z
	end

	-- Clip this to our desired min/max
	vecScratch = self:ClipPunchAngleOffset(vecScratch, ply:GetViewPunchAngles(), Angle(24, 3, 1))

	-- Add it to the view punch
	-- NOTE: 0.5 is just tuned to match the old effect before the punch became simulated
	ply:ViewPunch(vecScratch * 0.5)
end

function SWEP:Think()
	local owner = self:GetOwner()

	if not (IsValid(owner) and owner:IsPlayer()) then return end

	-- Debounce the recoiling counter
	if not owner:KeyDown(IN_ATTACK) then
		self.m_nShotsFired = 0
	end

	BaseClass.Think(self)
end

function SWEP:Deploy()
	self.m_nShotsFired = 0

	return BaseClass.Deploy(self)
end

function SWEP:WeaponSoundRealtime(shoot_type)
	local numBullets = 0

	-- ran out of time, clamp to current
	if self.m_flNextSoundTime < CurTime() then
		self.m_flNextSoundTime = CurTime()
	end

	-- make enough sound events to fill up the next estimated think interval
	local dt = math.Clamp(self.m_flAnimTime - self.m_flPrevAnimTime, 0, 0.2)
	if self.m_flNextSoundTime < CurTime() + dt then
		self:WeaponSound("single_npc", self.m_flNextSoundTime)
		self.m_flNextSoundTime = self.m_flNextSoundTime + self:GetFireRate()
		numBullets = numBullets + 1
	end
	if self.m_flNextSoundTime < CurTime() + dt then
		self:WeaponSound("single_npc", self.m_flNextSoundTime)
		self.m_flNextSoundTime = self.m_flNextSoundTime + GetFireRate()
		numBullets = numBullets + 1
	end

	return numBullets
end
