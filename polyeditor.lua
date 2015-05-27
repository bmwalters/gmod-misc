-- PolyEditor from https://www.youtube.com/watch?v=QwA6k-Y6TJ8 by BobbleheadBob (Luabee)
-- Edited by Zerf

local POLY

local function RoundToNearest(num, point)
	return math.Round(num/point) * point -- for some reason we add one, I'll figure it out later
end

local function SnappedCursorPos()
	return {x = RoundToNearest(POLY.Frame:ScreenToLocal(gui.MouseX()), POLY.SnapTo), y = RoundToNearest(POLY.Frame:ScreenToLocal(gui.MouseY()), POLY.SnapTo)}
end

local function ExportPolyData()
	local ret = "-- Put this stuff OUTSIDE your paint hook:\nlocal polydata = {}"
	for i, poly in ipairs(POLY.PolygonData)do
		ret = ret.."\npolydata["..i.."] = {\n"
		for i2, point in ipairs(poly)do
			ret = ret .. "\t{x = "..point.x..", y = "..point.y.."},\n"
		end
		ret = ret.."}\n"
	end
	ret = ret .. "\n-- Now put this line IN your Paint hook:\nfor k, v in pairs(polydata) do surface.DrawPoly(v) end"
	print(ret)
end

local backgroundcolor = Color(60, 60, 60)
local cursorcolor = Color(200, 0, 0, 200)
local pointcolor = Color(0, 200, 0, 100)
local polycolor = Color(0, 0, 200, 180)
local function edit()
	POLY = {}

	POLY.SnapTo = 20
	POLY.SnapPoints = {1, 2, 5, 10, 20, 50, 100}

	POLY.PolygonData = {{}}
	POLY.CurrentPoly = 1

	local background = vgui.Create("DPanel")
	background:SetSize(ScrW(), ScrH())
	background:SetPos(0, 0)
	-- background:SetCursor("blank")
	background:MakePopup()
	POLY.Frame = background

	local instructions = vgui.Create("DLabel", background)
	instructions:SetText("Click anywhere to place a point.")
	instructions:SizeToContents()
	instructions:Center()

	function background:PaintOver(w,h)
		for i, poly in ipairs(POLY.PolygonData) do
			surface.SetTextColor(color_white)
			for i2, point in ipairs(poly)do
				surface.SetTextPos(point.x-35, point.y-30)
				surface.DrawText("x: "..point.x.."; y: "..point.y)
				draw.RoundedBox(4, point.x-2, point.y-2, 5, 5, pointcolor)
			end

			local polygoncopy = poly
			if i == POLY.CurrentPoly then -- Add current mouse as point
				polygoncopy = {}
				for k, v in pairs(poly) do
					polygoncopy[k] = v
				end
				polygoncopy[#polygoncopy + 1] = SnappedCursorPos()
			end
			draw.NoTexture()
			surface.SetDrawColor(polycolor)
			surface.DrawPoly(polygoncopy)
		end

		local cursorpos = SnappedCursorPos()
		draw.RoundedBox(4, cursorpos.x - 2, cursorpos.y - 2, 5, 5, cursorcolor)
	end

	function background:Paint(w,h)
		draw.NoTexture()
		surface.SetDrawColor(backgroundcolor)
		surface.DrawRect(0, 0, w, h)

		local cursorpos = SnappedCursorPos()
		surface.SetTextPos(cursorpos.x - 35, cursorpos.y - 30)
		surface.SetTextColor(color_white)
		surface.DrawText("x: "..cursorpos.x.."; y: "..cursorpos.y)

		surface.SetDrawColor(100, 100, 100, 150)
		for i = POLY.SnapTo, ScrW(), POLY.SnapTo do
			surface.DrawLine(i, 0, i, ScrH())
			surface.DrawLine(0, i, ScrW(), i)
		end
	end

	function background:OnMousePressed(mc)
		if mc == MOUSE_LEFT then
			instructions:Remove()
			local data = POLY.PolygonData[POLY.CurrentPoly]
			data[#data + 1] = SnappedCursorPos()
		elseif mc == MOUSE_RIGHT then
			local menu = DermaMenu()
			menu:AddOption("Export", ExportPolyData)
			menu:AddSpacer()
			menu:AddOption("Add Polygon", function()
				POLY.CurrentPoly = POLY.CurrentPoly + 1
				POLY.PolygonData[POLY.CurrentPoly] = {}
			end)
			menu:AddOption("Clear", function()
				POLY.PolygonData[POLY.CurrentPoly] = {}
			end)
			menu:AddOption("Clear All", function()
				POLY.PolygonData = {{}}
				POLY.CurrentPoly = 1
			end)
			menu:AddSpacer()
			local snap = menu:AddSubMenu("Snap To...")
			for k, v in pairs(POLY.SnapPoints) do
				snap:AddOption(v, function()
					POLY.SnapTo = v
				end)
			end
			menu:AddSpacer()
			menu:AddOption("Cancel", function() end)
			menu:AddOption("Exit", function() background:Remove() end)
			menu:Open()
		end
	end
end

concommand.Add("polyeditor", edit)
