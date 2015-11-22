if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_base_z"

if CLIENT then
	SWEP.PrintName		= "Tommy Gun"
	SWEP.Author			= "Zerf"
	SWEP.Contact		= "steamcommunity.com/id/zerf_"
	SWEP.Purpose		= "Shoot 'em up!"
	SWEP.Instructions	= "Click!"
	SWEP.Category		= "Zerf"
end

SWEP.Spawnable	= true
SWEP.AdminOnly	= false

SWEP.ViewModelFOV	= 72
SWEP.ViewModel		= "models/weapons/c_tommygun.mdl"
SWEP.WorldModel		= "models/weapons/w_smg_p90_tommy.mdl"
SWEP.ViewModelFlip	= true
SWEP.UseHands = true

SWEP.AutoSwitchTo	= true
SWEP.AutoSwitchFrom	= false

SWEP.Slot		= 2
SWEP.SlotPos	= 1

SWEP.HoldType = "smg"

SWEP.FiresUnderwater = false

SWEP.DrawCrosshair	= true

SWEP.DrawAmmo		= true

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 100

SWEP.Secondary = {}

SWEP.Damage		= 20
SWEP.TakeAmmo	= 1
SWEP.Spread		= 0.1
SWEP.NumShots	= 1
SWEP.Recoil		= 0.3
SWEP.Delay		= 0.1
SWEP.Force		= 15

SWEP.IronSightsPos	= Vector(3.369, 0, 1.7)
SWEP.IronSightsAng	= Vector(-1.407, -3.981, 0)
SWEP.IronSightsFOV  = 50

SWEP.ShootSound		= Sound("tommygun_shoot.wav")
SWEP.ReloadSound	= ""
SWEP.EmptySound		= Sound("Weapon_Pistol.Empty")

function SWEP:DrawWorldModel()
	local hand, offset, rotate

	if not IsValid(self.Owner) then
		self:DrawModel()
		return
	end

	hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))

	offset = hand.Ang:Right() * 1 + hand.Ang:Forward() * -6 + hand.Ang:Up() * -2

	hand.Ang:RotateAroundAxis(hand.Ang:Right(), 12)
	hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 0)
	hand.Ang:RotateAroundAxis(hand.Ang:Up(), 360)

	self:SetRenderOrigin(hand.Pos + offset)
	self:SetRenderAngles(hand.Ang)

	self:DrawModel()
end
