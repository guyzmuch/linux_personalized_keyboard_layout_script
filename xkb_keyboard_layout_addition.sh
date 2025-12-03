#!/bin/bash

# HERE YOU CAN MANUALLY SET SOME INFO FOR THE LAYOUT (if left empty, they will be replaced with "layout_name")
layout_file_name=""
layout_description=""
# From my experience, adding the country and language reference does not work (does not place the layout in the correct language), so this is optional
# Both values need to be set to be active
country_list_ref=
language_list_ref=

# different path for the wayland setting
local_path=xkb
user_path=$HOME/.config/xkb
user_path_x11=$HOME/.config/xkb-manual
all_users_path=/etc/xkb
xkb_system_path=/usr/share/X11/xkb

# "XDG_SESSION_TYPE" is the type of display server protocol in linux. It can be "wayland" or "x11"
xdg_type=$XDG_SESSION_TYPE

# If the script is run as root, by default "XDG_SESSION_TYPE" is not defined
# So you can pass the "-E" option to preserve the environment variable from the original user
# Or you can set up the variable manually when running the command
if [[ -z "$XDG_SESSION_TYPE" && "$EUID" -eq 0 ]]; then
  echo ""
  echo "Root user as no XDG_SESSION_TYPE environment variable set"
  echo "1. Less secure: You can either relaunch the command with the '-E' option of sudo set, to preserve the environment variable."
  echo "   \"sudo -E ...\""
  echo "2. For better security, you first set the user value of the variable, and set it for the command"
  echo "   \"user_session_type=$(echo \$XDG_SESSION_TYPE)\""
  echo "   \"sudo XDG_SESSION_TYPE=\$user_session_type ...\""
  echo "3. For better security, you first echo the user value of the variable, then manually set it up for the command"
  echo "   \"echo \$XDG_SESSION_TYPE\""
  echo "   \"sudo XDG_SESSION_TYPE=<previous_value> ...\""
  exit 1
fi

# user variable filled by the user
layout_name=

# function asking information to the user in regards to the layout and fill the correct variable
getLayoutInfo() {
  # Requesting the layout name
  echo "Enter your layout name:"
  read layout_name

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
    # To set the layout for all users, you need to run the script as root
    if [ $EUID -ne 0 ]; then
        echo "To set the layout for all users, you need to run the script as root."
        exit 1
    fi
    files_path=$all_users_path
  fi

  # Creating the containing folders
  mkdir -p $files_path/rules
  mkdir -p $files_path/symbols

  # determine the layout discovery file template to use
  layout_discovery_template_file="layout_discorvery"
  if [[ -n "$country_list_ref" && -n "$language_list_ref" ]]; then
    layout_discovery_template_file="layout_discorvery_with_language_info"
  fi

  # Copying the files and inserting layout name
  sed -e "s/<layout_name>/${layout_name}/g" \
      -e "s/<layout_description>/${layout_description}/g" \
      layout_files/layout_mapping.xkb > $files_path/symbols/$layout_file_name
  sed -e "s/<layout_name>/${layout_name}/g" \
      -e "s/<layout_file_name>/${layout_file_name}/g" \
      layout_files/layout_option > $files_path/rules/evdev
  sed -e "s/<layout_name>/${layout_name}/g" \
      -e "s/<layout_file_name>/${layout_file_name}/g" \
      -e "s/<layout_description>/${layout_description}/g" \
      -e "s/<layout_country_list>/${country_list_ref}/g" \
      -e "s/<layout_language_list>/${language_list_ref}/g" \
      layout_files/$layout_discovery_template_file.xml > $files_path/rules/evdev.xml
  
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

    # Where to save the layout
  echo "Do you want the layout to be:"
  echo "1: Prepare in this repo for later copy"
  echo "2: Prepare for the users"
  read choice

  if [[ ("$choice" != "1") && ("$choice" != "2") ]]; then
    echo "Invalid choice. Exiting"
    exit 1
  fi

  getLayoutInfo

  # Setting the folder for the files
  files_path=$local_path
  if [ "$choice" == "2" ]; then
    files_path=$user_path_x11
  fi

  # Creating the containing folders
  mkdir -p $files_path/rules
  mkdir -p $files_path/symbols

  # Copying the files and inserting layout name
  sed -e "s/<layout_name>/${layout_name}/g" \
      -e "s/<layout_description>/${layout_description}/g" \
      layout_files/layout_mapping.xkb > $files_path/symbols/$layout_file_name
  sed -e "s/<layout_name>/${layout_name}/g" \
      -e "s/<layout_file_name>/${layout_file_name}/g" \
      -e "s/<layout_description>/${layout_description}/g" \
      layout_files/layout_discorvery_light.xml > $files_path/rules/evdev.xml


  # display some information in regards to x11 set up
  if [ "$choice" == "2" ]; then
    echo ""
    echo "Unfortunatly x11 does not suport having config file in the user configuration"
    echo "You have 2 choices for setting up the layout (please read the 'README.md>#x11 options' for more info)"
    echo "1: Manually set the layout each time"
    echo "2: Change system file for set up"
    read x11_set_up

    if [[ ("$x11_set_up" != "1") && ("$x11_set_up" != "2") ]]; then
      echo "Invalid choice. Exiting"
      exit 1
    fi

    # For manual set up, we need to run a command to load the layout each time
    if [[ "$x11_set_up" == "1" ]]; then
      echo "Run the following command to set up the layout everytime you want it."
      echo "'xkbcli compile-keymap --include \$HOME/.config/xkb-manual/ --include-defaults --layout ${layout_file_name} | xkbcomp - \$DISPLAY 2>/dev/null'"
      echo ""
      echo "If you want you can set up an alias for the command by adding it to \"~/.bashrc\" file of your user"
      echo "'echo \"alias load_layout='xkbcli compile-keymap --include \\\$HOME/.config/xkb-manual/ --include-defaults --layout ${layout_file_name} | xkbcomp - \\\$DISPLAY 2>/dev/null'\" >> \$HOME/.bashrc'"
    fi

    # For system set up, we need to copy the mapping to the system file, and manually add the info to the system evdev.xml file 
    if [[ "$x11_set_up" == "2" ]]; then
      # To set the layout for all users, you need to run the script as root
      if [ $EUID -ne 0 ]; then
        echo ""
        echo "The script needs to be run as root to copy the layout mapping file."
        echo "Either, re-run the script as root, or manually run the following command:"
        echo "'cp $files_path/symbols/$layout_file_name $xkb_system_path/symbols/$layout_file_name'"
      else 
        echo "Copying the layout mapping file to the system..."
        cp $files_path/symbols/$layout_file_name $xkb_system_path/symbols/$layout_file_name
      fi
      echo "You need to manually add the layout to the $xkb_system_path/rules/evdev.xml"
      echo "Insert the content of $files_path/rules/evdev.xml into $xkb_system_path/rules/evdev.xml within the \"layoutList\" tag (see example in the read me)"
      echo "Here is the content to copy"
      cat $files_path/rules/evdev.xml
      echo "/!\WARNING: Carefully copy the content, as mistake here might have consequences (maybe even break the OS)"
      echo "You might need to restart you session ater those changes."
      echo "The layout should be available as an option for your layout keyboard (even via the GUI of your OS)"
    fi
  fi

  # Exit the script to prevent following code to run
  exit
fi

# If we are here, $XDG_SESSION_TYPE is neither "wayland" or "x11", so we could not determine a correct display server protocol
echo "Your machine display server protocol return by XDG_SESSION_TYPE is: '$XDG_SESSION_TYPE'"
echo "This is not compatible with this script."
exit 1
