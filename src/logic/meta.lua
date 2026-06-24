Glossary.meta = {}

function Glossary.add_meta(type_or_data, ...)
	if type(type_or_data) == "string" then
		if not Glossary.meta[type_or_data] then
			Glossary.meta[type_or_data] = {}
		end
		Glossary.table_merge_with_arrays(Glossary.meta[type_or_data], ...)
	else
		Glossary.table_merge_with_arrays(Glossary.meta, ...)
	end
end

---

function Glossary.process_meta_collection_parts(from_type, from)
	local definition = from.glossary_meta and from.glossary_meta.collection_parts
	if not definition then
		definition = ((Glossary.meta[from_type] or {})[from.key] or {}).collection_parts
	end
	if definition then
		for _, item in ipairs(definition) do
			Glossary.insert("collection_parts", function(nodes)
				return item
			end)
		end
	end
end
function Glossary.process_meta_poker_hands(from_type, from)
	local definition = from.glossary_meta and from.glossary_meta.poker_hands
	if not definition then
		definition = ((Glossary.meta[from_type] or {})[from.key] or {}).poker_hands
	end
	if definition then
		for _, item in ipairs(definition) do
			Glossary.insert("poker_hands", function(nodes)
				return item
			end)
		end
	end
end

---

function Glossary.process_meta(from_type, from)
	Glossary.process_meta_collection_parts(from_type, from)
	Glossary.process_meta_poker_hands(from_type, from)
end

---

local old_localize = localize
function localize(arg1, arg2, ...)
	if arg2 == "poker_hands" and Glossary.processing.current_request then
		Glossary.insert("poker_hands", function(nodes)
			return arg1
		end)
	end
	return old_localize(arg1, arg2, ...)
end
