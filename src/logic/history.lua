Glossary.history_buffer = nil

function Glossary.can_move_history(dx)
	local history = type(G.OVERLAY_MENU) == "table" and G.OVERLAY_MENU.glossary_history
	return history and history[history.current_index + dx] ~= nil
end
function Glossary.move_history(dx)
	if not Glossary.can_move_history(dx) then
		return
	end
	local history = G.OVERLAY_MENU.glossary_history
	history.current_index = history.current_index + dx
	local entry = history[history.current_index]
	Glossary.keep_history = true
	Glossary.show_history_entry_info(entry)
	Glossary.keep_history = nil
end
function Glossary.get_history()
	if type(G.OVERLAY_MENU) ~= "table" or not G.OVERLAY_MENU.glossary_history then
		return {
			current_index = 0,
		}
	end
	return G.OVERLAY_MENU.glossary_history
end
function Glossary.add_to_history(context)
	if Glossary.keep_history then
		return
	end
	local history = Glossary.get_history()
	for i = history.current_index + 1, #history do
		history[i] = nil
	end
	table.insert(history, {
		target_type = context.target_type,
		target = context.target,
		source_type = context.source_type,
		source = context.source,
	})
	history.current_index = #history
end

function Glossary.save_history()
	Glossary.history_buffer = Glossary.get_history()
end
function Glossary.load_history()
	G.OVERLAY_MENU.glossary_history = Glossary.history_buffer
	Glossary.history_buffer = nil
end

function Glossary.show_history_entry_info(entry)
	Glossary.show_info(entry.target_type, entry.target, entry.source_type, entry.source)
end
