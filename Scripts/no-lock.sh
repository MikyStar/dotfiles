#!/bin/sh
exec systemd-inhibit --what=idle --who="no-lock.sh" --why="Preventing screen lock" --mode=block sleep infinity
