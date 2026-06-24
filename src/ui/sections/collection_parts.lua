Glossary.collection_part_buttons = {
	consumeables = function(item)
		local key = item.set
		if not key then
			return
		end
		return Glossary.UI.simple_collection_part_button({
			id = "your_collection_" .. key:lower() .. "s",
			label = localize("b_" .. key:lower() .. "_cards"),
			tallies = key:lower() .. "s",
			colour = G.C.SECONDARY_SET[key],
			mod = item.mod,
			item = item,
		})
	end,
	enhancements = {
		tallies = false,
		label = function(item)
			return localize("b_enhanced_cards")
		end,
	},
	editions = {
		tallies = true,
	},
	seals = {
		tallies = false,
	},
	vouchers = {
		tallies = true,
	},
	boosters = {
		tallies = true,
		label = function(item)
			return localize("b_booster_packs")
		end,
	},
	tags = {
		tallies = true,
	},
	blinds = {
		tallies = true,
	},
	jokers = {
		tallies = true,
	},
	stickers = {
		count = function(item)
			return G.ACTIVE_MOD_UI and modsCollectionTally(SMODS.Stickers)
		end,
	},
	poker_hands = {
		count = function(item)
			return G.ACTIVE_MOD_UI and modsCollectionTally(SMODS.PokerHands, nil, true)
		end,
	},
}

function Glossary.UI.simple_collection_part_button(args)
	local old_active_ui = G.ACTIVE_MOD_UI
	local id = args.id
	local label = args.label
	if args.mod then
		G.ACTIVE_MOD_UI = SMODS.Mods[args.mod]
		if G.ACTIVE_MOD_UI then
			label = G.ACTIVE_MOD_UI.name .. ": " .. label
		end
		if args.tallies then
			set_discover_tallies()
		end
	end
	local count
	if args.count then
		count = args.count(args.item)
	elseif args.tallies then
		count = G.DISCOVER_TALLIES[args.tallies]
	end
	local result = UIBox_button({
		button = id,
		label = { label },
		count = count,
		minw = 6,
		maxw = 6,
		id = id,
		colour = args.colour,
	})
	G.ACTIVE_MOD_UI = old_active_ui
	if args.tallies then
		set_discover_tallies()
	end
	return result
end
function Glossary.UI.collection_part_button(item)
	local definition = item.definition or Glossary.collection_part_buttons[item.type]
	if not definition then
		return
	end
	if type(definition) == "function" then
		return definition(item)
	end
	local id = definition.id and definition.id or "your_collection_" .. item.type
	local label = definition.label and definition.label(item) or localize("b_" .. item.type)
	local tallies
	if definition.tallies then
		tallies = definition.tallies
		if definition.tallies == true then
			tallies = item.type
		end
	end
	return Glossary.UI.simple_collection_part_button({
		id = id,
		label = label,
		tallies = tallies,
		colour = definition.colour,
		mod = item.mod,
		item = item,
	})
end
