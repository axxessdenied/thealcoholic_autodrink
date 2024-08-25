require 'Items/ProceduralDistributions'

TheAlcoholic.AutoDrink.items = table.newarray()

local function addDistribution(data, locations)
    for item, chance in pairs(data)
	do
        if #locations > 0
        then
            table.insert(TheAlcoholic.AutoDrink.items, item)
        
            for i, location in ipairs(locations)
            do
                if ProceduralDistributions.list[location] and ProceduralDistributions.list[location].items
                then
                    table.insert(ProceduralDistributions.list[location].items, item);
                    table.insert(ProceduralDistributions.list[location].items, chance);
                end
            end
        end
	end
end

if TheAlcoholic.AutoDrink.sBVars == nil then
    TheAlcoholic.AutoDrink.sBVars = TheAlcoholic.AutoDrink.onInitModData()
end

local sBVars = TheAlcoholic.AutoDrink.sBVars

if sBVars == nil then sBVars = SandboxVars.TheAlcoholicAutoDrink end

local flaskFullRarity   = sBVars.LootSpawnChance * 0.025
local flaskEmptyRarity  = sBVars.LootSpawnChance * 0.05
local flaskWaterRarity  = sBVars.LootSpawnChance * 0.05
local flaskLocations    = {
    "BathroomCabinet",
    "BathroomCounter",
    "BedroomDresser",
    "BedroomSideTable",
    "ClosetShelfGeneric",
    "DeskGeneric",
    "DresserGeneric",
    "FilingCabinetGeneric",
    "FridgeOffice",
    "GarageTools",
    "JunkHoard",
    "KitchenRandom",
    "KitchenBottles",
    "LibraryCounter",
    "LivingRoomShelf",
    "LivingRoomSideTable",
    "Locker",
    "LockerArmyBedroom",
    "LockerClassy",
    "MechanicShelfMisc",
    "OfficeCounter",
    "OfficeDesk",
    "OfficeDeskHome",
    "OfficeDrawers",
    "OtherGeneric",
    "PlankStashMisc",
    "PoliceDesk",
    "RandomFiller",
    "SafehouseMedical",
    "ShelfGeneric",
    "WardrobeMan",
    "WardrobeManClassy",
    "WardrobeWoman",
    "WardrobeWomanClassy",
}

if sBVars.WorldSpawnFlasks == true
then
    addDistribution(
    {
        ["TheAlcoholic.FlaskEmpty"]             =       flaskEmptyRarity,
        ["TheAlcoholic.FlaskWhiskeyFull"]       =       flaskFullRarity,
        ["TheAlcoholic.FlaskWineFull"]          =       flaskFullRarity,
        ["TheAlcoholic.FlaskWine2Full"]         =       flaskFullRarity,
        ["TheAlcoholic.FlaskWaterFull"]         =       flaskWaterRarity,
    }, flaskLocations
)
else
    addDistribution(
    {
        ["TheAlcoholic.FlaskEmpty"]             =       flaskEmptyRarity,
        ["TheAlcoholic.FlaskWhiskeyFull"]       =       flaskFullRarity,
        ["TheAlcoholic.FlaskWineFull"]          =       flaskFullRarity,
        ["TheAlcoholic.FlaskWine2Full"]         =       flaskFullRarity,
        ["TheAlcoholic.FlaskWaterFull"]         =       flaskWaterRarity,
    },
    {}
)
end