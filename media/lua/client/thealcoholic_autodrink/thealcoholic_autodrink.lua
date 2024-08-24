-- (c) 2024 - axxessdenied [Nick Slusarczyk]

TheAlcoholic.AutoDrink.activePlayer = nil
TheAlcoholic.AutoDrink.supportedMods = {}

function TheAlcoholic.AutoDrink.onStart()
    --AUTOSMOKE SUPPORT
    if AutoSmoke ~= nil and TheAlcoholic.AutoDrink.values.AutoSmoke == true
    then
        TheAlcoholic.AutoDrink.supportedMods["AutoSmoke"] = true
    else 
        TheAlcoholic.AutoDrink.supportedMods["AutoSmoke"] = false
    end
    TheAlcoholic.AutoDrink.values.stressThreshold = TheAlcoholic.values.stress_per_drink[TheAlcoholic.options.stress_per_drink] - 0.02
    if TheAlcoholic.AutoDrink.values.spawnFlaskChance == nil
    then --value of 0 in the options menu is nil here
        TheAlcoholic.AutoDrink.values.spawnFlaskChance = 0
    end
end

function TheAlcoholic.AutoDrink.onCreatePlayer(playerNum, character)
    local player = getSpecificPlayer(playerNum)

    if TheAlcoholic.AutoDrink.values.spawnFlask == true and player:HasTrait("Alcoholic")
    then
        if ZombRand(TheAlcoholic.AutoDrink.values.spawnFlaskChance - 1) == 0
        then
            player:getInventory():AddItem("TheAlcoholic.FlaskEmpty")
        end
    end
end

function TheAlcoholic.AutoDrink:canDrink()
    local player = self.activePlayer
    return not player:isStrafing()
        and not player:isAiming()
        and not player:isAsleep()
        and not player:isRunning()
        and not player:isSprinting()
end

local stressCheckDelta = 10000
local prevMultipler = 0
local stressCheckTs = 0

function TheAlcoholic.AutoDrink:drinkFromFlask()
    local drink = "Flask"
    local player = self.activePlayer
    local drinkItem = player:getInventory():getFirstTagRecurse(drink)
    if drinkItem ~= nil then
        local drinkAction = ISDrinkAlcohol:new(player, drinkItem, self.values.percentageConsumed)
        ISTimedActionQueue.add(drinkAction)
    else
        -- todo something else
    end
end

function TheAlcoholic.AutoDrink.onStressCheck()
    local multiplier = getGameTime():getTrueMultiplier()
    if getTimestampMs() < stressCheckTs and multiplier == prevMultipler then return end
    stressCheckTs = getTimestampMs() + stressCheckDelta / multiplier
    prevMultipler = multiplier

    if TheAlcoholic.options.debugmode 
    then
        print("AutoDrink: onStressCheck")
        print("AutoDrink: stressThreshold: " .. TheAlcoholic.AutoDrink.values.stressThreshold)
        print("AutoDrink - AutoSmoke support: " .. tostring(TheAlcoholic.AutoDrink.supportedMods["AutoSmoke"]))
        print("AutoDrink: percentageConsumed: " .. TheAlcoholic.AutoDrink.values.percentageConsumed)
    end

    -- iterate through each player
    for i=0, getNumActivePlayers() - 1 do
        TheAlcoholic.AutoDrink.activePlayer = getSpecificPlayer(i)
        local player = TheAlcoholic.AutoDrink.activePlayer
        if player == nil then break end
        if player:isDead() then break end
        if player:isAsleep() then break end
        if player:HasTrait("Alcoholic") == false then break end

        if player:getModData().AlcoholicTimeSinceLastDrink > TheAlcoholic.AutoDrink.values.drinkInterval and TheAlcoholic.AutoDrink.values.onlyStressed == false
        then
            TheAlcoholic.AutoDrink:drinkFromFlask()
        elseif player:getStats():getStress() >= TheAlcoholic.AutoDrink.values.stressThreshold 
        then
            -- AUTOSMOKE CHECK
            -- not sure if autosmoke supports local co-op
            -- we'll only check on the first player
            if TheAlcoholic.AutoDrink.supportedMods["AutoSmoke"] and i == 0
            then
                if ISTimedActionQueue.hasAction(AutoSmoke.currentAction) then return end --check if we're already smoking
                
                if player:HasTrait("Smoker") 
                then
                    local matches, lighter
                    matches = player:getInventory():getFirstTypeRecurse("Base.Matches")
                    lighter = player:getInventory():getFirstTypeRecurse("Base.Lighter")
                    local cigarette
                    cigarette = player:getInventory():getFirstTypeRecurse("Base.Cigarettes")
                    if cigarette and (matches or lighter)
                    then
                        break
                    end
                end
            end

            -- AUTODRINK CHECK
            if TheAlcoholic.AutoDrink:canDrink() then
                TheAlcoholic.AutoDrink:drinkFromFlask()
            end
        end
    end
end


-- EVENTS

Events.OnGameStart.Add(TheAlcoholic.AutoDrink.onStart)
Events.OnCreatePlayer.Add(TheAlcoholic.AutoDrink.onCreatePlayer)
Events.OnTick.Add(TheAlcoholic.AutoDrink.onStressCheck)