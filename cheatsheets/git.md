# Git

## References

**HEAD** -> Local current position

origin -> The remote URL, hence a reference to the Git remote host

<position>~ -> Ancestor ~3 or 3 times ~ -> 3 commits before

<commit sha>^ -> Parent n°1 commit

## Branches

```sh
git branch -a # ls all branches

git checkout -b [name_of_your_new_branch] # Switch to branch

git push -u origin [name of this new branch] # Pushing it to origin

git branch -d <branch> # Delete ( actually not really )
```

## Index area

```sh
git status -s # Short status

git commit -am "Message" # Add all and commit with message

###

git add -p <file> # 'Patch' -> Start hunk manual staging
# 'y' / 'n' -> stage / not stage
# 's' option will split the hunk if he's too big 

git add -i # Interactive mode to have a menu for actions then selecting files, diff ...

git reset <commit n°, optional> <file> # Unstage file
git reset # Unstage all files

###

git checkout -- <file> # Discard changes on file
git checkout -- . # Discard all changes on '.' location
```

## Merge

```sh
# Go to the branch where you want the other branch to be merged in
git merge [branch I want to merge] --comit
```

## Review tree

```sh
git log # List of commits with details

git log -S <some words> # Search all commits that have added or deleted <some words>
```

## Tags

Unique bookmarks in history

```sh
git tag <tag name> <commit n°, optional> # Tag HEAD or specific commit number

git tag -d <tag name> # Delete
```

-----
-----

# Vim Fugitive

# Status

:Gstatus -> Interactive git status

Ctrl+n -> Next file
<br />
Ctrl+p -> Previous file
<br />
`Also works in visual mode for multiple lines`

Enter -> Open file
<br />
- -> Toggle Add(stage) / Reset(unstage) file 
<br />
C -> **:Gcommit** -> Commit window like git commit without '-m'
<br />
p -> "Patch" = Start staging hunks in a lousy way, prefer following method :

_Open a file and :Gdiff in it_

:Gedit :<path> -> Open index version of file (:0 for current)

## Diff view

:Gdiffsplit -> Mapped to :Gdiff -> Open diff tool
<br />
:diffoff -> Quit diff wiew

_Can still run :Gstatus which will bring a new pane up top_

:ls -> Get buffers #

:diffupdate -> Re-evaluate for instance for white lines

:diffget <bufspec if merge> -> Get the diff from other window ; In merge, used in working copy
<br />
-> do -> In 2 way

:diffput <bufspec # if merge> -> Put the diff to other window ; In merge, used in //2 and //3
<br />
-> dp -> In 2 way

_With Visual mode I can specificly select and write diffget or diffput_
<br />
_With '|' I can chain vim commands, for instance I can run an update after a get or put_
 
\[c -> Previous hunk
<br />
\]c -> Next hunk

:only -> Select only current split -> Will finish the merge resolving
<br />
:Gwrite -> Will finish, select only current pane and stage the changes `In working copy, otherwise if I only want to keep the changes in merge and stage that I can go on merge or target and do :Gwrite!`

### 2-way diffs ( Working index )

| index version  	| working copy  	|  	
|---	             |---	            |

:Gread -> In 2-way will replace the current buffer by the other `-> Dicard`
<br />
:Gwrite -> In 2-way will replace the other buffer by the current buffer `-> Stage`

### 3-way diffs ( Merge conflicts )

|  target (HEAD) 	|  working copy 	|  merge 	    |   	
|---	             |---	            |---	         |
| bufspec //2     | file name   	  | bufspec //3 |

## History

### Browsing revisions

:Glog -> Browse previous revision of current file
<br />
`Optional arguments`
<br />
-- -> Browse commit messages instead
<br />
-x -> x last revisions
<br />
--reverse
<br />
--until=yesterday
<br />
--since=

:copen -> List of revisions (enter to open)
<br />
:cnext -> Next version ( older )
<br />
-> ]q
<br />
:cprev -> Previous version ( newer )
<br />
-> \[q
:cfirst
<br />
-> \[Q
:clast
<br />
-> \]Q

:Gedit -> Without argument -> Go back to working copy

### Searching text

:Ggrep <pattern> <opt, branch / sha> -> Search for pattern inside files included in git project or branch or commit

:Glog --grep=<pattern> -- -> Search in commit messages

:Glog -S\<pattern> -- -> Search added or removed text `Yes no space after the S`

_Same :copen "QuickFix" system as above_
