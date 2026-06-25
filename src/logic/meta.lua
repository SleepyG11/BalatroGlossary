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

function Glossary.get_meta(item_type, item)
	local item_meta = item.glossary_meta
	local global_meta = (Glossary.meta[item_type] or {})[item.key] or {}
	return item_meta or global_meta, item_meta, global_meta
end
function Glossary.get_meta_field(item_type, item, field)
	local _, item_meta, global_meta = Glossary.get_meta(item_type, item)
	return item_meta and item_meta[field] or global_meta[field]
end

---

function Glossary.process_meta_collection_parts(item_type, item)
	local definition = Glossary.get_meta_field(item_type, item, "collection_parts")
	if definition then
		for _, _item in ipairs(definition) do
			Glossary.insert("collection_parts", function()
				return _item
			end)
		end
	end
end
function Glossary.process_meta_poker_hands(item_type, item)
	local definition = Glossary.get_meta_field(item_type, item, "poker_hands")
	if definition then
		for _, _item in ipairs(definition) do
			Glossary.insert("poker_hands", function()
				return _item
			end)
		end
	end
end

---

function Glossary.process_meta(item_type, item)
	Glossary.process_meta_collection_parts(item_type, item)
	Glossary.process_meta_poker_hands(item_type, item)
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
