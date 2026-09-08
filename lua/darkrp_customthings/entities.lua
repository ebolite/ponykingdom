--[[---------------------------------------------------------------------------
DarkRP custom entities
---------------------------------------------------------------------------

This file contains your custom entities.
This file should also contain entities from DarkRP that you edited.

Note: If you want to edit a default DarkRP entity, first disable it in darkrp_config/disabled_defaults.lua
    Once you've done that, copy and paste the entity to this file and edit it.

The default entities can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/addentities.lua

For examples and explanation please visit this wiki page:
https://darkrp.miraheze.org/wiki/DarkRP:CustomEntityFields

Add entities under the following line:
---------------------------------------------------------------------------]]

local function spawnDebugItem(itemID, makeData)
    return function(ply, trace, definition)
        if not PonyRP or not PonyRP.Inventory or not PonyRP.Inventory.GetItemDef(itemID) then
            error("PonyRP debug item definition is unavailable: " .. itemID)
        end

        local data = makeData and makeData() or { createdAt = os.time() }
        local ent = ents.Create("ponyrp_item")
        if not IsValid(ent) then error("PonyRP world item entity is unavailable") end

        ent:SetupItem(itemID, data)
        ent:SetPos(trace.HitPos)
        if ent.Setowning_ent then ent:Setowning_ent(ply) end
        ent.SID = ply.SID
        ent.allowed = definition.allowed
        ent.DarkRPItem = definition
        ent:Spawn()
        ent:Activate()
        DarkRP.placeEntity(ent, trace, ply)
        if ent.CPPISetOwner then ent:CPPISetOwner(ply) end

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
        return ent
    end
end

local function makeFilledContainer(itemID, contents)
    return function()
        local Alchemy = PonyRP and PonyRP.Alchemy
        local Items = Alchemy and Alchemy.Items
        if not Items or not Items.BuildVessel then
            error("PonyRP alchemy vessel support is unavailable")
        end

        local data = { createdAt = os.time() }
        local vessel = Items.BuildVessel(itemID, data)
        if not vessel then error("PonyRP could not build alchemy container: " .. itemID) end
        for substance, amount in pairs(contents) do
            if not Alchemy.AddAmount(vessel, substance, amount, false) then
                error("PonyRP could not fill " .. itemID .. " with " .. substance)
            end
        end
        Items.StoreVessel(data, vessel)
        Items.RefreshLook(data, vessel)
        return data
    end
end

local GLASS = Color(226, 232, 240, 255)
local CROP = Color(180, 210, 140, 255)
local MINERAL = Color(168, 168, 176, 255)

-- The apple as it is found: the species' own wild genome, mostly water.
local function makeAppleSeed()
    local genome = PonyRP and PonyRP.Genetics and PonyRP.Genetics.WildGenome("apple")
    if not genome then error("PonyRP genetics are unavailable") end
    return { createdAt = os.time(), genome = genome }
end

-- A genome built the way the production-math table builds one: the eight locked
-- genes, then extra Size, Speed and Yield, then every remaining slot poured
-- into the target substance. Nothing grows like this without being bred for it.
local function makeMathSeed(size, speed, yield)
    local species = PonyRP and PonyRP.Plants and PonyRP.Plants.Get("apple")
    if not species then error("PonyRP genetics are unavailable") end

    local genes = {}
    for _, id in ipairs(species.locked) do table.insert(genes, id) end
    for _ = 2, size or 2 do table.insert(genes, "size") end
    for _ = 2, speed or 2 do table.insert(genes, "speed") end
    for _ = 2, yield or 2 do table.insert(genes, "yield") end
    while #genes < species.slots do table.insert(genes, "salt") end

    return { createdAt = os.time(), genome = { species = "apple", genes = genes } }
end

local function makeAppleFruit()
    local fruit = PonyRP.Genetics.Harvest(makeAppleSeed().genome, nil, 0)[1]
    fruit.createdAt = os.time()
    return fruit
end

local debugPonyItems = {
    {
        name = "Generic Item",
        itemID = "debug_generic_item",
        model = "models/props_junk/garbage_metalcan001a.mdl",
        command = "buydebuggenericitem",
        color = Color(112, 196, 255, 255),
    },
    {
        name = "Long Item",
        itemID = "debug_long_item",
        model = "models/props_c17/tools_wrench01a.mdl",
        command = "buydebuglongitem",
        color = Color(235, 98, 98, 255),
    },
    {
        name = "Fat Item",
        itemID = "debug_fat_item",
        model = "models/props_junk/watermelon01.mdl",
        command = "buydebugfatitem",
        color = Color(198, 137, 255, 255),
    },

    {
        name = "Vial",
        itemID = "ponyrp_vial",
        model = "models/ponyrp_content/glassware/vial.mdl",
        command = "buydebugvial",
        color = GLASS,
    },
    {
        name = "Flask",
        itemID = "ponyrp_flask",
        model = "models/ponyrp_content/glassware/flask.mdl",
        command = "buydebugnormalflask",
        color = GLASS,
    },
    {
        name = "Glass",
        itemID = "ponyrp_glass",
        model = "models/ponyrp_content/glassware/drinkingglass.mdl",
        command = "buydebugglass",
        color = GLASS,
    },
    {
        name = "Bowl",
        itemID = "ponyrp_bowl",
        model = "models/ponyrp_content/glassware/bowl.mdl",
        command = "buydebugbowl",
        color = GLASS,
    },
    {
        name = "Yeast Starter Flask",
        itemID = "ponyrp_flask",
        model = "models/ponyrp_content/glassware/flask.mdl",
        command = "buydebugyeaststarter",
        color = GLASS,
        makeData = makeFilledContainer("ponyrp_flask", { yeast = 1 }),
    },
    {
        name = "Flask of Water",
        itemID = "ponyrp_flask",
        model = "models/ponyrp_content/glassware/flask.mdl",
        command = "buydebugaquaflask",
        color = GLASS,
        makeData = makeFilledContainer("ponyrp_flask", { aqua = 100 }),
    },
    {
        name = "Bowl of Water",
        itemID = "ponyrp_bowl",
        model = "models/ponyrp_content/glassware/bowl.mdl",
        command = "buydebugaquabowl",
        color = GLASS,
        makeData = makeFilledContainer("ponyrp_bowl", { aqua = 200 }),
    },

    {
        name = "Apple",
        itemID = "ponyrp_fruit",
        model = "models/sg_props/props_consumable/apple.mdl",
        command = "buydebugapple",
        color = CROP,
        makeData = makeAppleFruit,
    },

    -- Mining and crafting. The pickaxe carries its tier and durability, so a
    -- fresh one is bought rather than crafted when only the swing is wanted.
    {
        name = "Basic Pickaxe",
        itemID = "ponyrp_pickaxe",
        model = "models/models/namje/wep/bw_wpn_shp_pickaxe.mdl",
        command = "buydebugpickaxe",
        color = MINERAL,
        makeData = function()
            return { createdAt = os.time(), tier = "basic" }
        end,
    },
    {
        name = "Fortified Pickaxe",
        itemID = "ponyrp_pickaxe",
        model = "models/models/namje/wep/bw_wpn_shp_pickaxe.mdl",
        command = "buydebugpickaxefortified",
        color = MINERAL,
        makeData = function()
            return { createdAt = os.time(), tier = "fortified", durability = 200 }
        end,
    },
    {
        name = "Augmented Pickaxe",
        itemID = "ponyrp_pickaxe",
        model = "models/models/namje/wep/bw_wpn_shp_pickaxe.mdl",
        command = "buydebugpickaxeaugmented",
        color = MINERAL,
        makeData = function()
            return { createdAt = os.time(), tier = "augmented", durability = 500 }
        end,
    },
    {
        name = "Rock",
        itemID = "ponyrp_rock",
        model = "models/equestrianhorizon/mlp_props/rock_tiny_a.mdl",
        command = "buydebugrock",
        color = MINERAL,
        makeData = function()
            return { createdAt = os.time(), contents = { rock = 25 } }
        end,
    },
    {
        name = "Apple Seed",
        itemID = "ponyrp_seed",
        model = "models/props_junk/garbage_metalcan001a.mdl",
        command = "buydebugappleseed",
        color = CROP,
        makeData = makeAppleSeed,
    },
    {
        name = "Fast Apple Seed",
        itemID = "ponyrp_seed",
        model = "models/props_junk/garbage_metalcan001a.mdl",
        command = "buydebugfastseed",
        color = CROP,
        -- Size 4, Speed 4, Yield 5: the 30-slot row from the production math,
        -- which ripens in ten minutes and gives 520u of Nutrium.
        makeData = function() return makeMathSeed(4, 4, 5) end,
    },
}

for kind in pairs((PonyRP and PonyRP.Recipes and PonyRP.Recipes.UPGRADES) or {}) do
    table.insert(debugPonyItems, {
        name = "Upgrade: " .. kind,
        itemID = "ponyrp_upgrade_" .. kind,
        model = "models/props_lab/reciever01b.mdl",
        command = "buydebugupgrade" .. kind,
        color = Color(196, 204, 216, 255),
    })
end

for itemID, spec in pairs((PonyRP and PonyRP.Storage and PonyRP.Storage.CRATES) or {}) do
    table.insert(debugPonyItems, {
        name = spec.name,
        itemID = itemID,
        model = spec.model,
        command = "buydebug" .. string.gsub(itemID, "ponyrp_", ""),
        color = Color(190, 160, 120, 255),
    })
end

-- Apparatus are their own entity classes rather than inventory items, so they
-- spawn through DarkRP's default handler instead of spawnDebugItem.
local debugPonyApparatus = {
    {
        name = "Debug Dispenser",
        class = "ponyrp_debugdispenser",
        model = "models/xqm/hydcontrolbox.mdl",
        command = "buydebugdispenser",
    },
    {
        name = "Alembic",
        class = "ponyrp_alembic",
        model = "models/gibs/airboat_broken_engine.mdl",
        command = "buydebugnormalalembic",
    },
    {
        name = "Macerator",
        class = "ponyrp_macerator",
        model = "models/props_c17/trappropeller_engine.mdl",
        command = "buydebugnormalmacerator",
    },
    {
        name = "Furnace",
        class = "ponyrp_furnace",
        model = "models/props/cs_militia/microwave01.mdl",
        command = "buydebugfurnace",
    },
    {
        name = "Crystal Analyzer",
        class = "ponyrp_analyzer",
        model = "models/props_lab/hev_case.mdl",
        command = "buydebuganalyzer",
    },
    {
        name = "Codex",
        class = "ponyrp_codexbook",
        model = "models/sg_props/Book.mdl",
        command = "buydebugnotes",
    },
    {
        name = "Debugalembic",
        class = "ponyrp_debugalembic",
        model = "models/gibs/airboat_broken_engine.mdl",
        command = "buydebugalembic",
    },
    {
        name = "Debugmacerator",
        class = "ponyrp_debugmacerator",
        model = "models/props_c17/trappropeller_engine.mdl",
        command = "buydebugmacerator",
    },
    {
        name = "Crusher",
        class = "ponyrp_crusher",
        model = "models/props_wasteland/gear01.mdl",
        command = "buydebugcrusher",
    },
    {
        name = "Crafting Table",
        class = "ponyrp_craftingtable",
        model = "models/props_c17/FurnitureTable002a.mdl",
        command = "buydebugcraftingtable",
    },
    {
        name = "Planter",
        class = "ponyrp_planter",
        model = "models/nater/weedplant_pot.mdl",
        command = "buydebugplanter",
    },
    {
        name = "Seed Machine",
        class = "ponyrp_seedmachine",
        model = "models/props_wasteland/laundry_washer003.mdl",
        command = "buydebugseedmachine",
    },
    {
        name = "Crate",
        class = "ponyrp_crate",
        model = "models/equestrianhorizon/mlp_props/crate.mdl",
        command = "buydebugcrateworld",
    },
}

local existingCommands = {}
for _, definition in ipairs(DarkRPEntities or {}) do existingCommands[definition.cmd] = true end

for sortOrder, item in ipairs(debugPonyItems) do
    if not existingCommands[item.command] then
        DarkRP.createEntity(item.name, {
            ent = "ponyrp_item",
            model = item.model,
            price = 1,
            max = 10,
            cmd = item.command,
            allowed = { TEAM_DEBUGPONY },
            category = "Debugpony Items",
            sortOrder = sortOrder,
            buttonColor = item.color,
            -- PonyRP purchases are shareable world items unless a particular
            -- definition explicitly opts back into DarkRP purchaser ownership.
            ownedByPurchaser = item.ownedByPurchaser == true,
            spawn = spawnDebugItem(item.itemID, item.makeData),
        })
    end
end

for sortOrder, machine in ipairs(debugPonyApparatus) do
    if not existingCommands[machine.command] then
        DarkRP.createEntity(machine.name, {
            ent = machine.class,
            model = machine.model,
            price = 1,
            max = 2,
            cmd = machine.command,
            allowed = { TEAM_DEBUGPONY },
            category = "Debugpony Items",
            sortOrder = 100 + sortOrder,
            buttonColor = Color(198, 137, 255, 255),
        })
    end
end
