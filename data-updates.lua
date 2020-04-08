------------------------------------------------------------------------------------------------------------------------------------------------------

local DID = require("globals")

------------------------------------------------------------------------------------------------------------------------------------------------------

for display,displaydata in pairs(DID.displays) do
	if mods["IndustrialRevolution"] then
		if displaydata.IR_unlock and data.raw.technology[displaydata.IR_unlock] then
			table.insert(data.raw.technology[displaydata.IR_unlock].effects, {type = "unlock-recipe", recipe = display})
		end
	else
		if displaydata.unlock and data.raw.technology[displaydata.unlock] then
			table.insert(data.raw.technology[displaydata.unlock].effects, {type = "unlock-recipe", recipe = display})
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------
