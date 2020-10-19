# TMUX

## Basic

`<C-b> -> Main trigger sequence for tmux`

i -> Reload conf file

## Sessions

```sh
tmux new -s <name>

tmux ls

# a / attach
tmux a -t <session name or number>

tmux rename-session -t <session name or number> <name>

# ses / session
tmux kill-ses -t <session name or number> 
tmux kill-session -a # All except current
tmux kill-session -a -t mysession # All except my session
```

s -> Display all sessions with overview

d -> Detach session

( -> Previous session

) -> Next session

$ -> Rename session

## Panes

`Use arrows to browse panes`

```
: setw synchronize-panes
```

% -> Create vertical pane ( right )

" -> Create horizontal pane ( bottom )

; -> Toggle last active pane

z -> Toggle zoom pane

x -> Close pane

{ -> Move current pane left

} -> Move current pane right

q -> Show pane numbers

q + 1..x -> Switch to pane n°x

! -> Convert pane to window

_MacOS_ : Meta + arrows -> Resize

_Windows_ : Ctrl + arrows -> Resize

space -> Toggle between layouts

o -> Go to next pane

## Windows

c -> New window

& -> Close current window

1...x -> Browse to window

, -> Rename current window

n -> Next window

p -> Previous window

```
: swap-window -s 2 -t 1 # Reorder window, swap window number 2(src) and 1(dst)

: swap-window -t -1 # Move current window to the left by one position
```

## Copy Mode
