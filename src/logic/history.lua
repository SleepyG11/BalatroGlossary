Glossary.history = {}
Glossary.history.buffer = nil

function Glossary.history.can_move(dx)
	local history = type(G.OVERLAY_MENU) == "table" and G.OVERLAY_MENU.glossary_history
	return history and history[history.current_index + dx] ~= nil
end
function Glossary.history.move(dx)
	if not Glossary.history.can_move(dx) then
		return
	end
	local history = G.OVERLAY_MENU.glossary_history
	history.current_index = history.current_index + dx
	local entry = history[history.current_index]
	Glossary.keep_history = true
	Glossary.show_history_entry_info(entry)
	Glossary.keep_history = nil
end
function Glossary.history.get()
	if type(G.OVERLAY_MENU) ~= "table" or not G.OVERLAY_MENU.glossary_history then
		return {
			current_index = 0,
		}
	end
	return G.OVERLAY_MENU.glossary_history
end
function Glossary.history.add(context)
	if Glossary.keep_history then
		return
	end
	local history = Glossary.history.get()
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

function Glossary.history.save()
	Glossary.history.buffer = Glossary.history.get()
end
function Glossary.history.load()
	G.OVERLAY_MENU.glossary_history = Glossary.history.buffer
	Glossary.history.buffer = nil
end

function Glossary.show_history_entry_info(entry)
	Glossary.show_info(entry.target_type, entry.target, entry.source_type, entry.source)
end
