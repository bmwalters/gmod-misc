-- Most code from mad cow, some from me
-- .phy of the crossbow_bolt made by Silver Spirit

AddCSLuaFile()

ENT.Type	= "anim"
ENT.Base	= "base_anim"


ENT.PrintName	= "CrossbowBolt"
ENT.Author		= "Worshipper/Zerf"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Damage		= 100
ENT.LifeTime	= 4
ENT.Model		= "models/crossbow_bolt.mdl"

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)

		-- Wake the physics object up. It's time to have fun!
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableGravity(false)
			phys:EnableDrag(true)
			phys:SetMass(2)
			phys:Wake()
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
			phys:AddGameFlag(FVPHYSICS_PENETRATING)
		end

--		local trail = util.SpriteTrail(self, 0, Color(255, 255, 255, 30), true, 2, 0, 3, 1 / (5.38) * 0.5, "trails/smoke.vmt")
		self.Moving = true
	end
--[[
	function ENT:PhysicsUpdate(phys)
		local vel = Vector(0, 0, ((-9.81 * phys:GetMass()) * 0.65))
		phys:ApplyForceCenter(vel)
	end
--]]
	function ENT:Impact(ent, normal, pos)
		if not IsValid(self) then return end

		local info

		local tr = {}
		tr.start = self:GetPos()
		tr.filter = {self, self.Owner}
		tr.endpos = pos
		tr = util.TraceLine(tr)

		if tr.HitSky then self:Remove() return end

		if not ent:IsPlayer() and not ent:IsNPC() then
			local effectdata = EffectData()
			effectdata:SetOrigin(pos - normal * 10)
			effectdata:SetEntity(self)
			effectdata:SetStart(pos)
			effectdata:SetNormal(normal)
			util.Effect("Impact", effectdata)
		end

		if IsValid(ent) then
			ent:TakeDamage(self.DamageDealt, self.Owner)

			self:EmitSound("Weapon_Crossbow.BoltHitBody")
			self:Remove()
			return
		end

		self:EmitSound("Weapon_Crossbow.BoltHitWorld")

		-- We've hit a prop, so let's weld to it. Also embed this in the object for looks

		self:SetPos(pos - normal * 10)
--		self:SetAngles(normal:Angle())

		if not IsValid(ent) then
			self:GetPhysicsObject():EnableMotion(false)
		end

		timer.Simple(self.LifeTime, function()
			if IsValid(self) then self:Remove() end
		end)
	end

	function ENT:PhysicsCollide(data, phys, dmg)
		if self.Moving then
			self.Moving = false
			phys:Sleep()
			self:Impact(data.HitEntity, data.HitNormal, data.HitPos)
		end
	end

	function ENT:Think()
		local phys	= self:GetPhysicsObject()
		local ang	= self:GetForward() * 100000
		local up	= self:GetUp() * -800

		local force = ang + up

		phys:ApplyForceCenter(force)

		if (self.HitWeld) then
			self.HitWeld = false
			constraint.Weld(self.HitEnt, self, 0, 0, 0, true)
		end
	end
end

if CLIENT then
	function ENT:Initialize()
		self:DrawShadow(false)
	end

	function ENT:IsTranslucent()
		return true
	end

	function ENT:Draw()
		self:DrawModel()
	end
end
