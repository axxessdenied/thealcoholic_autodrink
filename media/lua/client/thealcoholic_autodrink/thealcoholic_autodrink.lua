-- (c) 2024 - axxessdenied [Nick Slusarczyk]

TheAlcoholic.AutoDrink = TheAlcoholic.AutoDrink or {}

TheAlcoholic.AutoDrink.activePlayer = nil
TheAlcoholic.AutoDrink.supportedMods = {}

local sBVars = nil
local stressThreshold = 0
local ticksPerCheck = 0

function TheAlcoholic.AutoDrink.onLoad()
    if sBVars == nil then sBVars = TheAlcoholic.AutoDrink.sBVars end
    --AUTOSMOKE SUPPORT
    if AutoSmoke ~= nil and sBVars.AutoSmoke == true
    then
        TheAlcoholic.AutoDrink.supportedMods["AutoSmoke"] = true
    else 
        TheAlcoholic.AutoDrink.supportedMods["AutoSmoke"] = false
    end
    stressThreshold = TheAlcoholic.values.StressPerDrink - 0.02
    ticksPerCheck = math.floor(sBVars.StressCheckDeltaTime / 1000) * 60
end

function TheAlcoholic.AutoDrink.onCreatePlayer(playerNum, character)
    local player = getSpecificPlayer(playerNum)
    if sBVars == nil then sBVars = TheAlcoholic.AutoDrink.sBVars end
    if sBVars.PlayerSpawnFlask == true and player:HasTrait("Alcoholic")
    then
        if ZombRand(sBVars.PlayerSpawnFlaskChance - 1) == 0
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


function TheAlcoholic.AutoDrink:drinkFromFlask()
    local drink = "Flask"
    local player = self.activePlayer
    local drinkItem = player:getInventory():getFirstTagRecurse(drink)
    if drinkItem ~= nil then
        local drinkAction = ISDrinkAlcohol:new(player, drinkItem, self.sBVars.PercentageConsumed)
        ISTimedActionQueue.add(drinkAction)
    else
        -- todo something else
    end
end

function TheAlcoholic.AutoDrink.onStressCheck(ticks)
    if math.fmod(ticks, ticksPerCheck) ~= 0 then return end

    print("TheAlcoholic: Stress check")

    if sBVars == nil then sBVars = TheAlcoholic.AutoDrink.sBVars end

    -- iterate through each player
    for i=0, getNumActivePlayers() - 1 do
        TheAlcoholic.AutoDrink.activePlayer = getSpecificPlayer(i)
        local player = TheAlcoholic.AutoDrink.activePlayer
        if player == nil then break end
        if player:isDead() then break end
        if player:isAsleep() then break end
        if player:HasTrait("Alcoholic") == false then break end

        if player:getModData().AlcoholicTimeSinceLastDrink > sBVars.DrinkInterval and sBVars.OnlyStressed == false
        then
            TheAlcoholic.AutoDrink:drinkFromFlask()
        elseif player:getStats():getStress() >= stressThreshold
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

Events.OnLoad.Add(TheAlcoholic.AutoDrink.onLoad)
Events.OnCreatePlayer.Add(TheAlcoholic.AutoDrink.onCreatePlayer)
Events.OnTick.Add(TheAlcoholic.AutoDrink.onStressCheck)