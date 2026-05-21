function Glossary.insert(key, func) end
function Glossary.specify_mod(mod) end

function Glossary.new_info_queue_context(target_type, target, source_type, source)
	local sections = {}
	function Glossary.insert(key, func)
		if not sections[key] then
			sections[key] = Glossary.InfoSections[key]:create()
		end
		local result = func(sections[key])
		if result then
			Glossary.InfoSections[key]:insert(sections[key], result)
			return true
		end
		return false
	end
	local context = {
		target_type = target_type,
		target = target,
		source_type = source_type,
		source = source,
		sections = sections,
		info_queue = {},
		extra = {},
	}
	function Glossary.specify_mod(mod)
		context.mod = mod
	end
	return context
end

--

function Glossary.before_process_info_queue(context)
	context.info_queue = context.info_queue or {}
	context.extra = SMODS.merge_defaults(context.extra or {}, {
		processed_card_modifiers = {},
	})

	context.before = true
	context.stage = "before"
	local processors = Glossary.get_processors("before")
	for _, processor in ipairs(processors) do
		processor:func(context)
	end
	context.before = nil
	context.stage = nil
end
function Glossary.individual_process_info_queue(context)
	context.individual = true
	context.stage = "individual"
	local processors = Glossary.get_processors("individual")
	local i = 1
	while i <= #context.info_queue do
		local filtered = false
		local entry = context.info_queue[i]

		if entry then
			context.entry = entry
			for _, processor in ipairs(processors) do
				local result = processor:func(context)
				if result then
					table.remove(context.info_queue, i)
					filtered = true
					break
				end
			end
			context.entry = nil
		end

		if not filtered then
			i = i + 1
		end
	end
	context.individual = nil
	context.stage = nil
end
function Glossary.after_process_info_queue(context)
	context.after = true
	context.stage = "after"
	local processors = Glossary.get_processors("after")
	for _, processor in ipairs(processors) do
		processor:func(context)
	end
	context.after = nil
	context.stage = nil
end
