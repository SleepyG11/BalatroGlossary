Glossary.history = {}
Glossary.history.buffer = nil

function Glossary.history.can_move(dx)
	local history = type(G.GLOSSARY_OVERLAY_MENU) == "table" and G.GLOSSARY_OVERLAY_MENU.glossary_history
	return history and history[history.current_index + dx] ~= nil
end
function Glossary.history.move(dx)
	if not Glossary.history.can_move(dx) then
		return
	end
	local history = G.GLOSSARY_OVERLAY_MENU.glossary_history
	history.current_index = history.current_index + dx
	local entry = history[history.current_index]
	Glossary.keep_history = true
	Glossary.show_history_entry_info(entry)
	Glossary.keep_history = nil
end
function Glossary.history.get()
	if type(G.GLOSSARY_OVERLAY_MENU) ~= "table" or not G.GLOSSARY_OVERLAY_MENU.glossary_history then
		return {
			current_index = 0,
		}
	end
	return G.GLOSSARY_OVERLAY_MENU.glossary_history
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
	G.GLOSSARY_OVERLAY_MENU.glossary_history = Glossary.history.buffer
	Glossary.history.buffer = nil
end

function Glossary.show_history_entry_info(entry)
	Glossary.show_info(entry.target_type, entry.target, entry.source_type, entry.source)
end

local old_exit_menu = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(...)
	if G.GLOSSARY_OVERLAY_MENU then
		G.FUNCS.glossary_exit_overlay_menu()
	end
	old_exit_menu(...)
	G.ACTIVE_MOD_UI = nil
end

local old_overlay_menu = G.FUNCS.overlay_menu
function G.FUNCS.overlay_menu(...)
	if G.GLOSSARY_OVERLAY_MENU then
		G.FUNCS.glossary_exit_overlay_menu()
	end
	return old_overlay_menu(...)
end
