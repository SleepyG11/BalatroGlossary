if not next(SMODS.find_mod("Blindside")) then
	return
end

-- All of this works, but in Blindside not setted up a way to
-- display info about trims (seals) or upgrade (sticker)
-- when they're on base card it works tho

-- local function replace_with_blind(card)
-- 	if card.config.center_key == "c_base" then
-- 		local seal = card.seal and G.P_SEALS[card.seal]
-- 		if seal and seal.pools and seal.pools.bld_obj_enhancements then
-- 			card:set_ability("m_bld_flip", true, false)
-- 		elseif card.ability.bld_upgrade then
-- 			card:set_ability("m_bld_flip", true, false)
-- 		end
-- 	end
-- end

-- local old_centers_insert = Glossary.InfoSections.centers.insert
-- function Glossary.InfoSections.centers.insert(self, area, result, ...)
-- 	if result then
-- 		replace_with_blind(result)
-- 	end
-- 	return old_centers_insert(self, area, result, ...)
-- end

-- local old_centers_insert = Glossary.InfoSections.target_modifiers.insert
-- function Glossary.InfoSections.target_modifiers.insert(self, area, result, ...)
-- 	if result then
-- 		replace_with_blind(result)
-- 	end
-- 	return old_centers_insert(self, area, result, ...)
-- end
