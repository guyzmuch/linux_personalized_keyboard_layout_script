# Script to install personalized keyboard layout on linux

## Intro
I am french, and I am using the bépo keyboard layout (a layout optimized for french writting, similar to dvorak for english).  
But I wanted to change some keys in the standarst bépo layout to suit my need. On windows, I could simply create a installer with my custom layout, and having it work, on linux, it is a bit tricky.  
So this script is to help you set up a custom layout in linux in the best way possible depending on your display server (wayland or X11), and have the layout available in the keyboard option menu in the GUI.  
The script is proposing several options to reach the goal, and you are guided through it. The idea is to make it has easy as possible.  

The only thing to set up, is to know how to create a mapping for the layout (xkb format), I will explain later on.


## Getting started
Modify the file `layout_files/layou_mapping.xkb` and add your layout mapping within the accolade (without modifying the existing code).  
For example you could just modify one key on the US layout by including the base layout, and adding the keys you wish to modify (all others keys will use the base information)  
```
  include "us(basic)"

  key <AD01>	{[	 a,	 A		]};
  key <AC01>	{[	 q,	 Q		]};
```
In here, I have just inverted the letter "a" and "q" (this is just for the example, you can see the result in the `layout_mapping_examples/example.xkb` file)

Once the file is modified, you can run the script:  
`./xkb_keyboard_layout_addition.sh`  
And let you guided with the different option to have the wanted results.  
Depending on your choice, you might have to run the script as root.  
If all is correctly set up, after a log out of the session (or even restart your computer), you should see be able to select the layout in the GUI of the keyboard layout configuration of your operating system.


## The script choices
There are 2 differents path for the script, depending if your display server is wayland or X11 (the script auto detect that).  
In both case, the script will ask you to fill a name for your layout.

### wayland
1. You can choose to prepare the necessary files without setting them up on the operating system. This is great if you want to review the file the script is generating. The file will be generated in the folder "xkb" in the repo
2. You can set up the layout for the current user. The layout configuration will be generated in you user folder under "$HOME/.config/xkb". On restart, the layout will be available for selection for this user.
3. You can set up the layout for all users. The layout configuration will be generated in the system folder under "/etc/xkb". On restart, the layout will be available for selection for all users. This option needs root privilege (but the script will let you know)

### X11
Unfortunatly, X11 doesn't not have a simple way to have your custom layout as a seperate config in the system, and you will have to compromise
1. You can choose to prepare the necessary files without setting them up on the system. This is great if you want to review the file the script is generating. The file will be generated in the folder "xkb" in the repo
2. It will create the layout configuration file on your user folder under "$HOME/.config/xkb-manual". You will need to run a command every time you want to use the layout (as it will load it). The script us setting up an alias in the ".bashrc" file to launch the command.
3. Set up of the layout for all users by modifying some system files.

There is couple of limitations to the set up of the layout for X11:  
- In the second case, you will need to run the set up alias command every time you want to load the layout
- In the second case, the normal way of switching layout won't work anymore. Selecting a different layout from the panel bar won't work. To make it work again, the hack is to go to the keyboard layout settings, and change something (like moving a layout around).
- In the third case, the change might not work anymore on after some update of the operating system


## Limitation
The custom layout won't appear as a specific language layout in the system (aka it won't be part of the "English" or "French" or "German" layout), it will be it's own entity. And so, language flag won't show.

Depending on the option, the script will only work if you have a single custom layout setup, as the same file might be overwritten.  
The solution to have multiple custom layout will not be detailled thoroughly in here, but you can rename some generated folder to not have the same name (working for the X11 second option, but you will need to update the command). Or you might need to update the "evdev" and "evdev.xml" generated file to include all the different custom layout (wayland case 2 and 3).

