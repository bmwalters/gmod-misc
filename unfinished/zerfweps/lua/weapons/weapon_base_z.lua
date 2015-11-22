if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName		= "Zerf Base"
	SWEP.Author			= "Zerf"
	SWEP.Contact		= "steamcommunity.com/profiles/76561198052589582"
	SWEP.Purpose		= "Shoot 'em up!"
	SWEP.Instructions	= "Click!"
	SWEP.Category		= "Zerf"

	SWEP.Slot		= 1
	SWEP.SlotPos	= 1

	SWEP.DrawCrosshair	= true
	SWEP.DrawAmmo		= true
end

SWEP.Spawnable	= true
SWEP.AdminOnly	= false

SWEP.ViewModelFOV	= 54
SWEP.ViewModel		= "models/weapons/c_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip	= false
SWEP.UseHands		= true
SWEP.HoldType		= "pistol"

SWEP.AutoSwitchTo	= true
SWEP.AutoSwitchFrom	= false

SWEP.FiresUnderwater = false

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 100

SWEP.Secondary = {}

SWEP.Damage		= 20
SWEP.TakeAmmo	= 1
SWEP.Spread		= 0.1
SWEP.NumShots	= 1
SWEP.Recoil		= 0.3
SWEP.Delay		= 0.3
SWEP.Force		= 6

SWEP.IronSightsPos = Vector(-5.75, -14, 2.4)
SWEP.IronSightsAng = Vector(2.6, -1.5, 1.5)
SWEP.IronSightsFOV = 0

SWEP.ShootSound		= Sound("Weapon_Pistol.Single")
SWEP.ReloadSound	= Sound("Weapon_Pistol.Reload")
SWEP.EmptySound		= Sound("Weapon_Pistol.Empty")

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.ShootSound = self.ShootSound or ""
	self.ReloadSound = self.ReloadSound or ""
	self.EmptySound = self.EmptySound or ""
	self.SpreadIron = self.SpreadIron or (self.Spread * 0.75)
	self:SCK_Initialize()
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetIronSights(false)
	return true
end

function SWEP:Holster()
	self:SCK_Holster()
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound(self.EmptySound)
		self:Reload()
		return false
	end

	if self.Owner:WaterLevel() >= 3 and not self.FiresUnderwater then
		self:EmitSound(self.EmptySound)
		return false
	end

	return true
end

function SWEP:CanReload()
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return false end
	if self:Clip1() >= self.Primary.ClipSize then return false end
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then self:SetNextPrimaryFire(CurTime() + 0.5) return false end

	return true
end

function SWEP:PrimaryAttack()
--	if not IsFirstTimePredicted() then return end
	if (not self:CanPrimaryAttack()) then return end

	local bullet = {}
	bullet.Num		= self.NumShots
	bullet.Src		= self.Owner:GetShootPos()
	bullet.Dir		= self.Owner:GetAimVector()
	bullet.Spread	= Vector(self.Accur, self.Accur, 0)
	bullet.Tracer	= TRACER_NONE
	bullet.Force	= self.Force
	bullet.Damage	= self.Damage
	bullet.AmmoType	= self.Ammo

	local rnda = self.Recoil * -1
	local rndb = self.Recoil * math.random(-1, 1)

	self:ShootEffects()

	self.Owner:FireBullets(bullet)
	self:EmitSound(self.ShootSound)
	self.Owner:ViewPunch(Angle(rnda,rndb,rnda))
	self:TakePrimaryAmmo(1)

	self:SetNextPrimaryFire(CurTime() + self.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Delay)
	self.ReloadingTime = CurTime() + self.Delay
end

function SWEP:Reload()
--	if not IsFirstTimePredicted() then return end
	if not self:CanReload() then return end

	self:SetIronSights(false)
	local ammocnt = math.Clamp(self.Primary.ClipSize - self:Clip1(), 0, self.Owner:GetAmmoCount(self.Primary.Ammo))
	self.Owner:RemoveAmmo(ammocnt, self.Primary.Ammo)
	self:SetClip1(self:Clip1() + ammocnt)

	self:SendWeaponAnim(ACT_VM_RELOAD)
	local animtime = self.Owner:GetViewModel():SequenceDuration()
	self.ReloadingTime = CurTime() + animtime
	self:SetNextPrimaryFire(CurTime() + animtime)
	self:EmitSound(self.ReloadSound, nil, nil, nil, CHAN_WEAPON) -- CHAN_ITEM
end

--Ironsight BS
local IRONSIGHT_TIME = 0.25

SWEP.NextSecondaryAttack = 0
function SWEP:SecondaryAttack()
	if not self.IronSightsPos then return end
	if self.NextSecondaryAttack > CurTime() then return end

	self:SetIronSights(not (self:GetIronSights()))

	self.NextSecondaryAttack = CurTime() + IRONSIGHT_TIME + 0.5
end

function SWEP:SetIronSights(b)
	local fov = (b) and self.IronSightsFOV or 0

	self.Owner:SetFOV(fov, 0.4)
	self.Accur = (b) and self.SpreadIron or self.Spread

	self:SetNWBool("IronSights", b)
end

function SWEP:GetIronSights()
	return (self:GetNWBool("IronSights", false))
end

function SWEP:GetViewModelPosition(pos, ang)
	if not self.IronSightsPos then return pos, ang end

	local bIron = self:GetIronSights()

	if bIron ~= self.LastIron then
		self.LastIron = bIron
		self.IronTime = CurTime()

		self.SwayScale	= bIron and 0.3 or 1.0
		self.BobScale	= bIron and 0.1 or 1.0
	end

	local IronTime = self.IronTime or 0

	if (not bIron) and (IronTime < (CurTime() - IRONSIGHT_TIME)) then
		return pos, ang
	end

	local mul = 1.0

	if IronTime > CurTime() - IRONSIGHT_TIME then
		mul = math.Clamp((CurTime() - IronTime) / IRONSIGHT_TIME, 0, 1)
		if not bIron then mul = 1 - mul end
	end

	local offset = self.IronSightsPos

	if self.IronSightsAng then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(),	self.IronSightsAng.x * mul)
		ang:RotateAroundAxis(ang:Up(),		self.IronSightsAng.y * mul)
		ang:RotateAroundAxis(ang:Forward(),	self.IronSightsAng.z * mul)
	end

	pos = pos + offset.x * ang:Right()   * mul
	pos = pos + offset.y * ang:Forward() * mul
	pos = pos + offset.z * ang:Up()      * mul

	return pos, ang
end

-- SWEP construction kit garbage
local FullCopy = table.FullCopy or function(tab)
	-- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	-- Does not copy entities of course, only copies their reference.
	-- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	if (not tab) then return nil end

	local res = {}
	for k, v in pairs(tab) do
		if (type(v) == "table") then
			res[k] = FullCopy(v) -- recursion ho!
		elseif (type(v) == "Vector") then
			res[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			res[k] = Angle(v.p, v.y, v.r)
		else
			res[k] = v
		end
	end

	return res
end
--[[-----------------------------------------------------
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378

		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
-----------------------------------------------------]]--
function SWEP:SCK_Initialize()
	if (self.VElements or self.WElements) then self.SCK = true else return end
	if CLIENT then
		self.VElements = FullCopy(self.VElements)
		self.WElements = FullCopy(self.WElements)
		self.ViewModelBoneMods = FullCopy(self.ViewModelBoneMods)

		self:CreateModels(self.VElements) -- create viewmodels
		self:CreateModels(self.WElements) -- create worldmodels

		-- init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)

				-- Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					-- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					-- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")
				end
			end
		end
	end
end

function SWEP:SCK_Holster()
	if not self.SCK then return end
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
end

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		if not self.SCK then return end

		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end

		if (not self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (not self.vRenderOrder) then
			-- we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs(self.VElements) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for k, name in ipairs(self.vRenderOrder) do
			local v = self.VElements[name]
			if (not v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (not v.bone) then continue end

			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)

			if (not pos) then continue end

			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= v.material) then
					model:SetMaterial(v.material)
				end

				if (v.skin and v.skin ~= model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs(v.bodygroup) do
						if (model:GetBodygroup(k) ~= v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif (v.type == "Quad" and v.draw_func) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		if not self.SCK then return end

		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (not self.WElements) then return end

		if (not self.wRenderOrder) then
			self.wRenderOrder = {}

			for k, v in pairs(self.WElements) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			-- when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs(self.wRenderOrder) do
			local v = self.WElements[name]
			if (not v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end

			if (not pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= v.material) then
					model:SetMaterial(v.material)
				end

				if (v.skin and v.skin ~= model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs(v.bodygroup) do
						if (model:GetBodygroup(k) ~= v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif (v.type == "Quad" and v.draw_func) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
		if not self.SCK then return end

		local bone, pos, ang
		if (tab.rel and tab.rel ~= "") then

			local v = basetab[tab.rel]

			if (not v) then return end

			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation(basetab, v, ent)

			if (not pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
		else
			bone = ent:LookupBone(bone_override or tab.bone)

			if (not bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r -- Fixes mirrored models
			end
		end

		return pos, ang
	end

	function SWEP:CreateModels(tab)
		if not self.SCK then return end

		if (not tab) then return end

		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs(tab) do
			if (v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME")) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
			elseif (v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite)
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				-- make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs(tocheck) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
			end
		end
	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		if not self.SCK then return end

		if self.ViewModelBoneMods then

			if (not vm:GetBoneCount()) then return end

			-- WORKAROUND --
			-- We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (not hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			-- END WORKAROUND --

			for k, v in pairs(loopthrough) do
				local bone = vm:LookupBone(k)
				if (not bone) then continue end

				-- WORKAROUND --
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (not hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				-- END WORKAROUND --

				if vm:GetManipulateBoneScale(bone) ~= s then
					vm:ManipulateBoneScale(bone, s)
				end
				if vm:GetManipulateBoneAngles(bone) ~= v.angle then
					vm:ManipulateBoneAngles(bone, v.angle)
				end
				if vm:GetManipulateBonePosition(bone) ~= p then
					vm:ManipulateBonePosition(bone, p)
				end
			end
		else
			self:ResetBonePositions(vm)
		end
	end

	function SWEP:ResetBonePositions(vm)
		if not self.SCK then return end

		if (not vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale(i, Vector(1, 1, 1))
			vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			vm:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end
end
