-- Credit to http://steamcommunity.com/profiles/76561197960440071/ for porting model from CS:GO
-- Credit to http://steamcommunity.com/profiles/76561197990245265/ for the NPC code

if SERVER then AddCSLuaFile() end

ENT.Base		= "base_nextbot"
ENT.Spawnable	= false

ENT.Model = Model("models/sirgibs/ragdolls/chicken.mdl")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetSkin(math.random(1, self:SkinCount()))
	self:SetBloodColor(-1)

	self.Init = CurTime() + 1

	self.ShouldPanic = false
	self.IsPanicking = false
end

function ENT:GetPanick()
	return self.ShouldPanic or self.IsPanicking
end

function ENT:RunAway(panic)
	self.SetSpeed = 101
	self.MovingToOffset = 300

	local anim = panic and "run01flap" or "run01"
	self:ResetSequence(self:LookupSequence(anim))
	self:SetPlaybackRate(self:SequenceDuration() + 0.5)

	if panic then
		self:EmitSound("ambient/creatures/chicken_panic_0"..math.random(1, 4)..".wav")
	elseif math.random(1, 4) == 2 then
		self:EmitSound("ambient/creatures/chicken_idle_0"..math.random(1, 3)..".wav")
	end

	self.loco:SetDesiredSpeed(self.SetSpeed)

	self:MoveToPos(self:GetPos() + Vector(math.random(-1, 1), math.random(-1, 1), 0) * self.MovingToOffset)

	if not panic then coroutine.wait(2) end
end

function ENT:WalkAway()
	self.SetSpeed = 14
	self.MovingToOffset = 70

	self:ResetSequence(self:LookupSequence("walk01"))
	self:SetPlaybackRate(self:SequenceDuration() + 0.2)

	if math.random(1, 4) == 2 then
		self:EmitSound("ambient/creatures/chicken_idle_0"..math.random(1, 3)..".wav")
	end

	self.loco:SetDesiredSpeed(self.SetSpeed)

	self:MoveToPos(self:GetPos() + Vector(math.random(-1, 1), math.random(-1, 1), 0) * self.MovingToOffset)

	coroutine.wait(2)
end

function ENT:MoveToPos(pos, options)
	local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, pos)

	if not IsValid(path) then return "failed" end

	self.HasPanicked = false

	while IsValid(path) do
		path:Update(self)

		if options.draw then
			path:Draw()
		end

		if self.loco:IsStuck() then
			self:HandleStuck()
			return "stuck"
		end

		if options.maxage then
			if path:GetAge() > options.maxage then return "timeout" end
		end

		if options.repath then
			if path:GetAge() > options.repath then path:Compute(self, pos) end
		end

		if self.ShouldPanic and not self.IsPanicking then
			self.ShouldPanic = false
			self.IsPanicking = true

			self:RunAway(true)
		end

		coroutine.yield()
	end

	if not self.IsPanicking then
		self:StartActivity(ACT_IDLE)
		self.HasPanicked = true
	else
		self.IsPanicking = false
		self.ShouldPanic = false

		coroutine.wait(0.1)
	end

	return "ok"
end

function ENT:RunBehaviour()
	while not self:GetPanick() do
		if math.random(1, 10) == 3 then
			self:RunAway()
		else
			self:WalkAway()
		end
	end
end

function ENT:OnInjured(dmginfo)
	--[[
	local efx = EffectData()
		efx:SetStart(self:GetPos())
		efx:SetOrigin(self:GetPos())
	util.Effect("balloon_pop", efx)
	--]]

	net.Start("chicken_particles")
		net.WriteVector(self:GetPos())
	net.Broadcast()

	self:EmitSound("ambient/creatures/chicken_death_0"..math.random(1, 3)..".wav")

	self:Remove()
end
