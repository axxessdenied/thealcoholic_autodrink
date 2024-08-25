TheAlcoholic.AutoDrink = TheAlcoholic.AutoDrink or {}

function TheAlcoholic.AutoDrink.onInitModData()
    TheAlcoholic.AutoDrink.sBVars = SandboxVars.TheAlcoholicAutoDrink
end

Events.OnInitGlobalModData.Add(TheAlcoholic.AutoDrink.onInitModData)