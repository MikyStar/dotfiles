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
