-- (c) 2024 - axxessdenied [Nick Slusarczyk]

TheAlcoholic.AutoDrink = TheAlcoholic.AutoDrink or {}

TheAlcoholic.AutoDrink.activePlayer = nil
TheAlcoholic.AutoDrink.supportedMods = {}

local sBVars = nil
local stressThreshold = 0
local playerAction = {
    false,
    false,
    false,
    false,
}
local stressTickDelta = 5
local timeSinceLastStressCheck = 0
local timeStressAdd = 1
local hasDrankFromStressThisHour = false

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

    stressTickDelta = sBVars.StressCheckDeltaTime
    if stressTickDelta % 60 == 0
    then
        timeStressAdd = 60
        Events.EveryHours.Add(TheAlcoholic.AutoDrink.onStressCheck)
    elseif stressTickDelta % 10 == 0
    then
        timeStressAdd = stressTickDelta / 10
        Events.EveryTenMinutes.Add(TheAlcoholic.AutoDrink.onStressCheck)
    else
        Events.EveryOneMinute.Add(TheAlcoholic.AutoDrink.onStressCheck)
    end
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


function TheAlcoholic.AutoDrink:drinkFromFlask(fromStress)
    local drink = "Flask"
    local player = self.activePlayer
    if fromStress == true then hasDrankFromStressThisHour = true end
    local drinkItem = player:getInventory():getFirstTagRecurse(drink)
    if sBVars == nil then sBVars = TheAlcoholic.AutoDrink.sBVars end
    if drinkItem ~= nil then
        local drinkAction = ISDrinkAlcohol:new(player, drinkItem, sBVars.PercentageConsumed)
        ISTimedActionQueue.add(drinkAction)
    else
        -- todo something else
    end
end

function TheAlcoholic.AutoDrink.onStressCheck()
    if stressTickDelta % timeSinceLastStressCheck ~= 0
    then
        timeSinceLastStressCheck = timeSinceLastStressCheck + timeStressAdd
        return
    end

    timeSinceLastStressCheck = stressTickDelta % 60 == 0 and 60 or 0

    if sBVars == nil then sBVars = TheAlcoholic.AutoDrink.sBVars end

    if stressThreshold == 0 then
        stressThreshold = TheAlcoholic.values.StressPerDrink - 0.02
    end

    -- iterate through each player
    for i=0, getNumActivePlayers() - 1 do
        TheAlcoholic.AutoDrink.activePlayer = getSpecificPlayer(i)
        local player = TheAlcoholic.AutoDrink.activePlayer
        if player == nil then break end
        if player:isDead() then break end
        if player:isAsleep() then break end
        if player:HasTrait("Alcoholic") == false then break end

        if player:getModData().AlcoholicTimeSinceLastDrink > sBVars.DrinkInterval - 1 and sBVars.OnlyStressed == false
        then
            if TheAlcoholic.values.DebugMode == true
            then
                print("Drinking because of time")
            end
            TheAlcoholic.AutoDrink:drinkFromFlask()
        elseif player:getStats():getStress() - player:getStats():getStressFromCigarettes() >= stressThreshold
        then
            print ("Stress: " .. player:getStats():getStress() - player:getStats():getStressFromCigarettes())
            print ("Threshold: " .. stressThreshold)
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
            if TheAlcoholic.AutoDrink:canDrink() and hasDrankFromStressThisHour == false then
                if TheAlcoholic.values.DebugMode == true
                then
                    print("Drinking because of stress")
                end
                TheAlcoholic.AutoDrink:drinkFromFlask(true)
            end
        end
    end
end

function TheAlcoholic.AutoDrink.EveryHours()
    hasDrankFromStressThisHour = false
end

-- EVENTS

Events.OnLoad.Add(TheAlcoholic.AutoDrink.onLoad)
Events.OnCreatePlayer.Add(TheAlcoholic.AutoDrink.onCreatePlayer)
Events.EveryHours.Add(TheAlcoholic.AutoDrink.EveryHours)