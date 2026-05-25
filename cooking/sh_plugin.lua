local PLUGIN = PLUGIN

PLUGIN.name = "Cooking"
PLUGIN.author = "Heawi"
PLUGIN.description = "Adds cooking of foods and drinks"

PLUGIN.CookingRecipes = PLUGIN.CookingRecipes or {}

function PLUGIN:RegisterRecipe(food, foodData)
    assert(foodData.Name, food .. " is missing name")
    assert(foodData.Description, food .. " is missing description")
    assert(foodData.PreparationTime, food .. " is missing preparation time")
    
    assert(foodData.Ingredients, food .. " is missing ingredients")
    assert(foodData.ItemsToGive, food .. " is missing items to give")

    self.CookingRecipes[food] = foodData
end

function PLUGIN:OnScreenSizeChanged()
    createHeawiCookingFonts()
end

ix.util.Include("sh_config.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")