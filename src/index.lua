Glossary.G = {}

Glossary.load_file("src/utils.lua")
Glossary.load_file("src/logic/index.lua")
Glossary.load_file("src/api/index.lua")
Glossary.load_file("src/ui/index.lua")

Glossary.load_directory("src/definitions")
Glossary.load_directory("src/definitions/compatibility", true)

--

function Glossary.open(target)
	if not target or target.glossary_ignore then
		return false
	end
	-- Deck when there's no cards
	if target == G.deck then
		target:stop_hover()
		Glossary.show_back_info(G.GAME.selected_back.effect.center, "area", G.deck)
		return true
	-- Any card
	elseif target.is and target:is(Card) then
		-- Special case for card in hand
		if target.area and target.area == G.hand and not Glossary.cc.allow_trigger_in_hand then
			return
		end
		target:stop_hover()
		Glossary.show_card_info(target, "card", target)
		return true
	-- Skip tag sprite
	elseif target.config and target.config.tag then
		target:stop_hover()
		Glossary.show_tag_info(target.config.tag, "tag", target.config.tag)
		return true
	-- Skip tag sprite in blind select or run info
	elseif
		target.config
		and target.config.ref_table
		and target.config.ref_table.config
		and target.config.ref_table.config.tag
	then
		target:stop_hover()
		Glossary.show_tag_info(target.config.ref_table.config.tag, "tag", target.config.ref_table.config.tag)
		return true
	end
	return false
end
