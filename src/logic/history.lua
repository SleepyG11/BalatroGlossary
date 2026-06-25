Glossary.history = {}
Glossary.history.buffer = nil
Glossary.history.external_data = nil

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
	Glossary.history.keep = true
	Glossary.show_history_entry_info(entry)
	Glossary.history.keep = nil
end
function Glossary.history.get()
	if type(G.GLOSSARY_OVERLAY_MENU) ~= "table" or not G.GLOSSARY_OVERLAY_MENU.glossary_history then
		return {
			current_index = 0,
		}
	end
	return G.GLOSSARY_OVERLAY_MENU.glossary_history
end
function Glossary.history.get_current()
	local history = Glossary.history.get()
	return history[history.current_index]
end
function Glossary.history.add(context)
	if Glossary.history.keep then
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

--

function Glossary.history.save_external(target_back_funcs)
	local history = Glossary.history.get()
	local entry = history and history[history.current_index]
	if not entry then
		Glossary.history.external_data = nil
		return
	end
	Glossary.history.external_data = {
		history = history,
		entry = entry,
		target_back_funcs = target_back_funcs or {},
	}
end
function Glossary.history.has_external()
	return Glossary.history.external_data and Glossary.history.external_data.entry and true or false
end
function Glossary.history.load_external()
	local saved = Glossary.history.external_data
	Glossary.history.external_data = nil
	G.FUNCS.exit_overlay_menu()
	if not (saved and saved.entry) then
		return
	end
	Glossary.history.keep = true
	Glossary.show_history_entry_info(saved.entry)
	Glossary.history.keep = nil
	if saved.history and G.GLOSSARY_OVERLAY_MENU then
		G.GLOSSARY_OVERLAY_MENU.glossary_history = saved.history
	end
end

--

function Glossary.show_history_entry_info(entry)
	Glossary.show_info(entry.target_type, entry.target, entry.source_type, entry.source)
end
function G.FUNCS.glossary_load_external_history()
	Glossary.history.load_external()
end

--

local old_exit_menu = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(...)
	Glossary.history.external_data = nil
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

local old_gen_opts = create_UIBox_generic_options
function create_UIBox_generic_options(args, ...)
	if args and args.back_func then
		local external = Glossary.history.external_data
		if external and external.target_back_funcs[args.back_func] then
			args.back_func = "glossary_load_external_history"
		end
	end
	return old_gen_opts(args, ...)
end
