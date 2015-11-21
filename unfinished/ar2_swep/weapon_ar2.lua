-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/shared/hl2mp/weapon_ar2.cpp
	-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/shared/hl2mp/weapon_hl2mpbase_machinegun.cpp
		-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/shared/hl2mp/weapon_hl2mpbase.cpp
			-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/shared/basecombatweapon_shared.cpp

-- https://github.com/wiox/gmod-csweapons/blob/master/lua/weapons/weapon_csbase.lua
-- https://github.com/garrynewman/garrysmod/blob/master/garrysmod/scripts/weapon_ar2.txt
-- https://github.com/zerfgog/swep_bases/tree/master/swep_bases/lua/weapons/swep_ar2

if SERVER then AddCSLuaFile() end

DEFINE_BASECLASS("weapon_hl2basemachinegun")

SWEP.Category = "HL2 SWEPs"
SWEP.PrintName = "AR2"
SWEP.Spawnable = true

SWEP.m_fMinRange1 = 65
SWEP.m_fMaxRange1 = 2048

SWEP.m_fMinRange2 = 256
SWEP.m_fMaxRange2 = 2048

SWEP.m_nShotsFired = 0
SWEP.m_nVentPose = -1

if SERVER then
	CreateConVar("sk_weapon_ar2_alt_fire_radius", "10")
	CreateConVar("sk_weapon_ar2_alt_fire_duration", "4")
	CreateConVar("sk_weapon_ar2_alt_fire_mass", "150")
end

local VECTOR_CONE_1DEGREES = Vector(0.00873, 0.00873, 0.00873)
local VECTOR_CONE_2DEGREES = Vector(0.01745, 0.01745, 0.01745)
local VECTOR_CONE_3DEGREES = Vector(0.02618, 0.02618, 0.02618)
local VECTOR_CONE_4DEGREES = Vector(0.03490, 0.03490, 0.03490)
local VECTOR_CONE_5DEGREES = Vector(0.04362, 0.04362, 0.04362)
local VECTOR_CONE_6DEGREES = Vector(0.05234, 0.05234, 0.05234)
local VECTOR_CONE_7DEGREES = Vector(0.06105, 0.06105, 0.06105)
local VECTOR_CONE_8DEGREES = Vector(0.06976, 0.06976, 0.06976)
local VECTOR_CONE_9DEGREES = Vector(0.07846, 0.07846, 0.07846)
local VECTOR_CONE_10DEGREES = Vector(0.08716, 0.08716, 0.08716)
local VECTOR_CONE_15DEGREES = Vector(0.13053, 0.13053, 0.13053)
local VECTOR_CONE_20DEGREES = Vector(0.17365, 0.17365, 0.17365)

local MAX_TRACE_LENGTH = 1.732050807569 * 2 * 16384

local COMBINEBALL_NOT_THROWN = 0
local COMBINEBALL_HOLDING = 1
local COMBINEBALL_THROWN = 2
local COMBINEBALL_LAUNCHED = 3 -- by a combine_ball launcher

local function CreateCombineBall(origin, velocity, radius, mass, lifetime, owner)
	local ball = ents.Create("prop_combine_ball")

	ball:PhysicsInit(SOLID_VPHYSICS)
	ball:SetSolid(SOLID_VPHYSICS)
	ball:SetMoveType(MOVETYPE_VPHYSICS)
	ball:SetCollisionGroup(24) -- ??

	ball:SetRadius(radius)

	ball:SetPos(origin)
	ball:SetOwner(owner)

	ball:SetSaveValue("m_flRadius", radius)
	ball:SetSaveValue("m_vecAbsVelocity", velocity)
	ball:Spawn()

	ball:SetSaveValue("m_bWeaponLaunched", true)
	ball:SetSaveValue("m_flSpeed", velocity:Length())
	ball:SetSaveValue("m_bLaunched", true)
	ball:SetSaveValue("m_nState", COMBINEBALL_THROWN)

	ball:EmitSound("NPC_CombineBall.Launch")

	-- ball:StartWhizSoundThink()

	-- ball:StartLifetime(lifetime)
	local phys = ball:GetPhysicsObject()
	if IsValid(phys) then
		phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
		phys:SetMass(mass)
		phys:SetInertia(Vector(500, 500, 500)) -- ??
	end

	-- Workaround for StartLifetime not being available
	timer.Simple(lifetime, function()
		if IsValid(ball) then
			ball:Fire("Explode")
		end
	end)

	return ball
end

function SWEP:Initialize()
	if SERVER then
		self:SetNPCMinBurst(2)
		self:SetNPCMaxBurst(5)
		self:SetNPCFireRate(self.Primary.Delay)
	end
end

local acttable = {
	ACT_HL2MP_IDLE					= ACT_HL2MP_IDLE_AR2,
	ACT_HL2MP_RUN					= ACT_HL2MP_RUN_AR2,
	ACT_HL2MP_IDLE_CROUCH			= ACT_HL2MP_IDLE_CROUCH_AR2,
	ACT_HL2MP_WALK_CROUCH			= ACT_HL2MP_WALK_CROUCH_AR2,
	ACT_HL2MP_GESTURE_RANGE_ATTACK	= ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
	ACT_HL2MP_GESTURE_RELOAD		= ACT_HL2MP_GESTURE_RELOAD_AR2,
	ACT_HL2MP_JUMP					= ACT_HL2MP_JUMP_AR2,
	ACT_RANGE_ATTACK1				= ACT_RANGE_ATTACK_AR2,
}

function SWEP:TranslateActivity(act)
	return acttable[act] or -1
end

function SWEP:GetBulletSpread()
	local cone = VECTOR_CONE_3DEGREES

	return cone
end

function SWEP:RemapValClamped(value, a, b, c, d)
	-- clamp to 0/1
	local v = math.Clamp((value - a) / (b - a), 0, 1)

	-- remap
	return c + (d - c) * v
end

function SWEP:GetPrimaryAttackActivity()
	if m_nShotsFired < 2 then
		return ACT_VM_PRIMARYATTACK
	elseif m_nShotsFired < 3 then
		return ACT_VM_RECOIL1
	elseif m_nShotsFired < 4 then
		return ACT_VM_RECOIL2
	end

	return ACT_VM_RECOIL3
end

function SWEP:Think()
	if self.m_flDelayedFire and CurTime() > self.m_flDelayedFire then
		self:DelayedAttack()
	end

	local owner = self:GetOwner()

	if IsValid(owner) then
		local vm = owner:GetViewModel()
		if IsValid(vm) then
			if self.m_nVentPose == -1 then
				self.m_nVentPose = vm:GetPoseParameter("VentPoses")
			end

			local ventpose = self:RemapValClamped(self.m_nShotsFired, 0, 5, 0, 1)
			vm:SetPoseParameter("VentPoses", ventpose) -- first argument was a number before, might be wrong
		end
	end

	BaseClass.Think(self)
end

function SWEP:DoImpactEffect(tr, damagetype)
	local data = EffectData()
	data:SetOrigin(tr.endpos + tr.normal)
	data:SetNormal(tr.normal)

	util.Effect("AR2Impact", data)

	BaseClass.DoImpactEffect(self, tr, damagetype)
end

function SWEP:DelayedAttack()
	self.m_flDelayedFire = false

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	-- Deplete the clip completely
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:SetNextSecondaryFire(CurTime() + self:SequenceDuration())

	-- Register a muzzleflash for the AI
	owner:MuzzleFlash()

	self:WeaponSound("double_shot")

	-- Fire the bullets
	local vecSrc = owner:GetShootPos()
	local vecAiming = owner:GetAimVector()
	local impactPoint = vecSrc + (vecAiming * MAX_TRACE_LENGTH)

	local vecVelocity = vecAiming * 1000

	if SERVER then
		-- Fire the combine ball
		CreateCombineBall(vecSrc, ecVelocity, GetConVar("sk_weapon_ar2_alt_fire_radius"):GetFloat(), GetConVar("sk_weapon_ar2_alt_fire_mass"):GetFloat(), GetConVar("sk_weapon_ar2_alt_fire_duration"):GetFloat(), owner)

		-- View effects
		local white = Color(255, 255, 255, 64)
		owner:ScreenFade(SCREENFADE.IN, white, 0.1, 0)
	end

	-- Disorient the player
	local ang = owner:GetLocalAngles()
	ang.x = ang.x + math.random(-4, 4)
	ang.y = ang.y + math.random(-4, 4)

	-- owner:SnapEyeAngles(ang)

	owner:ViewPunch(Angle(util.SharedRandom("ar2pax", -8, -12), util.SharedRandom("ar2pay", 1, 2), 0))

	-- Decrease ammo
	owner:RemoveAmmo(1, self.Secondary.Ammo)

	-- Can shoot again immediately
	self:SetNextPrimaryFire(CurTime() + 0.5)

	-- Can blow up after a short delay (so have time to release mouse button)
	self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
	if self.m_flDelayedFire then return end

	-- Cannot fire underwater
	if IsValid(self:GetOwner()) and self:GetOwner():WaterLevel() == 3 then
		self:SendWeaponAnim(ACT_VM_DRYFIRE)

		self:WeaponSound("empty")

		self:SetNextSecondaryFire(CurTime() + 0.5)
		return
	end

	local delay = CurTime() + 0.5
	self.m_flDelayedFire = delay
	self:SetNextPrimaryFire(delay)
	self:SetNextSecondaryFire(delay)

	self:SendWeaponAnim(ACT_VM_FIDGET)
	self:WeaponSound("special1")
end

function SWEP:CanHolster()
	if self.m_flDelayedFire then return false end

	return BaseClass.CanHolster(self)
end

function SWEP:Holster()
	if self:CanHolster() == false then return false end

	return true
end

function SWEP:Deploy()
	self.m_flDelayedFire = false

	return BaseClass.Deploy(self)
end

function SWEP:Reload()
	if self.m_flDelayedFire then return false end

	return BaseClass.Reload(self)
end

function SWEP:AddViewKick()
	local EASY_DAMPEN = 0.5
	local MAX_VERTICAL_KICK = 8
	local SLIDE_LIMIT = 0.5

	-- Get the view kick
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self:DoMachineGunKick(owner, EASY_DAMPEN, MAX_VERTICAL_KICK, self.m_fFireDuration, SLIDE_LIMIT)
end

local ProficiencyTable = {
	{7.0,		0.75},
	{5.00,		0.75},
	{3.0,		0.85},
	{5.0/3.0,	0.75},
	{1.00,		1.0},
}

function SWEP:GetProficiencyValues()
	COMPILE_TIME_ASSERT(ARRAYSIZE(ProficiencyTable) == WEAPON_PROFICIENCY_PERFECT + 1) -- no idea

	return ProficiencyTable
end
