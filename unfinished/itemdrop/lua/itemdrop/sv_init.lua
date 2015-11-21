util.AddNetworkString("ITEMDROP_ShowDropPopup")

ITEMDROP.TotalWeight = 0
for i, item in pairs(ITEMDROP.DropItems) do
	ITEMDROP.TotalWeight = ITEMDROP.TotalWeight + item.weight
end

function ITEMDROP.CheckForDrop(result)
	for k, v in pairs(player.GetAll()) do
		if ((result == WIN_INNOCENT) and (v:GetRole() == ROLE_INNOCENT or v:GetRole() == ROLE_DETECTIVE)) or ((result == WIN_TRAITOR) and (v:GetRole() == ROLE_TRAITOR)) then
			local droppercent = math.random(1, 100)
			if v:Alive() then droppercent = droppercent + 5 end
			ply:MessageC("[DEBUG] [ITEMDROP] Your Probability: "..droppercent.."   Required: "..ITEMDROP.DropChance)
			if droppercent >= ITEMDROP.DropChance then
				ITEMDROP.GenerateDrop(v, droppercent)
			end
		end
	end
end

function ITEMDROP.GenerateDrop(ply)
	local droppercent = math.random(1, ITEMDROP.TotalWeight)
	local itemid = 0

	for i, item in ipairs(ITEMDROP.DropItems) do
		if droppercent <= item.weight then
			itemid = i
			break
		end
	end

	ply:MessageC("[DEBUG] [ITEMDROP] DropPercent: "..droppercent.."   ItemID: "..itemid)

	net.Start("ITEMDROP_ShowDropPopup")
		net.WriteUInt(itemid, 8)
	net.Send(ply)
end

hook.Add("TTTEndRound", "ITEMDROP_ItemDropCheck", ITEMDROP.CheckForDrop)