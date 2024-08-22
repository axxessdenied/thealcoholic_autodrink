function TheAlcoholic.canDrink(player)
    return not player:isStrafing()
        and not player:isAiming()
        and not player:isAsleep()
        and not player:isRunning()
        and not player:isSprinting()
end