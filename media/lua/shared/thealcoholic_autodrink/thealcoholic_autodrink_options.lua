TheAlcoholic.AutoDrink = TheAlcoholic.AutoDrink or {}

function TheAlcoholic.AutoDrink.onInitModData()
    --[[
    TheAlcoholic.AutoDrink.values = {
        onlyStressed = getSandboxOptions():getOptionByName("thealcoholicautodrink.only_stressed"):getValue(),
        drinkInterval = getSandboxOptions():getOptionByName("thealcoholicautodrink.drink_interval"):getValue(),
        percentageConsumed = getSandboxOptions():getOptionByName("thealcoholicautodrink.drink_percentage"):getValue(),
        stressThreshold = 0,
        AutoSmoke = getSandboxOptions():getOptionByName("thealcoholicautodrink.autosmoke"):getValue(),
        spawnFlask = getSandboxOptions():getOptionByName("thealcoholicautodrink.spawn_flask"):getValue(),
        spawnFlaskChance = getSandboxOptions():getOptionByName("thealcoholicautodrink.spawn_chance"):getValue(),
    }
    ]]
    TheAlcoholic.AutoDrink.sBVars = SandboxVars.TheAlcoholicAutoDrink
end

Events.OnInitGlobalModData.Add(TheAlcoholic.AutoDrink.onInitModData)