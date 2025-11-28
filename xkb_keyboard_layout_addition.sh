#!/bin/bash

# HERE YOU CAN MANUALLY SET SOME INFO FOR THE LAYOUT (if left empty, they will be replaced with "layout_name")
layout_file_name=""
layout_description=""

# different path for the wayland setting
local_path=xkb
user_path=$HOME/.config/xkb/
all_users_path=/etc/xkb/

# "XDG_SESSION_TYPE" is the type of display server protocol in linux. It can be "wayland" or "x11"
xdg_type=$XDG_SESSION_TYPE

# user valiable filled by the user
layout_name=
country_list_ref=
language_list_ref=

# function asking information to the user in regards to the layout and fill the correct variable
getLayoutInfo() {
  # Requesting the layout name
  echo "Enter your layout name:"
  read layout_name

  # Requesting the country list reference
  echo "Enter the country list reference for the layout (ex: US, FR, DE):"
  read country_list_ref

  # Requesting the language list reference
  echo "Enter the language list reference for the layout (ex: eng, fra, deu):"
  read language_list_ref

  # if no specific file name is defined, we use the layout name
  if [ -z "$layout_file_name" ]; then
    layout_file_name="$layout_name"
  fi
  # if no specific description is defined, we use the layout name
  if [ -z "$layout_description" ]; then
    layout_description="$layout_name"
  fi
}

# For wayland, we can create keyboard mapping file and save it either on the user setup, or for all the users.
# We ask the user where to save the file
# We ask the user information on its layout: name, contry code, language list
# We then take the template files, replacing placeholders with the values given by the user, and save the modified files at the right place.
if [[ "$xdg_type" == "wayland" ]]; then
  echo "CREATING KEYBOARD LAYOUT FOR WAYLAND..."
  # Where to save the layout
  echo "Do you want the layout to be:"
  echo "1: Prepare in this repo for later copy"
  echo "2: Set for the current user"
  echo "3: Set for all users (need to run as root)"
  read choice

  if [[ ("$choice" != "1") && ("$choice" != "2") && ("$choice" != "3") ]]; then
    echo "Invalid choice. Exiting"
    exit 1
  fi

  getLayoutInfo

  # Setting the folder for the files
  files_path=$local_path
  if [ "$choice" == "2" ]; then
    files_path=$user_path
  fi
  if [ "$choice" == "3" ]; then
    files_path=$all_users_path
  fi

  # Creating the containing folders
  mkdir -p $files_path/rules
  mkdir -p $files_path/symbols

  # Copying the files and inserting layout name
  sed "s/<layout_name>/${layout_name}/g" layout_files/layout_mapping.xkb > $files_path/symbols/$layout_file_name
  sed "s/<layout_name>/${layout_name}/g" layout_files/layout_option | sed "s/<layout_file_name>/${layout_file_name}/g" > $files_path/rules/evdev
  sed "s/<layout_name>/${layout_name}/g" layout_files/layout_discorvery.xml | sed "s/<layout_file_name>/${layout_file_name}/g" | sed "s/<layout_description>/${layout_description}/g" | sed "s/<layout_country_list>/${country_list_ref}/g"  | sed "s/<layout_language_list>/${language_list_ref}/g" > $files_path/rules/evdev.xml

  # Report on the file saved
  echo ""
  echo "The folder containing the configuration file for the layout have been saved in \"$files_path\""
  # echo "The folder containing the configuration file for the layout have been saved in $file_path"
  if [ "$choice" != '1' ]; then
    echo "You might need to restart you session to see the changes."
    echo "The layout should be available as an option for your layout keyboard (even via the GUI of your OS)"
  fi

  # Exit the script to prevent following code to run
  exit
fi

# For x11, we have 2 choices (that are not ideals):
# - Create the configuration for the layout, and load it manually every time
# - Create a mapping file in the system folder and modify a xkb configuration. This touch some configuration, that could be dangerous, and the setting might reset on some OS update
if [[ "$xdg_type" == "x11" ]]; then
  echo "CREATING KEYBOARD LAYOUT FOR X11..."

  # Exit the script to prevent following code to run
  exit
fi

# If we are here, $XDG_SESSION_TYPE is neither "wayland" or "x11", so we could not determine a correct display server protocol
echo "Your machine display server protocol return by XDG_SESSION_TYPE is: '$XDG_SESSION_TYPE'"
echo "This is not compatible with this script."
exit 1
