This is a script for the "contact" game. (Not as the gameboard but as a player/assistant)

### Table of Contents
- [Game Rules](#game-rules)
- [Usage](#usage)
- [Custom Languages](#custom-languages)
  - [Create 1 or more dictionaries](#create-1-or-more-dictionaries)
  - [Add the dictionary (and language) into config.json](#add-the-dictionary-and-language-into-configjson)
- [Citations](#citations)
- [TODOs](#todos)

# Game Rules

[Link To a Better Explanation](https://www.ludozofi.com/home/games/contact/#:~:text=Contact%20is%20a%20word%2Dguessing,asking%20questions%20to%20the%20wordmaster.)

You need 3 or more players.

One person (let's call him "warden") thinks of a word (the word has to be a valid noun. eg. `"apple"`) and annouces the first letter (eg.`"a"`).

Then the other people have to guess that word, they can do so in 2 ways.

A: They can do so by asking: "Is it `"ant"`?"

If they guess the word, then they win (the person will win only if the guessers give up).

B: One of the guessers can also think of a word (but not tell anyone) that starts with the same letter (eg. `"age`), and make a riddle about it: "Is it someting that is measured in years?"

Now the warden has to "defend" by solving the riddle and saying: "It is not `"age"`" (even if it isn't the word the riddler initially thought of, but it maches the description of the riddle, it would still be a valid defense for the warden.)

If the warden is having trouble solving the riddle, the other player can also try solving the riddle. If a player other than the riddler or warden thinks he has a solution for the riddle, that player should announce "Contact!" (as if he has a mental connection with the riddler) and he and the riddler start a 10 second countdown. The warden can try solving the riddle during that time period, but when the time is up, both the riddler and the guesser announce their asnwers/solutions for the riddle.

If the answers of the guesser and the riddler match, the warden fails to defend and has to give up the next letter (`"p"` in total `"ap"`.) However, if the answers of the guesser and the riddler are different, the warden has successfuly defended and doesn't have to give the next letter.

From here the game continues, but all wards that are being riddled have to start with the new first letters    `"ap"`.

The game continues, the warden gives up more letters as he fails to "defend" against riddles. Eventually the guessers either reveal all letters, guess the word, or give up.

Additional rules:
- If the riddle is based on knowledge the warden doesn't have, it is invalid.
- If the warden doesn't know the word riddled (never heard of it), the players can decide whether its considered fair to give up the next letter.
- Only nouns can be used in the game, 2 word nouns shouldn't be used.
- "obscure" words shoudln't be used. ("chlorofluorocarbons","homo sapiens" etc.)
- no repeating words
- The spelling of all words has to be correct.
- The players shouldn't use aids such as dictionaries (or this script), but the warden should doublecheck the spelling, to make sure he is giving the correct letters, or if he thinks the riddler spelled his own word incorrectly (in which case the riddle is invalid).

# Usage

# Custom Languages

If you want to add your own language, here is what you need to do (2 things):

## Create 1 or more dictionaries

In the `/dictionaries` folder, create a JSON file with the name of the language and fill it like this:

```nim
# language.json
{
  "a":[ # words starting with "a"
    [0,"apple",["a red fruit","a tech company"]], # [number,word,[definixtions]]
    [2,"area",["a region"]]
  ],
  "b":[ #words starting with "b"
    [1,"boat",["a small ship"]]
  ]
}
```

The number is the frequency rank of the word. 

The words are categorized based on the first letter to avoid doing the sort the first time. Just me doing premature optimization.

More instructions in `processor.ipynb`

## Add the dictionary (and language) into config.json

In order to make your language.dictionary selectable, you will have to put it into `config.json`. Open `config.json`.

```nim
{
  "language_specific"{
    "your_language"{
      "language_codes": ["RU", "ru", "rus", "russian"],
        "dictionaries": ["russian.json", "english.json"],
        "commands": {
            "quit": {
                "keys": ["в", "выйти"],
                "help": "Quits the script"
            },
            "help": {
                "keys": ["п", "помощь"],
                "help": "prints help message"
            },
            "add": {
                "keys": ["д", "добавиль"],
                "help": "adds the next letter"
            },
            "back": {
                "keys": ["о", "обратно"],
                "help": "Goes back one letter"
            },
            "undo": {
                "keys": ["u", "undo"],
                "help": "Undoes your last action"
            },
            "mark": {
                "keys": ["m", "mark"],
                "help": "Marks words as used"
            },
            "unmark": {
                "keys": ["um", "unmark"],
                "help": "Unmarks marked words"
            },
            "page": {
                "keys": ["с", "страница"],
                "help": "p+ p- Flip pages of the dicitonary"
            }
        }
    }
  }
}
```

`languege_codes` are the ways you call your language, usually the country code, lowercase lanugage name and codes in [ISO 639.1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes). Language codes are parsed in the order they appear in the config file, be carefull about duplicate language_codes.

`dictionaries` is a list of dicitonaries (files) in the `/dictionaries` folder that belong to this language. You can add multiple, the script will prompt you to select a dictionary from this list if there are multiple.

`commands` the script provides the option to type the commands in a different language so you don't have to switch keyboards all the time, you will have to make translations for all the commands. Translate only the "key":**"values"**, don't translate the "key"s. You can use the russain and german configurations as an example/template.

If you actually go so far as to make a custom dictionary or language, please make a pull request.

# Citations

For English dictionary:
- Wordlist: https://github.com/hackerb9/gwordlist
- Definitions: [Bird, Steven, Edward Loper and Ewan Klein (2009), Natural Language Processing with Python. O’Reilly Media Inc.](https://www.nltk.org) 
  - Princeton University "About WordNet." [WordNet](https://wordnet.princeton.edu/). Princeton University. 2010. 

For Russian dictionary:
- Wordlist: https://github.com/hingston/russian/blob/master/100000-russian-words.txt
- Definitions: https://github.com/Harrix/Russian-Nouns

# TODOs
- [ ] make commands from all languages work regardless
- [ ] change dictionaries to have all words in one list
- [ ] faster to parse dictionaries
- [ ] add more dictionaries to dictionaries
- [ ] add more languages
- [ ] add more commands
    