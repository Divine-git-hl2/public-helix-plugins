local PLUGIN = PLUGIN

PLUGIN.name = "Crafting"
PLUGIN.author = "Heawi"
PLUGIN.description = "Adds crafting of items"

PLUGIN.CraftingRecipes = PLUGIN.CraftingRecipes or {}

function PLUGIN:RegisterRecipe(craft, craftData)
    assert(craftData.Name, craft .. " is missing name")
    assert(craftData.Description, craft .. " is missing description")
    assert(craftData.CraftingTime, creaft .. " is missing crafting time")
    assert(craftData.MinExpToCraft, craft .. " is missing minimal experience needed to craft")
    assert(craftData.ExperienceToGive, craft .. " is missing the amount of xp to reward")
    assert(craftData.ItemsToCraft, craft .. " is missing items needed to craft")
    assert(craftData.ItemsToGive, craft .. " is missing items to give")

    self.CraftingRecipes[craft] = craftData
end

function PLUGIN:OnScreenSizeChanged()
    createHeawiCraftingFonts()
end

ix.util.Include("sh_config.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")