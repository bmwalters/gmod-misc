net.Receive("ITEMDROP_ShowDropPopup", function()
	local itemid = net.ReadUInt(8)
	local item = ITEMDROP.DropItems[itemid]
	ITEMDROP.OpenDropPanel(item.name, item.icon)
end)

function ITEMDROP.OpenDropPanel(itemname, iconpath)
	local main  = vgui.Create("DFrame") -- DPanel
	main:SetTitle("Item Drop!")
	main:SetSize(200, 300)
	main:SetPos(ScrW() - 250, 0)
	main:CenterVertical()
	main:ShowCloseButton(false)

	local icon = vgui.Create("DImage", main)
	icon:SetSize(128, 128)
	icon:SetPos((200 - 128) / 2, (300 - 128) / 3)
	icon:SetImage(iconpath)

	local label = vgui.Create("DLabel", main)
	label:SetPos(mainwidth * 0.1, mainheight * 0.8)
	label:SetText(itemname)
	label:SizeToContents()

	timer.Simple(10, function()
		main:Remove()
	end)
end
