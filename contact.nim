import json

var
  file: File
  dictionary: JsonNode
  config: JsonNode

#load config
discard open(file, "config.json")
config = parseJson(file.readAll())
close(file)

var language = config["last_language"].getStr()

# Ask for the game language
stdout.write("Enter language or language code. Press Enter for default",language,":")
var user_input=readLine(stdin)

for key in keys(config["language_specific"]):
  if user_input in to(config["language_specific"][key]["language_codes"],seq[string]):
    language = key

echo language
#load dictioanry
# discard open(file, "dictionaries/" & language & ".json")
# dictionary = parseJson(file.readAll())
# close(file)

# echo "Enter first letter:"
# user_input=readLine(stdin)

# # Print the loaded data
# echo dictionary

#Exiting
config["last_language"]= %* language
writeFile("config.json", $config)
