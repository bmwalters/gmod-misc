-- From Willox: http://facepunch.com/showthread.php?t=1445138&p=46873254#post46873254
hook.Add("Initialize", "ResolutionChanged_Hook", function()
	vgui.CreateFromTable({
		Base = "Panel",

		PerformLayout = function()
			hook.Run("ResolutionChanged", ScrW(), ScrH())
		end
	}):ParentToHUD()
end)

hook.Add("ResolutionChanged", "Resolution Change Test", function(w, h)
	print("OH NO THE RESOLUTION CHANGED TO " .. w .. "x" .. h)
end)
