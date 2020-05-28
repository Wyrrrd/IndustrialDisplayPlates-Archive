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

if mods ["Dectorio"] then
	if data.raw["item-group"]["dectorio"] then
		data.raw["item-subgroup"]["display-plates"].group = "dectorio"
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------