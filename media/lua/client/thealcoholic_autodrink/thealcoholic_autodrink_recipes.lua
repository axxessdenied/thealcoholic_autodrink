TheAlcoholic.AutoDrink = TheAlcoholic.AutoDrink or {}

function TheAlcoholic.AutoDrink.onCreateFlaskWhiskey(items, result, player)
    player:getInventory():AddItem("Base.WhiskeyEmpty")
end

function TheAlcoholic.AutoDrink.OnCreateFlaskWine(items, result, player)
    player:getInventory():AddItem("Base.WineEmpty")
end

function TheAlcoholic.AutoDrink.OnCreateFlaskWine2(items, result, player)
    player:getInventory():AddItem("Base.WineEmpty2")
end