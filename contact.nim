import json
import strutils
import std/unicode

#load config
var config = parseFile("config.json")
let words_per_page = config["words_per_page"].getInt()

#Get for the language
proc getLanguage(config: JsonNode): JsonNode =
  var last_language = config["last_language"].getStr()
  var language: JsonNode

  #text
  echo "\e[1mAvailable Languages\e[0m" #TODO make the language codes presence a bit more clear
  for key in keys(config["languages"]):
    echo "- ",config["languages"][key]["native_name"].getStr()
  stdout.write("Choose language: default (",last_language,"):")

  #parse language
  let user_input=readLine(stdin)
  for key in keys(config["languages"]):
    if user_input in to(config["languages"][key]["language_codes"],seq[string]):
      language = parseFile("i18n/" & config["languages"][key]["i18n"].getStr())
      break
  if isNil(language):
    language = parseFile("i18n/" & config["languages"][last_language]["i18n"].getStr())
  echo language["messages"]["selected_language"].getStr()
  return language

var language = getLanguage(config)

#Choose dictionary
var dictionary_choices = to(language["dictionaries"],seq[string])
var dictionary_file_name: string
if len(dictionary_choices)==1:
  dictionary_file_name=dictionary_choices[0]
elif len(dictionary_choices)>1:
  echo language["messages"]["available_dictionaries"].getStr()
  for i,choice in dictionary_choices:
    echo i,"|",choice
  stdout.write(language["messages"]["enter_choice_number"].getStr())
  let user_input=readLine(stdin)
  if user_input=="":
    dictionary_file_name=dictionary_choices[0]
  else:
    dictionary_file_name=dictionary_choices[parseInt(user_input)]

proc printHelpMessage(language:JsonNode) =
  echo "\e[1m",language["messages"]["available_commands"].getStr(),"\e[0m"
  let commands = language["commands"]
  for command in keys(commands):
    echo commands[command]["keys"],"-",commands[command]["help"]

printHelpMessage(language)
#load dictioanry
echo language["messages"]["loading_dictionary"].getStr(), dictionary_file_name
var dictionary: JsonNode = parseFile("dictionaries/" & dictionary_file_name)

#Start
stdout.write(language["messages"]["enter_first_letter"].getStr())
var user_input=readLine(stdin).toLower()
var letters: seq[Rune] = @[user_input.toRunes()[0]]
var page: int = 0;

type Word = object
    rank: int
    word: string
    definitions: seq[string]

var main_wordlist: seq[seq[Word]] = @[newSeq[Word](0)]
template current_wordlist: var seq[Word] = main_wordlist[^1]

for w in dictionary[$letters]:
  main_wordlist[0].add(Word(word: w[1].getStr(), rank: w[0].getInt(), definitions: to(w[2],seq[string])))
dictionary.`=destroy`()

proc printWordlist(wordlist: seq[Word],words_per_page:int=50,page_n: int = 0) =
  var i = min((page_n+1)*words_per_page,len(wordlist))-1
  let end_i = i-words_per_page
  while end_i<i and -1<i:
    var word=wordlist[i]
    echo i, " - \e[1m", word.word, "\e[0m"
    for d in word.definitions:
      echo "  |" & d
    i-=1

#command parser
#make command index
var command_index: seq[tuple[commandText: string, comandID: string]]
for command in keys(language["commands"]):
  for text in language["commands"][command]["keys"]:
    command_index.add((text.getStr(), command))
#command lookup
proc commandParser(user_input: string, command_index: seq[tuple[commandText: string, comandID: string]]): seq[string] =
  let split_input=user_input.split(' ')
  for command_tup in command_index:
    if len(command_tup.commandText)<=len(split_input[0]):
      if command_tup.commandText==split_input[0]:
        if len(split_input)==1:
          return @[command_tup.comandID,""]
        else:
          return @[command_tup.comandID,split_input[1]]

#command cycle
var dont_print_wordlist: bool = false
let words_starting_with_message=language["messages"]["words_starting_with"].getStr()
let enter_command_message=language["messages"]["enter_command"].getStr()
while true:
  if not dont_print_wordlist:
    printWordlist(current_wordlist,words_per_page,page)
    echo "\e[1m",words_starting_with_message, letters,"\e[0m"
    dont_print_wordlist=false
  stdout.write("\e[1m",enter_command_message,"\e[0m")
  var command=commandParser(readLine(stdin),command_index)
  ## commands
  # page flipping
  if command[0]=="page":
    #parse
    if len(command[1])==0 or command[1][0]=='+':
      page+=1
    elif command[1][0]=='-':
      page-=1
    elif isDigit(command[1][0]):
      page=parseint(command[1])
    #adust page
    if page<0:
      page+=(len(current_wordlist) div words_per_page)+1
    elif (page+1)*words_per_page>len(current_wordlist):
      page=page mod ((len(current_wordlist) div words_per_page)+1)
  #quit
  elif command[0]=="quit":
    break
  #help
  elif command[0]=="help":
    printHelpMessage(language)
    dont_print_wordlist=true
  #add
  elif command[0]=="add":
    letters = letters & command[1].toLower().toRunes()
    let str_letters: string = $letters
    var new_wordlist: seq[Word]
    for word in current_wordlist:
      if len(word.word)>=len(str_letters) and word.word[0..len(str_letters)-1].toLower()==str_letters:
        new_wordlist.add(word)
    main_wordlist.add(new_wordlist)
    page=0
  #back
  elif command[0]=="remove":
    letters=letters[0..^2]
    main_wordlist.delete(len(main_wordlist)-1)
    page=0

#Exiting
if config["last_language"].getStr()!=language["language_name"].getStr():
  config["last_language"]= %* language["language_name"].getStr()
  writeFile("config.json", $config)
