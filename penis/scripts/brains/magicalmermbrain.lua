require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
--require "behaviours/choptree"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/leash"

local SEE_DIST = 20

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9
local MAX_WANDER_DIST = 10

local MIN_FOLLOW_LEADER = 2
local MAX_FOLLOW_LEADER = 8
local TARGET_FOLLOW_LEADER = (MAX_FOLLOW_LEADER+MIN_FOLLOW_LEADER)/2

local RUN_AWAY_DIST = 1
local STOP_RUN_AWAY_DIST = 8

local GO_HOME_DIST = 5

local KEEP_FACE_DIST = 8
local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_LIGHT_DIST = 20
local TRADE_DIST = 20
local SEE_TREE_DIST = 15
local SEE_TARGET_DIST = 20
local SEE_FOOD_DIST = 10

local KEEP_CHOPPING_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8


local function ShouldRunAway(inst, target)
    return not inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetTraderFn(inst)
    return FindEntity(inst, TRADE_DIST, function(target) return inst.components.trader:IsTryingToTradeWithMe(target) end, {"player"})
end

local MagicalMermBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MagicalMermBrain:OnAttacked(attacker)
    self.inst.components.combat:SetTarget(attacker)
    self.inst.components.combat:ShareTarget(attacker, 30, function(dude) return dude:HasTag("magicalmerm") and dude.components.follower.leader == GetPlayer() end, 5)
end


local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function StartChoppingCondition(inst)
    return inst.components.follower.leader and inst.components.follower.leader.sg:HasStateTag("chopping")
end


local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function GetStayPos(inst)
    return inst.components.followersitcommand.locations["currentstaylocation"]
end

local function GetWanderPoint(inst)
        local target = GetLeader(inst) or GetPlayer()
        if target then
                return target:GetPosition()
            end
end

local function KeepChoppingAction(inst)
    -- I used combat cooldown. Combat time is added by merm stategraph chopping
    if not inst.components.combat:InCooldown() then
            return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_CHOPPING_DIST*KEEP_CHOPPING_DIST
    else return false end
end

local function StartChoppingCondition(inst)
    return inst.components.follower.leader and inst.components.follower.leader.sg:HasStateTag("chopping")
end


local function FindTreeToChopAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.CHOP end)
    if target then
        return BufferedAction(inst, target, ACTIONS.CHOP)
    end
end


local function ShouldGoHome(inst)
    local homePos = inst.components.followersitcommand.locations["currentstaylocation"]
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) > GO_HOME_DIST*GO_HOME_DIST)
end

local function GoHomeAction(inst)
    local homePos = inst.components.followersitcommand.locations["currentstaylocation"]
    if homePos then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, 0.2)
    end
end

-- local function EatFoodAction(inst)
--     local target = FindEntity(inst, SEE_DIST, function(item) return item:HasTag("insect") end)
--     if target then
--         return BufferedAction(inst, target, ACTIONS.EAT)
--     end
-- end

local function EatFoodAction(inst)
    local target = nil
    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end
    if not target then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) return inst.components.eater:CanEat(item) end)
    end
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem.owner and target.components.inventoryitem.owner ~= inst) end
        return act
    end
end

    -------------------------------------------------------------------------- MEMBRAIN

-- function MermBrain:OnStart()
--     local root = PriorityNode(
--     {
--         WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
--         WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
--             ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) ),
--         WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
--             RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ),

--         IfNode(function() 
--             if (self.inst.components.follower.leader == nil) then
--                     local x,y,z = self.inst.Transform:GetWorldPosition()
--                 local ents = TheSim:FindEntities(x,y,z, TUNING.SPIDERHAT_RANGE, {"player"})
--                 if (#ents > 0) then
--                     local newfather = ents[1]
--                     newfather.components.leader:AddFollower(self.inst)
--                     self.inst.components.follower.maxfollowtime = 99999999
--                     self.inst.components.follower:AddLoyaltyTime(9999999)
--                     self.inst.components.combat:GiveUp()
--                     return true
--                 else return false
--                 end
--             end
--         end,

--         DoAction(self.inst, EatFoodAction, "Eat Food"),

--         IfNode(function() return self.inst.components.follower.leader ~= nil end, "has leader",
--             FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),
--             Wander(self.inst)
--     }, .5)
   
--     self.bt = BT(self.inst, root)
    
--     self.inst:ListenForEvent("attacked", function(inst, data) self:OnAttacked(data.attacker) end)    
-- end

function MagicalMermBrain:OnStart()
       
    local root = 
        PriorityNode(
        {

        IfNode(function() 
            local target = self.inst.components.combat.target
                if target and target:HasTag("bee") then
                local beehome = target.components.homeseeker and target.components.homeseeker.home 
                if beehome and beehome.prefab == "beebox" then
                    self.inst.components.combat:GiveUp()
                end
            end
        end,
        "OnFire", Panic(self.inst) ),
            
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
            ChattyNode(self.inst, STRINGS.MAGICALMERM_TALK_PANICFIRE,
                Panic(self.inst))),
            ChattyNode(self.inst, STRINGS.MAGICALMERM_TALK_FIGHT,
                WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                    ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) )),
            ChattyNode(self.inst, STRINGS.MAGICALMERM_TALK_FIGHT,
                WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
                    RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) )),

        IfNode(function() 
            if (self.inst.components.follower.leader == nil) then
                    local x,y,z = self.inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x,y,z, TUNING.SPIDERHAT_RANGE, {"player"})
                if (#ents > 0) then
                    local newfather = ents[1]
                    newfather.components.leader:AddFollower(self.inst)
                    self.inst.components.follower.maxfollowtime = 99999999
                    self.inst.components.follower:AddLoyaltyTime(9999999)
                    self.inst.components.combat:GiveUp()
                    return true
                else return false
                end
            end
        end,
        "OnFire", Panic(self.inst) ),

         IfNode(function() return StartChoppingCondition(self.inst) end, "chop", 
                WhileNode(function() return KeepChoppingAction(self.inst) end, "keep chopping",
                    LoopNode{ 
                        ChattyNode(self.inst, STRINGS.MAGICALMERM_TALK_HELP_CHOP_WOOD,
                            DoAction(self.inst, function() return FindTreeToChopAction(self.inst) end ))})),

        IfNode(function() 
        if self.inst.components.follower.leader ~= nil and self.inst.components.followersitcommand and self.inst.components.followersitcommand:IsCurrentlyStaying() == false then
            return true
        elseif self.inst.components.follower.leader ~= nil and not self.inst.components.followersitcommand then
            return true
        end
        end, "has leader",  
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER)),
        -- and one where it is "gohome" to a position
    IfNode(function() 
        
        if self.inst.components.follower.leader ~= nil and self.inst.components.followersitcommand and self.inst.components.followersitcommand:IsCurrentlyStaying() == true then
            return true
        end
        end, "has leader",  
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
                    DoAction(self.inst, GoHomeAction, "Go Home", true ))),  

    DoAction(self.inst, EatFoodAction, "Eat Food"),

    IfNode(function() return self.inst.components.follower.leader ~= nil end, "has leader",
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),
       Wander(self.inst)
        }, .5)
    
    self.bt = BT(self.inst, root)
    
    self.inst:ListenForEvent("attacked", function(inst, data) self:OnAttacked(data.attacker) end)    
end

function MagicalMermBrain:OnInitializationComplete()
    --self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))
end

return MagicalMermBrain

