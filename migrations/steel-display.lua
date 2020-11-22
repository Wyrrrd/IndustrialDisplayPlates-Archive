local DID = require("globals")

for index, force in pairs(game.forces) do
    for display,displaydata in pairs(DID.displays) do
        if displaydata.IR_unlock and force.technologies[displaydata.IR_unlock] and force.technologies[displaydata.IR_unlock].researched then
            force.recipes[display].enabled = true
        elseif displaydata.unlock and force.technologies[displaydata.unlock] and force.technologies[displaydata.unlock].researched then
            force.recipes[display].enabled = true
        end
    end
end
