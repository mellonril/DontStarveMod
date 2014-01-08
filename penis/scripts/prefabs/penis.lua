local assets=
{ 
    Asset("ANIM", "anim/penis.zip"),
    Asset("ANIM", "anim/swap_penis.zip"), 

    Asset("ATLAS", "images/inventoryimages/penis.xml"),
    Asset("IMAGE", "images/inventoryimages/penis.tex"),
}

local function onfinished(inst)
    inst:Remove()
end

----Adding "magicalmerm" for spawning otherwise empty
local prefabs = 
{
    "magicalmerm",
    "splash_ocean",
}

-------------------------------------

local function fn(colour)

 --    local function OnEquip(inst, owner) 
	-- 	owner.SoundEmitter:PlaySound("dontstarve/birds/chirp_crow")   
 --        owner.AnimState:OverrideSymbol("swap_object", "swap_penis", "penis")
 --        owner.AnimState:Show("ARM_carry") 
 --        owner.AnimState:Hide("ARM_normal")
 --        SpawnPrefab("magicalmerm").Transform:SetPosition(inst.Transform:GetWorldPosition()) 
	-- end



    local function OnEquip(inst, owner) 
    	owner.AnimState:OverrideSymbol("swap_object", "swap_penis", "penis")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal")
    -- this part spawn nummagicalmerm around the player
	local pt = Vector3(owner.Transform:GetWorldPosition())

    local nummagicalmerm = 4

    owner:StartThread(function()
        for k = 1, nummagicalmerm do
        
            local theta = math.random() * 2 * PI
            local radius = math.random(3, 8)

            -- we have to special case this one because birds can't land on creep
            local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                local x,y,z = (pt + offset):Get()
                local ents = TheSim:FindEntities(x,y,z , 1)
                return not next(ents) 
            end)

            if result_offset then
                local magicalmerm = SpawnPrefab("magicalmerm")
                
                magicalmerm.Transform:SetPosition((pt + result_offset):Get())
                GetPlayer().components.playercontroller:ShakeCamera(owner, "FULL", 0.2, 0.02, .25, 40)
                
                --need a better effect
                local fx = SpawnPrefab("splash_ocean")
                local pos = pt + result_offset
                fx.Transform:SetPosition(pos.x, pos.y, pos.z)
                --PlayFX((pt + result_offset), "splash", "splash_ocean", "idle")
            end

            Sleep(.33)
        end
    end)
    return true  
    end  

    local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end
	-----------------------------
	
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("penis")
    anim:SetBuild("penis")
    anim:PlayAnimation("idle")
	
	------weapon part
	
    inst:AddTag("sharp")
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.PENIS_DAMAGE)
    
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)
    
    inst.components.finiteuses:SetOnFinished( onfinished )
	
	------------------
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "penis"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/penis.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )

    return inst
end

return  Prefab("common/inventory/penis", fn, assets, prefabs)