import json
import  strutils

#load config
var config = parseFile("config.json")
let words_per_page = config["words_per_page"].getInt()

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
  echo "Available dictionaries:"
  for i,choice in dictionary_choices:
    echo i,"|",choice
  stdout.write("Enter number, (defualt 0):")
  let user_input=readLine(stdin)
  if user_input=="":
    dictionary_file_name=dictionary_choices[0]
  else:
    dictionary_file_name=dictionary_choices[parseInt(user_input)]
  
echo "Loading dictionary: ", dictionary_file_name

proc printHelpMessage(language_specific:JsonNode) =
  echo "\e[1mCommands:\e[0m"
  let commands = language_specific["commands"]
  for command in keys(commands):
    echo commands[command]["keys"],"-",commands[command]["help"]

printHelpMessage(config["language_specific"][language])
#load dictioanry
var dictionary = parseFile("dictionaries/" & dictionary_file_name)

#Start
stdout.write("Enter first letter:")
var user_input=readLine(stdin)
var letters: string = $user_input[0]
var page: int = 0;

type Word = object
    rank: int
    word: string
    definitions: seq[string]

var main_wordlist: seq[seq[Word]] = @[@[]]
template current_wordlist: var seq[Word] = main_wordlist[^1]
# var action_log: seq[string]

for w in dictionary[letters]:
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
for command in keys(config["language_specific"][language]["commands"]):
  for text in config["language_specific"][language]["commands"][command]["keys"]:
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
while true:
  printWordlist(current_wordlist,words_per_page,page)
  echo "\e[1mWords starting with: ", letters
  stdout.write("Enter Command:>\e[0m")
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
    if len(command[1])>1 and command[1][0]=='!':
      discard
    else:
      break
  #help
  elif command[0]=="help":
    printHelpMessage(config["language_specific"][language])
  #add
  elif command[0]=="add":
    letters = letters & command[1]
    var new_wordlist: seq[Word]
    for word in current_wordlist:
      if len(word.word)>=len(letters) and word.word[0..len(letters)-1]==letters:
        new_wordlist.add(word)
    main_wordlist.add(new_wordlist)
    page=0
  #back
  elif command[0]=="back":
    letters=letters[0..^2]
    main_wordlist.delete(len(main_wordlist)-1)
    page=0
  #log
  # action_log.add()

#Exiting
if config["last_language"].getStr()!=language:
  config["last_language"]= %* language
  writeFile("config.json", $config)
