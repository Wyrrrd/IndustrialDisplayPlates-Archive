for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if technologies["steel-processing"].researched then
    recipes["steel-display-small"].enabled = true
    recipes["steel-display-medium"].enabled = true
    recipes["steel-display"].enabled = true
  end

end
