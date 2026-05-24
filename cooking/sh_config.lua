local PLUGIN = PLUGIN

PLUGIN:RegisterRecipe("chinese_takeout", {
    Name = "Noodles",
    Model = "models/props_junk/garbage_takeoutcarton001a.mdl",
    Description = "Simple noodles made out of flour and water",
    PreparationTime = 40,
    Ingredients = {
        { item = "water", displayName ="Water",  amount = 1 },
        { item = "milk_carton", displayName="Milk",   amount = 1 },
    },
    ItemsToGive = {
        { item = "chinese_takeout", displayName ="Chinese takeout", amount = 1 },
    },
})