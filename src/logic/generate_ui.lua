function Glossary.request_processing(context)
	Glossary.G.processing_request = {
		context = context,
		started = false,
		can_finish = false,
		finished = false,
	}
end
function Glossary.clear_processing_request()
	Glossary.G.processing_request = nil
end

local old_generate_ui = generate_card_ui
function generate_card_ui(...)
	local a, b, c, d, e, f = old_generate_ui(...)
	if Glossary.G.processing_request and Glossary.G.processing_request.can_finish then
		Glossary.G.processing_request.can_finish = false
		Glossary.G.processing_request.finished = true
		Glossary.after_process_info_queue(Glossary.G.processing_request.context)
	end
	return a, b, c, d, e, f
end
