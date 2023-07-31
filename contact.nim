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

var wordlist: seq[Word]
var old_wordlist: seq[Word]

for w in dictionary[letters]:
  wordlist.add(Word(word: w[1].getStr(), rank: w[0].getInt(), definitions: to(w[2],seq[string])))
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

#command cycle
while true:
  printWordlist(wordlist,words_per_page,page)
  echo "\e[1mWords starting with: ", letters
  stdout.write("Enter Command:>\e[0m")
  user_input=readLine(stdin)
  ## commands
  # page flipping
  if user_input[0]=='p':
    #parse
    if len(user_input)==1 or user_input[1]=='+':
      page+=1
    elif user_input[1]=='-':
      page-=1
    elif isDigit(user_input[1]):
      page=parseint(user_input[1..^1])
    #adust page
    if page<0:
      page+=(len(wordlist) div words_per_page)+1
    elif (page+1)*words_per_page>len(wordlist):
      page=page mod ((len(wordlist) div words_per_page)+1)
  #quit
  elif user_input[0]=='q':
    if len(user_input)>1 and user_input[1]=='!':
      discard
    else:
      break
  #help
  elif user_input[0]=='h':
    printHelpMessage(config)
  #add
  elif user_input[0]=='a':
    letters = letters & user_input.split(' ')[1]
    var new_wordlist: seq[Word]
    old_wordlist = newSeq[Word](0) #make a better old words structure better to allow further backtracking
    for word in wordlist:
      if len(word.word)>=len(letters) and word.word[0..len(letters)-1]==letters:
        new_wordlist.add(word)
      else:
        old_wordlist.add(word)
    wordlist=new_wordlist
  #back
  elif user_input[0]=='b':
    letters=letters[0..^2]
    for word in old_wordlist:
      if len(word.word)>=len(letters) and word.word[0..len(letters)-1]==letters:
        wordlist.add(word)
    #TODO add a sort here


#Exiting
if config["last_language"].getStr()!=language:
  config["last_language"]= %* language
  writeFile("config.json", $config)
