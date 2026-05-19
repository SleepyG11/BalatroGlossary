Glossary.load_file("src/utils.lua")

Glossary.load_file("src/api/index.lua")
Glossary.load_file("src/logic/index.lua")

Glossary.load_file("src/ui/index.lua")

Glossary.load_file("src/definitions/index.lua")

--

local old_r_press = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(...)
	old_r_press(self, ...)
	local hovered_target = self.hovering.target
	if hovered_target then
		if hovered_target.is and hovered_target:is(Card) then
			hovered_target:stop_hover()
			Glossary.show_card_info(hovered_target)
		elseif hovered_target.config and hovered_target.config.tag then
			hovered_target:stop_hover()
			Glossary.show_tag_info(hovered_target.config.tag)
		elseif
			hovered_target.config
			and hovered_target.config.ref_table
			and hovered_target.config.ref_table.config
			and hovered_target.config.ref_table.config.tag
		then
			hovered_target:stop_hover()
			Glossary.show_tag_info(hovered_target.config.ref_table.config.tag)
		end
	end
end
