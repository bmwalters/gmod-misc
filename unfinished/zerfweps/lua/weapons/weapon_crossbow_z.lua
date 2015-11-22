if SERVER then AddCSLuaFile() end

SWEP.Base		= "weapon_base_z"

if CLIENT then
	SWEP.PrintName	= "Crossbow 2"
	SWEP.Author		= "Zerf/Worshipper"
	SWEP.Slot		= 5
	SWEP.Icon		= "vgui/ttt/icon_crossbow"
	SWEP.Category	= "Zerf"

	SWEP.ViewModelFlip = false
end

SWEP.Spawnable	= true

SWEP.Primary.Automatic		= false
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Ammo			= "XBowBolt"

SWEP.Spread	= 0.01
SWEP.Damage	= 60
SWEP.Delay	= 0.5

SWEP.ViewModel		= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel		= "models/weapons/w_crossbow.mdl"
SWEP.HoldType = "crossbow"
SWEP.ViewModelFlip	= false
SWEP.ViewModelFOV	= 54
SWEP.UseHands		= true

SWEP.IronSightsPos = Vector(0, 0, -15) -- Vector(5, 0, 1)
SWEP.IronSightsFOV = 30

SWEP.ReloadSound		= Sound("Weapon_Crossbow.Reload")
SWEP.ShootSoundSingle	= Sound("Weapon_Crossbow.Single")
SWEP.ShootSound1		= Sound("Weapon_Crossbow.BoltElectrify")
SWEP.ShootSound2		= Sound("Weapon_Crossbow.BoltFly")
SWEP.EmptySound			= Sound("")

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if not self:CanPrimaryAttack() then return end
	self:FireBolt()
end

function SWEP:FireBolt()
	if not IsFirstTimePredicted() then return end
	if not self:CanPrimaryAttack() then return end
	local ply = self.Owner

	if not ply then return end

	if SERVER then
		local pBolt = ents.Create("cbow_bolt_z")
		pBolt:SetPos(ply:GetShootPos())
		pBolt:SetAngles(ply:GetAimVector():Angle())
		pBolt.DamageDealt = self.Damage
		pBolt:SetOwner(ply)
		pBolt:Spawn()
	end

	ply:ViewPunch(Angle(-2, 0, 0))

	self:EmitSound(self.ShootSoundSingle, nil, nil, nil, CHAN_WEAPON)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self.NextReload = CurTime() + self.Owner:GetViewModel():SequenceDuration() + 0.3

	self:TakePrimaryAmmo(1)
end

function SWEP:Think()
	if (self.NextReload) and self.NextReload <= CurTime() then
		self:Reload()
		self.NextReload = false
	end
end
