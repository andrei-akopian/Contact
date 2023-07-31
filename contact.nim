import json
import  strutils

#load config
var config = parseFile("config.json")

#Get for the language
proc getLanguage(config: JsonNode): string =
  var language = config["last_language"].getStr()
  stdout.write("Enter language or language code. Press Enter for default (",language,"):")
  let user_input=readLine(stdin)
  for key in keys(config["language_specific"]):
    if user_input in to(config["language_specific"][key]["language_codes"],seq[string]):
      language = key
  echo "Selected language:",language
  return language

var language = getLanguage(config)

#Choose dictionary
var dictionary_choices = to(config["language_specific"][language]["dictionaries"],seq[string])
var dictionary_file_name: string
if len(dictionary_choices)==1:
  dictionary_file_name=dictionary_choices[0]
elif len(dictionary_choices)>1:
  echo "\nAvailable dictionaries:"
  for i,choice in dictionary_choices:
    echo i,"|",choice
  stdout.write("Enter number, (defualt 0):")
  let user_input=readLine(stdin)
  if user_input=="":
    dictionary_file_name=dictionary_choices[0]
  else:
    dictionary_file_name=dictionary_choices[parseInt(user_input)]
  
echo "Using dictionary: ", dictionary_file_name

#load dictioanry
var dictionary = parseFile("dictionaries/" & dictionary_file_name)

#Start
stdout.write("Enter first letter:")
let user_input=readLine(stdin)
var letters: string = $user_input[0]

type Word = object
    rank: int
    word: string
    definitions: seq[string]

var wordlist: seq[Word]

for w in dictionary[letters]:
  wordlist.add(Word(word: w[1].getStr(), rank: w[0].getInt(), definitions: to(w[2],seq[string])))

proc printWordlist(wordlist: seq[Word]) =
  for i,word in wordlist:
    echo i, " - \e[1m", word.word, "\e[0m"
    for d in word.definitions:
      echo "  |" & d

printWordlist(wordlist)

#Exiting
if config["last_language"].getStr()!=language:
  config["last_language"]= %* language
  writeFile("config.json", $config)
