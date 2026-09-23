# Widgets

## Goal

Now I want to create some desktop widgets that will be displayed in the middle of the right hand side of the screen

They have to be dynamic and displayed over the wallpaper, but they have to be behind the applications.

There will be 3 distinct sections

They will be in the same theme as the current QuickShell bar: For the icons use the some color as the one of the pills and the text same color as the text. Also use Nerd Font icons

## Sections

1. Weather

- Using weather.com
- First row, current weather
- Then, display in an horizontal list below the weather for the each next 24h (with each hour below)
- Display on horizontal list for the previsions of the next 7 days (one icon for the morning, one the afernoon)
- Below display the city (use Nice France), the last refreshed ddate and a refresh icon button to refresh the data
- Auto refresh every 1h

2. Infos

- Date + hour of last NixOS snapshot
- Number of snapshots stored
- Number of packages available for updates (*DISCUSS THE STRATEGY FIRST*)

3. Disk space

- Underline on hover and display an icon of a terminal (on click open kitty at the location of the path) and of a folder (on click open nautilus at the location of the path)
- Add a config file with the list of hardcoded path to display

4. Endpoints

- A vertical list of URL endpoint status (*DISCUSS THE STRATEGY FIRST*)
- Url with a dot either green (HTTP code 2xx) or red (every other code)
- On hover underline the text and on click opens firefox to the URL
- Add a config file with the list of URLS
