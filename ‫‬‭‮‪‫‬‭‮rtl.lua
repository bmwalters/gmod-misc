--‫‬‭‮‪‫‬‭‮‫‬‭‮‪‫‬‭‮lua code by zerf

setmetatable(_G, {__index = function(self,k)
	if rawget(self, string.gsub(k, "‫‬‭‮‪‫‬‭‮", "")) then
		return rawget(self, string.gsub(k, "‫‬‭‮‪‫‬‭‮", ""))
	end
end})

_G["‫‬‭‮‪‫‬‭‮_G"]["‫‬‭‮‪‫‬‭‮concommand"]["‫‬‭‮‪‫‬‭‮Add"] = _G["‫‬‭‮‪‫‬‭‮concommand"]["Add"]
_G["‫‬‭‮‪‫‬‭‮_G"]["‫‬‭‮‪‫‬‭‮printhi"] = function()
	print("‫‬‭‮‪‫‬‭‮hi")
end

_G["‫‬‭‮‪‫‬‭‮_G"]["‫‬‭‮‪‫‬‭‮concommand"]["‫‬‭‮‪‫‬‭‮Add"]("printhi", _G["‫‬‭‮‪‫‬‭‮_G"]["‫‬‭‮‪‫‬‭‮printhi"])
