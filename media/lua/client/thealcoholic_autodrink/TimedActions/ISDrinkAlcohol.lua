-- (c) 2024 - axxessdenied [Nick Slusarczyk]

require('TimedActions/ISEatFoodAction')

ISDrinkAlcohol = ISEatFoodAction:derive("ISDrinkAlcohol")

local eat_perform = ISEatFoodAction.perform
local eat_new = ISEatFoodAction.new

function ISDrinkAlcohol:perform()
    eat_perform(self)

    -- todo: custom stuff here
end

function ISDrinkAlcohol:new(character, item, percentage)
    local o = eat_new(self, character, item, percentage)
    setmetatable(o, self)
    self.__index = self
    return o
end