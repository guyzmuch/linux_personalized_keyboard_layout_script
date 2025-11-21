#!/bin/bash

local_path=xkb
user_path=$HOME/.config/xkb/
all_users_path=/etc/xkb/

# Where to save the layout
echo "Do you want the layout to be:"
echo "1: Prepare in this repo for later copy"
echo "2: Set for the current user"
echo "3: Set for all users (need to run as root)"
read choice

if [[ ("$choice" != "1") && ("$choice" != "2") && ("$choice" != "3") ]]; then
  echo "Invalid choice. Exiting"
  exit
fi

# Requesting the layout name
echo "Enter your layout name:"
read layout_name

# Requesting the country list reference
echo "Enter the country list reference for the layout (ex: US, FR, DE):"
read country_list_ref

# Requesting the language list reference
echo "Enter the language list reference for the layout (ex: eng, fra, deu):"
read language_list_ref


echo "local_path $local_path"
# Setting the folder for the files
files_path=$local_path
if [ "$choice" == "2" ]; then
  files_path=$local_path
fi
if [ "$choice" == "3" ]; then
  files_path=$all_users_path
fi
echo "files_path $files_path"

# Creating the containing folders
mkdir -p $files_path/rules
mkdir -p $files_path/symbols

# Copying the files and inserting layout name
sed "s/<layout_name>/${layout_name}/g" layout_files/layout_mapping.xkb > $files_path/symbols/$layout_name
sed "s/<layout_name>/${layout_name}/g" layout_files/layout_option > $files_path/rules/evdev
sed "s/<layout_name>/${layout_name}/g" layout_files/layout_discorvery.xml | sed "s/<layout_country_list>/${country_list_ref}/g"  | sed "s/<layout_language_list>/${language_list_ref}/g" > $files_path/rules/evdev.xml

# Report on the file saved
echo ""
echo "The folder containing the configuration file for the layout have been saved in \"$files_path\""
# echo "The folder containing the configuration file for the layout have been saved in $file_path"
if [ "$choice" != '1' ]; then
  echo "You might need to restart you session to see the changes."
  echo "The layout should be available as an option for your layout keyboard (even via the GUI of your OS)"
fi

exit
