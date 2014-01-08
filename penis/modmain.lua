PrefabFiles = {
    "penis",
	"magicalmerm"
}

        STRINGS = GLOBAL.STRINGS
        RECIPETABS = GLOBAL.RECIPETABS
        Recipe = GLOBAL.Recipe
        Ingredient = GLOBAL.Ingredient
        TECH = GLOBAL.TECH

-- [[ DebugKeys enabled - to be disabled when mod is released to the public ]] -- 
        GLOBAL.CHEATS_ENABLED = true
        GLOBAL.require( 'debugkeys' )

-- [[ penis BEGIN ]] -- 
        GLOBAL.STRINGS.NAMES.PENIS = "Crow Stick"

        STRINGS.RECIPE_DESC.PENIS = "Superb work of a genius "

        GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PENIS = "Look at that sharp beak!"
		
		TUNING.PENIS_DAMAGE = (50)

        local penis = GLOBAL.Recipe("penis",{ Ingredient("feather_crow", 2), Ingredient("twigs", 1) },                     
        RECIPETABS.WAR, TECH.NONE)
        penis.atlas = "images/inventoryimages/penis.xml"

-- [[ magicalmerm BEGIN ]] --
        GLOBAL.STRINGS.MAGICALMERM_NAMES = { "Fthagn", "Trota", "Schot", "Wet One" }
        GLOBAL.STRINGS.MAGICALMERM_TALK_PANICFIRE = { "Oww!", "I'm burning!", "It burns!" }
        GLOBAL.STRINGS.MAGICALMERM_TALK_HELP_CHOP_WOOD = { "For master!", "", "Heigh-ho!", "We chop chop chop", "Heigh-ho", "Heigh-ho hum", "All day no rest", "Whole day through", "Don't need no axe!", "Chop!", "Yes master!" }
        GLOBAL.STRINGS.MAGICALMERM_TALK_FIGHT = { "Come here you!", "Wanna fight!?", "Banzai!" }
        GLOBAL.STRINGS.MAGICALMERM_TALK_FOLLOWWILSON= "test"

        STRINGS.NAMES.MAGICALMERM = "Merm Plushie"
        STRINGS.RECIPE_DESC.MAGICALMERM = "Stitch together a toy and give it life."
        STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICALMERM = {}
        STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICALMERM.GENERIC = "The dark side of Science."
        STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICALMERM = "LIFE SPRINGS FROM LIFE"
        STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICALMERM = "What a tiny spark could do to that!"
        STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICALMERM = "I think I read about these guys..."
        STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICALMERM = "Bah! No heart."
        STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICALMERM = "What moves its soul?"
        STRINGS.CHARACTERS.MAGICALMERM = {}
        STRINGS.CHARACTERS.MAGICALMERM.COMBAT_QUIT={GENERIC = " ",}
