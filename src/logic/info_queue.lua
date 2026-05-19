function Glossary.pre_process_info_queue(context)
	if
		context.target_type == "card"
		and context.source.config.center_key ~= "c_base"
		and (context.source.config.card.value or context.source.config.card.suit)
	then
		table.insert(context.info_queue, 1, context.source.config.center)
	end
end
function Glossary.post_process_info_queue(context) end

function Glossary.process_info_queue(context)
	context.extra = context.extra or {}
	context.info_queue = context.info_queue or {}

	Glossary.pre_process_info_queue(context)

	local i = 1
	while i <= #context.info_queue do
		local filtered = false
		local entry = context.info_queue[i]

		if entry then
			for _, filter in ipairs(Glossary.InfoQueueFiltersPool) do
				context.entry = entry
				local result = filter:func(context)
				if result then
					table.remove(context.info_queue, i)
					filtered = true
					break
				end
			end
		end

		if not filtered then
			i = i + 1
		end
	end

	Glossary.post_process_info_queue(context)
end
