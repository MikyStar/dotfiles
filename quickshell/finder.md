# Finder

I want to replace rofi with a custom quickshell widget in the same theming as the bar and the widgets that will be over whatever is on the screen

You will create it at the same level as 'bar' and 'widgets' folders and name it 'finder'

This finder can be triggered from a keyboard shortcut (this will be handled by hyprland but you need to make it easily triggerable from the outside)

It will consit on a text field fuzzy-finder like Telescope for neovim (I have FZF installed, maybe you can use it) that can index applications, files and custom bash commands that will be under $HOME/Scripts

Below the text field, there will be A list displayed in a horizontal way containing the filers:
    - 'All' (so no filter, default)
    - 'Applications'
    - 'Files'
    - 'Scripts'
Using tab, I can cycle through the filters

Below the filters will be the actual result list

At the left of the applications will be their icon and at the left of the files will be the file icon

By default the first element of the result list will be highlighted, pressing enter will either open the app or the file (in it's default application) or run the script

On hover on files, will make appear to it's far right a folder and terminal icon that will either open on nautils or in terminal (just like for the disk widget)

The fuzzy-finding has to be case insensitive and be smart, like if i write 'dskp' it can resolve to 'Disk-paths', **let's discuss how to handle it if we can't use FZF**
