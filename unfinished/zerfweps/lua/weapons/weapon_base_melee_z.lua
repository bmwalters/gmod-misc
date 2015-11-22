if SERVER then AddCSLuaFile() end

DEFINE_BASECLASS("weapon_base_z")

if CLIENT then
	SWEP.PrintName		= "Zerf Melee Base"
	SWEP.Author			= "Zerf"
	SWEP.Contact		= "steamcommunity.com/profiles/76561198052589582"
	SWEP.Purpose		= "Stab 'em!"
	SWEP.Instructions	= "Click!"
	SWEP.Category		= "Zerf"

	SWEP.Slot		= 0
	SWEP.SlotPos	= 0

	SWEP.DrawCrosshair	= true
	SWEP.DrawAmmo		= false
end

if SERVER then
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
	SWEP.Weight			= 0
end

SWEP.Spawnable	= true
SWEP.AdminOnly	= false

SWEP.ViewModelFOV	= 54
SWEP.ViewModel		= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFlip	= false
SWEP.UseHands		= true
SWEP.HoldType		= "melee"

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 0

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1

SWEP.Damage		= 20
SWEP.Force		= 5
SWEP.Delay		= 0.5
SWEP.MaxDist	= 90

SWEP.SwingSound		= Sound("Weapon_Crowbar.Single")
SWEP.DeploySound	= ""
SWEP.HolsterSound	= ""

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.SwingSounds = self.SwingSounds or {self.SwingSound}
	self.DeploySounds = self.DeploySounds or {self.DeploySound}
	self.HolsterSounds = self.HolsterSounds or {self.HolsterSound}
	BaseClass.SCK_Initialize(self)
end

function SWEP:Deploy()
	self:EmitSound(self.DeploySounds[math.random(1, #self.DeploySounds)])
	self:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:Holster()
	self:EmitSound(self.HolsterSounds[math.random(1, #self.HolsterSounds)])
--	self:SendWeaponAnim(ACT_VM_HOLSTER)
	BaseClass.SCK_Holster(self)
	return true
end

function SWEP:Reload()
	return false
end

function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) then return end

	if self.Owner.LagCompensation then -- for some reason not always true
		self.Owner:LagCompensation(true)
	end

	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * 70)

	local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
	local hitEnt = tr_main.Entity

	self:EmitSound(self.SwingSounds[math.random(1, #self.SwingSounds)])

	if IsValid(hitEnt) or tr_main.HitWorld then
		self:SendWeaponAnim(ACT_VM_HITCENTER)

		if not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			--edata:SetDamageType(DMG_CLUB)
			edata:SetEntity(hitEnt)

			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
				util.Effect("BloodImpact", edata)
				-- does not work on players rah
				--util.Decal("Blood", tr_main.HitPos + tr_main.HitNormal, tr_main.HitPos - tr_main.HitNormal)

				-- do a bullet just to make blood decals work sanely; need to disable lagcomp because firebullets does its own
				self.Owner:LagCompensation(false)
				self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
			else
				util.Effect("Impact", edata)
			end
		end
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end

	if SERVER then
		-- Do another trace that sees nodraw stuff like func_button
		local tr_all = nil
		tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner})

		self.Owner:SetAnimation(PLAYER_ATTACK1)

		if IsValid(hitEnt) then
			local dmg = DamageInfo()
			dmg:SetDamage(self.Damage)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
			dmg:SetDamagePosition(self.Owner:GetPos())
			dmg:SetDamageType(DMG_CLUB)

			hitEnt:DispatchTraceAttack(dmg, spos + (self.Owner:GetAimVector() * 3), sdest)
		end
	end

	if self.Owner.LagCompensation then
		self.Owner:LagCompensation(false)
	end

	self:SetNextPrimaryFire(CurTime() + self.Delay)
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:OnDrop()
	self:Remove()
end
