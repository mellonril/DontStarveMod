require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.CHOP, "chop"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("attack") end end),
    EventHandler("doaction", 
        function(inst, data) 
            if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
                if data.action == ACTIONS.CHOP then
                    inst.sg:GoToState("chop", data.target)
                end
            end
        end),
    
}

local states=
{
    State{
        name= "funnyidle",
        tags = {"idle"},
        
        onenter = function(inst)
			inst.Physics:Stop()
            local currentclockphase = GetClock():GetPhase()
	    if currentclockphase == "day" then 
		    inst.AnimState:PlayAnimation("idle_happy")
	    elseif currentclockphase == "night" then 
		    inst.AnimState:PlayAnimation("idle_creepy")
	    else
		    inst.AnimState:PlayAnimation("idle_angry")
	    end
            inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/hurt")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
    State {
		name = "frozen",
		tags = {"busy"},
		
        onenter = function(inst)
            inst.AnimState:PlayAnimation("frozen")
            inst.Physics:Stop()
            inst.components.highlight:SetAddColour(Vector3(82/255, 115/255, 124/255))
        end,
    },
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    State{
		name = "abandon",
		tags = {"busy"},
		
		onenter = function(inst, leader)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("abandon")
            inst:FacePoint(Vector3(leader.Transform:GetWorldPosition()))
		end,
		
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
   
    State{
        name = "attack",
        tags = {"attack"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/attack")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "chop",
        tags = {"chopping"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
	    inst.components.combat:StartAttack()
	    print (" chopped once!")
        end,
        
        timeline=
        {
            
            TimeEvent(13*FRAMES, function(inst) inst:PerformBufferedAction() end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("eat")
        end,
        
        timeline=
        {

		TimeEvent(3*FRAMES, function(inst) 
		    
		    	local target = FindEntity(inst, 2, function(item) return item:HasTag("insect") end)
    			if target then
				target:Remove()
				inst.components.eater.lasteattime = GetTime()
				inst.components.health:DoDelta(10)  
   			end

		    end),

		
            TimeEvent(20*FRAMES, function(inst) 
		    
		    	

		    inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddSleepStates(states,
{
	sleeptimeline = 
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/sleep") end ),
	},
})

CommonStates.AddIdle(states,"funnyidle")
CommonStates.AddSimpleState(states,"hit", "hit", {"busy"})
CommonStates.AddSimpleState(states,"refuse", "pig_reject", {"busy"})
CommonStates.AddFrozenStates(states)

CommonStates.AddSimpleActionState(states,"pickup", "pig_pickup", 10*FRAMES, {"busy"})

CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4*FRAMES, {"busy"})

    
return StateGraph("magicalmerm", states, events, "idle", actionhandlers)


