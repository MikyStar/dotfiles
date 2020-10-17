# VIM CheatScheet

# Default bindings 

## Working directory

:cd %:p:h -> Change the current directory to current file directory

## Browsing

Ctrl+W -> Enter window mode
Ctrl+W, HJKL -> Browse splits
Ctrl+W, R -> Rotate up/left
Ctrl+W, r -> Rotate down/right

Ctrl+ww -> browse throught windows ( nerdtree, splits ... )

Ctrl + g -> Displays infos on the position in the file at the bottom

```
:# -> Go to line #
#G -> Go to line #
#| -> Go to column #
```

gt -> to next tab
gT -> go to previous tab
{i}gt -> go to tab in position i

f{char} -> Move to next occurence of char
F{char} -> Move to next occurence of char backwards

'' -> Move to last position ( it's double single quote )

H -> Move to top of screen
M -> Move to middle of screen
L -> Move to bottom of screen

Ctrl+U -> Browse half screen up
Ctrl+D -> Browse half screen down

Ctrl+B -> Page up
Ctrl+F -> Page down

{ -> Move to previous blank line
} -> Move to next blank line

```
#z -> Make top of screen start at line #
```

## Replace & Search

Between lines
:#,#s/old/new/gc -> c = "Confirm"

:%s -> All lines of the file

Ctrl+r,"-> Paste current register to command

Using * on a word or a visual make it search for the next occurance

/\<i -> Search for words that starts with i
/i\> -> Search for words that ends with i

## Commands in Insert mode

esc+###+i+€$£+esc -> Insert ### times the string €$£

`When using a number for repeating a task a certain amount of time with a key that's binded to something can be resolve by pressing the ESC key after it, example 5+o+ESC -> Make take in consideration the number before and transforms the single line understood from the o binding to 5 new lines`

## Terminal

:term

Ctrl+w -> Switch terminal to VIM mode
---> N -> Enter normal mode and can browse through output of terminal for instance
---> i -> Go back to terminal mode

:! %<shell command> -> Execute a shell command
:silent !<command> -> Execute a shell commmand without the need to press enter at the end
:r !<command> -> Put the output of the command into the current buffer

## Windows

### Resizing

:res 60 -> 60 rows
:res +5
:vertical resize 50 -> 50 columns

### Splitting

:sp -> Split horizontally
:vsp -> Split vertically

Ctrl+W, R -> Swap splits

Ctrl+W, HJKL -> Browse between splits VIM like `Remapped to just Ctrl + HJKL` => 'Window browsing'

## Browse cursor positions

Ctrl + O -> backward
Ctrl + I -> forward

### Buffers

`List of opppened files`

:buffers -> List openned buffers
:bn -> buffer next
:bp -> buffer previous
:bd -> Delete buffer

## Registers

:reg -> List all of them

"#p -> Paste content of the # register
kyy -> Copy current line in register k
Kyw -> *Append* current word to register k

:WipeReg -> `Custom command` to delete all registers

### Specific registers :

. Last inserted text
: Last command
" Last register

@: -> Repeat last command
@@ -> Repeat again last command

## Marks

:marks -> List all marks

ma -> Put a marker named "a" at that position
'a -> Jump to mark "a"
d'a -> Delete from current to line to line on mark "a"
d{backtick}a -> Delete from current position to position on mark "a"

:delmarks! -> Delete all lowercase marks for the current buffer
:delmarks a -> Delete mark 'a'
:delmarks a-d -> Delete mark 'a, b, c, d'

## Changes

:changes -> List current changes
:e! -> Discard all changes

Ctrl + R -> Redo the previous undo through u

## Change case

~ -> Makes selected caracter switch case
3~ -> Makes 3 next caracters switch case
3w -> Makes 3 next words switch case

## Openning

:e -> Reloads current file
:e <path> Open or create file
:tabedit <path> -> Open file in new tab
:tabonly -> Close every tabs except the current one

:x -> Save and quit

## Recording

qa -> Starts recording in the register a
q -> Stop recording
@a -> Play register a

## The g 

gx -> Follow link under cursor
gm -> Go to the middle of the column

## Folding

zo → Open fold
Visual + zf → Fold selection
zf{ motion } -> Make a fold of the motion ( works with markers like zf'a will fold current line until mark)

[//]: ////////////////////////////////////////////////////////////

# Vimdiff

## Configure Git to use it

git config --global diff.tool vimdiff
git config --global difftool.prompt false
git config --global alias.d difftool

## Review Git changes

do → Get the content of the opposite line where the cursor is
dp → Push the content where the cursor is on the oposite line
]c → Next diff
[c → Previous diff

[//]: ////////////////////////////////////////////////////////////

# Plugins

## Tabulous

### Rename current tab

:TabulousRename <name>

## NerdTree

Ctrl+n to toggle

m -> Open context menu to do actions like append node, delete...
go -> Open next to NerdTree but keep focus in NerdTree
t -> Open in new Tab
T -> Opens silently
i -> Open in split view horizontal
s -> Open in split view vertical
R -> Reloads root directory
r -> Reloads current directory
O -> Expand recursively
P -> Jump to root
p -> Jump to parent
J -> Go to last child
a -> Append a node ( add / before the name and that's a folder )

## YouCompleteMe

:YcmCompleter +
  GoTo, etc. -> Go to include/declaration/definition 
  GetDoc -> View documentation comments for identifiers 
  GetType -> Type information for identifiers 
  FixIt -> Automatically fix certain errors 
  GoToReferences -> Reference finding 
  RefactorRename <new name> -> Renaming symbols 
  Format -> Code formatting 

## Git

### Vim as a mergetool

```sh
$ git mergetool # Open vim as a mergetool to handle conflict between a merge in two branchs
```

- LOCAL -> The file in the current branch
- BASE -> The file as it was before it was modified in both branches hence the conflict
- REMOTE -> The file as it is in the branch I'm merging into the current one

In the final merged file ( the view on the bottom ) go to a conflict and execute those commands to select what to keep
:diffg RE  -> Get from REMOTE
:diffg BA  -> Get from BASE
:diffg LO  -> Get from LOCAL


### GitGutter

:GitGutterLineHighlightsToggle -> Change background of new/changed lines => `Remapped to :Githl`

:GitGutterNextHunk -> Go to next hunk => `Remapped to :Gitnext`
:GitGutterPrevHunk -> Go to previous hunk => `Remapped to :Gitprev`

:GitGutterStageHunk -> Stage a hunk => `Remapped to :Gitstage`
:GitGutterUndoHunk -> Undo a staged hunk => `Remapped to :Gitunstage`

:GitGutterPreviewHunk -> See what has changed for that hunk

### Fugitive

:Gdiffsplit -> Make a split with hunks highlighted => `Remapped to :Gitsplit`

### Tsuquyomi

_TypeScript handling_

:TsuquyomiImport -> Import the file needed for the variable under the cursor

### Errors / Syntastic

:lopen -> List errors
:lnext / :lprevious -> Browse errors

:SyntasticToggleMode -> Toggle plugin
:SytasticSetLocList -> Populate the list of errors
:SyntasticCheck pylint  -> Run the select linter
:SyntasticReset -> Turn off all errors
:SyntasticInfo -> Display info about the linting of the current file

[//]: ////////////////////////////////////////////////////////////

# Others

:noh -> Clear highlighted stuff
:tabclose -> Close current tab
:messages -> Show vim messages
:map -> See how keys are mapped
:map key -> See what the bindings with key
