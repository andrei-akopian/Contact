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

In the dictionaries folder, create a JSON file with the name of the language and fill it like this:

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

In order to make your language selectable, you will have to put it into configs. If you are adding a custom dictionary or editing it.

```nim

```

# Citations

For English dictionary:
- Wordlist: https://github.com/hackerb9/gwordlist
- Definitions: [Bird, Steven, Edward Loper and Ewan Klein (2009), Natural Language Processing with Python. O’Reilly Media Inc.](https://www.nltk.org) 
  - Princeton University "About WordNet." [WordNet](https://wordnet.princeton.edu/). Princeton University. 2010. 

# TODOs
- [ ] make commands from all languages work regardless
- [ ] change dictionaries to have all words in one list
- [ ] add more dictionaries to dictionaries
- [ ] add more languages
- [ ] add more commands
    