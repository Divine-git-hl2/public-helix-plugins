local PLUGIN = PLUGIN

PLUGIN:RegisterRecipe("chinese_takeout", {
    Name = "Noodles",
    Model = "models/props_junk/garbage_takeoutcarton001a.mdl",
    Description = "Simple noodles made out of flour and water",
    PreparationTime = 20,
    Ingredients = {
        { item = "water", displayName ="Water",  amount = 1 },
        { item = "milk_carton", displayName="Milk",   amount = 1 },
    },
    MinExpToCook = 0,
    ExperienceToGive = 0.025,
    ItemsToGive = {
        { item = "chinese_takeout", displayName ="Chinese takeout", amount = 1 },
    },
})

PLUGIN:RegisterRecipe("pro_chinese_takeout", {
    Name = "Pro Noodles",
    Model = "models/props_junk/garbage_takeoutcarton001a.mdl",
    Description = "Simple noodles made out of flour and water",
    PreparationTime = 2,
    Ingredients = {
        { item = "water", displayName ="Water",  amount = 2 },
        { item = "milk_carton", displayName="Milk",   amount = 2 },
    },
    MinExpToCook = 5,
    ExperienceToGive = 0.05,
    ItemsToGive = {
        { item = "chinese_takeout", displayName ="Chinese takeout", amount = 1 },
    },
})