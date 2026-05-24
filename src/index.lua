Glossary.G = {}

Glossary.load_file("src/utils.lua")
Glossary.load_file("src/logic/index.lua")
Glossary.load_file("src/api/index.lua")
Glossary.load_file("src/ui/index.lua")

Glossary.load_directory("src/definitions")
Glossary.load_directory("src/definitions/compatibility", true)
