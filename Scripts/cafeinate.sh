#!/bin/sh
exec systemd-inhibit --what=idle:sleep --who="cafeinate.sh" --why="Caffeinate: preventing idle and sleep" --mode=block sleep infinity
