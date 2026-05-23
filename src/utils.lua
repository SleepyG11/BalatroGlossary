function Glossary.is_collection_card_junk(context)
	return context.target_type == "card"
		and (context.source_type ~= "card" or not context.source.playing_card)
		and context.target.config.center_key == "c_base"
		and (context.target.area and context.target.area.config.collection)
end

function Glossary.get_target_mod(target_type, target)
	if target_type == "back" then
		return target.mod
	elseif target_type == "card" then
		return target.config.center.mod
	elseif target_type == "tag" then
		return G.P_TAGS[target.key].mod
	end
	return nil
end

function Glossary.get_card_back_center(card, forced)
	local fallback = forced and G.P_CENTERS.b_red or nil
	if card.config.center and card.config.center.set == "Back" then
		return card.config.center
	end
	if card.glossary_back then
		return card.glossary_back.effect.center
	end
	if card.area and card.area == G.deck then
		return G.GAME.selected_back and G.GAME.selected_back.effect.center or fallback
	end
	if card.facing == "back" or forced then
		if type(card.back) == "string" then
			return G.GAME[card.back] and G.GAME[card.back].effect.center
		end
	end
	return fallback
end

function Glossary.safe_card_from_center(center_key, area)
	local card = SMODS.create_card({
		key = "c_base",
		front = false,
		area = area,
		bypass_discovery_center = true,
		bypass_discovery_ui = true,
		bypass_lock = true,
	})
	local success = pcall(function()
		card:set_ability(center_key, false, false)
	end)
	if success then
		return card
	else
		card:remove()
		return nil
	end
end
