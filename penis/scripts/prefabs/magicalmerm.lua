

local assets=
{
	Asset("ANIM", "anim/merm_build.zip"),
	Asset("ANIM", "anim/ds_pig_basic.zip"),
	Asset("ANIM", "anim/ds_pig_actions.zip"),
	Asset("ANIM", "anim/ds_pig_attacks.zip"),
	Asset("SOUND", "sound/merm.fsb"),
}

local prefabs =
{
    "fish",
    "froglegs",
    "footballhat",
}

local loot = 
{
    "fish",
    "froglegs",
}

local start_inv =
{
    "footballhat",
}

-------adding starting inventory items? TBchecked

local function OninizializzaInventario(inst)
	-- inst.components.inventory:GuaranteeItems({"footballhat"})
    local newpoop = SpawnPrefab("footballhat")
            inst.components.inventory:GiveItem(newpoop)
        if newpoop then
        if newpoop.components.equippable and
        newpoop.components.equippable.equipslot == EQUIPSLOTS.HEAD then
    inst:DoTaskInTime(0.1, function() inst.components.inventory:Equip(newpoop) end)
        end
        end
end

-- local newpoop = SpawnPrefab("poop")
--             inst.components.inventory:GiveItem(newpoop)
--             print("DoTaskInTime")

-- local function OninizializzaInventario2(inst, start_inv)   
--         inst.components.inventory:Equip("footballhat")
--         inst.AnimState:Show("hat")
--         print("ma sta funzionando2")
-- end

        -- inst:DoTaskInTime(0.1, function() inst.components.inventory:Equip(data.item) end)   

        -- self.inst:ListenForEvent("attacked", function(inst, data) self:OnAttacked(data.attacker) end)   

-----magicalmerm accept items

local function ShouldAcceptItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        return false
    end
    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        
        -- if (item.components.edible.foodtype == "VEGGIE")
        --    -- and inst.components.follower.leader
        --    -- and inst.components.follower:GetLoyaltyPercent() > 0.9 
        --    then
        --     return false
        -- end
        
        -- if item.components.edible.foodtype == "MEAT" then     
        --       return false
        --     end

        --     if inst.components.inventory:Has(item.prefab, 1) then
        --         return false
        --     end
        -- end
        
       return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)

    --I wear hats
    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current then
            inst.components.inventory:DropItem(current)
        end
        
        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
end

local function ShouldWake(inst)
    return GetClock():IsDay()
           or (inst.components.combat and inst.components.combat.target)
           or (inst.components.burnable and inst.components.burnable:IsBurning() )
           or (inst.components.freezable and inst.components.freezable:IsFrozen() )
end

local function ShouldSleep(inst)

    return not GetClock():IsDay()
           and not (inst.components.combat and inst.components.combat.target)
           and not (inst.components.burnable and inst.components.burnable:IsBurning() )
           and not (inst.components.freezable and inst.components.freezable:IsFrozen() )
end

local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.MERM_TARGET_DIST,function(guy)
                return guy:HasTag("monster") and guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) and not 
                (inst.components.follower.leader ~= nil and guy:HasTag("abigail"))
        end)
end

local function NormalKeepTargetFn(inst, target)
    --give up on dead guys
    return inst.components.combat:CanTarget(target)
end
---------OnAttacked already present in magicalmermbrain?

local function OnAttacked(inst, data)
    --print(inst, "OnAttacked")
    local attacker = data.attacker

    inst.components.combat:SetTarget(attacker)
end
------------------------------------
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
    local whoisplayer = GetPlayer()

	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)

    inst:AddTag("character")
    inst:AddTag("merm")
    inst:AddTag("magicalmerm")
    -- inst:AddTag("summonedbyplayer")
    inst:AddTag("wet")
    -- inst:AddTag("scarytoprey")

    anim:SetBank("pigman")
    anim:SetBuild("merm_build")

    ------------------------------------------
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.MERM_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.MERM_WALK_SPEED
    
    inst:SetStateGraph("SGmerm")
    anim:Hide("hat")

    local brain = require "brains/magicalmermbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
--------------    
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = 99999999
    whoisplayer.components.leader:AddFollower(inst)
    inst.components.follower:AddLoyaltyTime(9999999)
--------------  
    inst:AddComponent("talker")
    inst.components.talker:StopIgnoringAll()
--------------        
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
--------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetAttackPeriod(TUNING.MERM_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, NormalRetargetFn)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
--------------    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MERM_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.MERM_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.MERM_ATTACK_PERIOD)
-------------
    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.MAGICALMERM_NAMES
    inst.components.named:PickNewName()
-------------

 -------------   
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    
    inst:AddComponent("inventory")
    OninizializzaInventario(inst)

    
    inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = function(inst)
        if inst.components.follower.leader ~= nil then
            return "FOLLOWER"
        end
    end

    inst:AddComponent("knownlocations")

-----------------
    inst:AddComponent("trader")
    inst.components.trader:Enable()
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
-----------------
    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

    ------------------------------------------

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("inizializzaInventario", OninizializzaInventario)
    
    return inst
end

return Prefab( "common/magicalmerm", fn, assets, prefabs, loot, start_inv)
