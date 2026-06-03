local PLUGIN = PLUGIN

PLUGIN:RegisterRecipe("SMG1", {
    Name = "MP7",
    Model = "models/weapons/w_smg1.mdl",
    Description = "An smg primarly used by higher ranked civil protection units",
    CraftingTime = 20,
    ItemsToCraft = {
        { item = "water", displayName ="Water",  amount = 1 },
    },
    MinExpToCraft = 0,
    ExperienceToGive = 0.05,
    ItemsToGive = {
        { item = "smg1", displayName ="MP7", amount = 1 },
    },
})