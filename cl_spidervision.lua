local spidervision = CreateClientConVar("spidervision", "0", false, false)

local rt_store = render.GetScreenEffectTexture(0)
local mat_copy = Material("pp/copy")

local gridsize = 5

hook.Add("HUDPaint", "Rendertarget_Test", function()
	if not spidervision:GetBool() then return end
	local w, h = ScrW() / gridsize, ScrH() / gridsize
	local rt = render.GetRenderTarget()
	for i = 1, gridsize do
		for i2 = 1, gridsize do
			render.DrawTextureToScreenRect(rt, w * (i - 1), h * (i2 - 1), w, h)
		end
	end
end)
