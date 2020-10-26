# VIM CheatScheet

# Default bindings 

## Working directory

:cd %:p:h -> Change the current directory to current file directory

:f -> Get file path

## Browsing

Ctrl+W -> Enter window mode
<br />
Ctrl+W, HJKL -> Browse splits
<br />
Ctrl+W, R -> Rotate up/left
<br />
Ctrl+W, r -> Rotate down/right
<br />
<br />
Ctrl+ww -> browse throught windows ( nerdtree, splits ... )
<br />
Ctrl + g -> Displays infos on the position in the file at the bottom

```
:# -> Go to line #
#G -> Go to line #
#| -> Go to column #
```

gt -> to next tab
<br />
gT -> go to previous tab
<br />
{i}gt -> go to tab in position i
<br />
<br />
f{char} -> Move to next occurence of char
<br />
F{char} -> Move to next occurence of char backwards
<br />
<br />
'' -> Move to last position ( it's double single quote )
<br />

H -> Move to top of screen
<br />
M -> Move to middle of screen
<br />
L -> Move to bottom of screen
<br />
<br />
Ctrl+U -> Browse half screen up
<br />
Ctrl+D -> Browse half screen down
<br />
<br />
Ctrl+B -> Page up
<br />
Ctrl+F -> Page down
<br />
<br />

{ -> Move to previous blank line
<br />
} -> Move to next blank line
<br />

```
#z -> Make top of screen start at line #
```

## Replace & Search

Between lines
<br />
:#,#s/old/new/gc -> c = "Confirm"
<br />
<br />

:%s -> All lines of the file

Ctrl+r,"-> Paste current register to command

Using * on a word or a visual make it search for the next occurance

### With FZF + fd + Rg

Ctrl + p -> mapped to ':Files .' => FuzzyFinder to browse files

Ctrl + f -> mapped to ':Rg' => Search for string ; prefix the string with ' for exact match

```
/\<i -> Search for words that starts with i
/i\> -> Search for words that ends with i
```

## Commands in Insert mode

esc+###+i+€$£+esc -> Insert ### times the string €$£

`When using a number for repeating a task a certain amount of time with a key that's binded to something can be resolve by pressing the ESC key after it, example 5+o+ESC -> Make take in consideration the number before and transforms the single line understood from the o binding to 5 new lines`

## Terminal

:term

Ctrl+w -> Switch terminal to VIM mode
<br />
---> N -> Enter normal mode and can browse through output of terminal for instance
<br />
---> i -> Go back to terminal mode
<br />

:! %<shell command> -> Execute a shell command
<br />
:silent !<command> -> Execute a shell commmand without the need to press enter at the end
<br />
:r !<command> -> Put the output of the command into the current buffer
<br />

## Windows

### Resizing

:res 60 -> 60 rows
<br />
:res +5
<br />
:vertical resize 50 -> 50 columns
<br />

### Splitting

:sp -> Split horizontally
<br />
:vsp -> Split vertically

Ctrl+W, R -> Swap splits

Ctrl+W, HJKL -> Browse between splits VIM like `Remapped to just Ctrl + HJKL` => 'Window browsing'

:only -> Keep only current pane

## Browse cursor positions

Ctrl + O -> backward
<br />
Ctrl + I -> forward

### Buffers

`List of opppened files`

:buffers -> List openned buffers
<br />
:bn -> buffer next
<br />
:bp -> buffer previous
<br />
:bd -> Delete buffer
<br />
:tab split -> Open buffer in a new tab

## Registers

:reg -> List all of them

"#p -> Paste content of the # register
<br />
kyy -> Copy current line in register k
<br />
Kyw -> *Append* current word to register k

:WipeReg -> `Custom command` to delete all registers

### Specific registers :

. Last inserted text
<br />
: Last command
<br />
" Last register

@: -> Repeat last command
<br />
@@ -> Repeat again last command

## Marks

:marks -> List all marks

ma -> Put a marker named "a" at that position
<br />
'a -> Jump to mark "a"
<br />
d'a -> Delete from current to line to line on mark "a"
<br />
d{backtick}a -> Delete from current position to position on mark "a"

:delmarks! -> Delete all lowercase marks for the current buffer
<br />
:delmarks a -> Delete mark 'a'
<br />
:delmarks a-d -> Delete mark 'a, b, c, d'

## Changes

:changes -> List current changes
<br />
:e! -> Discard all changes

Ctrl + R -> Redo the previous undo through u

## Change case

~ -> Makes selected caracter switch case
<br />
3~ -> Makes 3 next caracters switch case
<br />
3w -> Makes 3 next words switch case

## Openning

:e -> Reloads current file
<br />
:e <path> Open or create file
<br />
:tabedit <path> -> Open file in new tab
<br />
:tabonly -> Close every tabs except the current one

:x -> Save and quit

## Recording

qa -> Starts recording in the register a
<br />
q -> Stop recording
br />
@a -> Play register a

## The g 

gx -> Follow link under cursor
<br />
gm -> Go to the middle of the column

## Folding

zo → Open fold
<br />
Visual + zf → Fold selection
<br />
zf{ motion } -> Make a fold of the motion ( works with markers like zf'a will fold current line until mark)

[//]: ////////////////////////////////////////////////////////////

# Vimdiff

## Configure Git to use it

git config --global diff.tool vimdiff
<br />
git config --global difftool.prompt false
<br />
git config --global alias.d difftool

## Review Git changes

do → Get the content of the opposite line where the cursor is
<br />
dp → Push the content where the cursor is on the oposite line
<br />
]c → Next diff
<br />
[c → Previous diff

-----
-----

# Plugins

## Tabulous

### Rename current tab

:TabulousRename <name>

## NerdTree

Ctrl+n to toggle

m -> Open context menu to do actions like append node, delete...
<br />
o -> Open file in previous window `OR` Expand directory
<br />
go -> Open next to NerdTree but keep focus in NerdTree
<br />
t -> Open in new Tab
<br />
T -> Opens silently
<br />
i -> Open in split view horizontal
<br />
s -> Open in split view vertical
<br />
R -> Reloads root directory
<br />
r -> Reloads current directory
<br />
O -> Expand recursively
<br />
P -> Jump to root
<br />
p -> Jump to parent
<br />
J -> Go to last child
<br />
a -> Append a node ( add / before the name and that's a folder )

## YouCompleteMe

:YcmCompleter +
<br />
  GoTo, etc. -> Go to include/declaration/definition 
<br />
  GetDoc -> View documentation comments for identifiers 
<br />
  GetType -> Type information for identifiers 
<br />
  FixIt -> Automatically fix certain errors 
<br />
  GoToReferences -> Reference finding 
<br />
  RefactorRename <new name> -> Renaming symbols 
<br />
  Format -> Code formatting 

## The Silver Searcher ( ag )

```
:Ag <pattern> # Use Esc-a if window won't close
```

## Git

### Vim as a mergetool

```sh
$ git mergetool # Open vim as a mergetool to handle conflict between a merge in two branchs
```

- LOCAL -> The file in the current branch
<br />
- BASE -> The file as it was before it was modified in both branches hence the conflict
<br />
- REMOTE -> The file as it is in the branch I'm merging into the current one

In the final merged file ( the view on the bottom ) go to a conflict and execute those commands to select what to keep
<br />
:diffg RE  -> Get from REMOTE
<br />
:diffg BA  -> Get from BASE
<br />
:diffg LO  -> Get from LOCAL


### GitGutter

:GitGutterLineHighlightsToggle -> Change background of new/changed lines => `Remapped to :Githl`

:GitGutterNextHunk -> Go to next hunk => `Remapped to :Gitnext`
<br />
:GitGutterPrevHunk -> Go to previous hunk => `Remapped to :Gitprev`

:GitGutterStageHunk -> Stage a hunk => `Remapped to :Gitstage`
<br />
:GitGutterUndoHunk -> Undo a staged hunk => `Remapped to :Gitunstage`

:GitGutterPreviewHunk -> See what has changed for that hunk

### Fugitive

:Gdiffsplit -> Make a split with hunks highlighted => `Remapped to :Gitsplit`
<br />
`\[c` -> Previous hunk
<br />
`\]c` -> Next hunk
<br />
`<leader>hp` -> Preview hunk
<br />
`<leader>hs` -> Stage hunk
<br />
`<leader>hu` -> Undo hank
<br />
-> _Use :diffoff then :q to exit_

### Tsuquyomi

_TypeScript handling_

:TsuquyomiImport -> Import the file needed for the variable under the cursor

### Errors / Syntastic

:lopen -> List errors
<br />
:lnext / :lprevious -> Browse errors

:SyntasticToggleMode -> Toggle plugin
<br />
:SytasticSetLocList -> Populate the list of errors
<br />
:SyntasticCheck pylint  -> Run the select linter
<br />
:SyntasticReset -> Turn off all errors
<br />
:SyntasticInfo -> Display info about the linting of the current file

-----

### VimSpector ( debugger )



-----
-----

# Others

:noh -> Clear highlighted stuff
<br />
:tabclose -> Close current tab
<br />
:messages -> Show vim messages
<br />
:map -> See how keys are mapped
<br />
:map key -> See what the bindings with key
