#!/bin/bash

# ToDo: Add flags (-g, -u, etc.) to enable skipping the interactive part

# Ensure an argument was passed
if [ ! $# -eq 1 ]; then
  echo "Warning: $0 requires a single argument with the configuration filename." 1>&2
  exit
fi

# Source the bash configuration
if [ -f $1 ]; then
  source $1
else
  echo "$1: No such file" 1>&2
  exit
fi

# Perform the most basic (and inadequate) input sanitation
# Check only the User Interface program name
if [ -z $UI_NAME ]; then
  echo "Program name is not set. Use a valid configuration file" 1>&2
  exit
fi


# Name resources
DESKTOP_FILE="$UI_NAME.desktop"
MIME_TYPE_FILE="$UI_NAME.xml"
PROGRAM_ICON_FILE="$UI_NAME-icon.svg"
ICON_RESOURCE_I="$UI_FILE_I_MIME_TYPE-$UI_FILE_I_MIME_SUBTYPE.svg"
ICON_RESOURCE_II="$UI_FILE_II_MIME_TYPE-$UI_FILE_II_MIME_SUBTYPE.svg"


# Get installation mode from user
read -p "Select mode: install (I) or uninstall (U): " -n1 ANS
echo

if [[ $ANS == [Ii] ]] ; then
  # Initiate installation
  INSTALL_MODE=1
  
  # Get installation scope
  read -p "Select a local (L) or global (G) installation: " -n1 GLOBAL
  echo

elif [[ $ANS == [Uu] ]]; then
  # Initiate uninstallation
  INSTALL_MODE=0
  
  # Deduce installation scope
  if [ -f "$HOME/.local/share/applications/$DESKTOP_FILE" ]; then
    echo "Local installation found."
    GLOBAL="L"
  elif [ -f "/usr/share/applications/$DESKTOP_FILE" ]; then
    echo "Global installation found."
    GLOBAL="G"
  else
    echo "No installation found."
    exit
  fi
  
else
  echo Unknown option
  exit
fi


if [[ $GLOBAL == [Ll] ]] ; then
  # Local installation
  SHARE_DIR="$HOME/.local/share"
  BIN_DIR="$HOME/.local/bin"
  DO=""
elif [[ $GLOBAL == [Gg] ]]; then
  # Global installation
  SHARE_DIR="/usr/share"
  BIN_DIR="/usr/local/bin"
  DO="sudo"
else
  echo Unknown option
  exit
fi


# Name paths (could be distro-dependant)
DESKTOP_PATH="$SHARE_DIR/applications"
MIME_TYPE_PATH="$SHARE_DIR/mime/packages"
ICON_PATH="$SHARE_DIR/icons/hicolor/scalable/mimetypes"
PROG_ICON_PATH="$SHARE_DIR/icons/hicolor/scalable/apps"


# Create directories as needed
if [ $INSTALL_MODE -eq 1 ]; then
  $DO mkdir -p "$BIN_DIR"
  $DO mkdir -p "$DESKTOP_PATH"
  $DO mkdir -p "$MIME_TYPE_PATH"
  $DO mkdir -p "$ICON_PATH"
  $DO mkdir -p "$PROG_ICON_PATH"
  
  # Creat a Default Applications file if it does not exist
  if [ ! -f $DESKTOP_PATH/defaults.list ]; then    
    $DO echo "[Default Applications]" > $DESKTOP_PATH/defaults.list
  fi
fi


# Copy or remove files
if [ $INSTALL_MODE -eq 1 ]; then
  # Install Executable
  $DO cp "$UI_PATH_LINUX" "$BIN_DIR/$UI_NAME"
  
  # Install Icons
  $DO cp "$UI_ICON" "$PROG_ICON_PATH/$PROGRAM_ICON_FILE"
  $DO cp "$UI_FILE_I_MIME_ICON" "$ICON_PATH/$ICON_RESOURCE_I"
  $DO cp "$UI_FILE_II_MIME_ICON" "$ICON_PATH/$ICON_RESOURCE_II"
  
  # Generate Desktop Entry File
  echo -e "\
[Desktop Entry]
Type=Application
Name=$UI_DISPLAY_NAME
Comment=$UI_COMMENT
Exec=$UI_NAME %f
Icon=$PROG_ICON_PATH/$PROGRAM_ICON_FILE
Terminal=true
MimeType=$UI_FILE_I_MIME_TYPE/$UI_FILE_I_MIME_SUBTYPE;$UI_FILE_II_MIME_TYPE/$UI_FILE_II_MIME_SUBTYPE
" | $DO tee -a "$DESKTOP_PATH/$DESKTOP_FILE" > /dev/null

  # Generate MIME Type XML file
  $DO echo -e "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>
\t<mime-type type=\"$UI_FILE_I_MIME_TYPE/$UI_FILE_I_MIME_SUBTYPE\">
\t\t<comment>$UI_FILE_I_MIME_COMMENT</comment>
\t\t<glob pattern=\"*$UI_FILE_I_MIME_EXTENSION\"/>
\t</mime-type>
\t<mime-type type=\"$UI_FILE_II_MIME_TYPE/$UI_FILE_II_MIME_SUBTYPE\">
\t\t<comment>$UI_FILE_II_MIME_COMMENT</comment>
\t\t<glob pattern=\"*$UI_FILE_II_MIME_EXTENSION\"/>
\t</mime-type>
</mime-info>
" | $DO tee -a "$MIME_TYPE_PATH/$MIME_TYPE_FILE" > /dev/null
  
  # Append default application for extension
  echo "$UI_FILE_I_MIME_TYPE/$UI_FILE_I_MIME_SUBTYPE=$DESKTOP_FILE" | \
	$DO tee -a $DESKTOP_PATH/defaults.list > /dev/null
  echo "$UI_FILE_II_MIME_TYPE/$UI_FILE_II_MIME_SUBTYPE=$DESKTOP_FILE" | \
	$DO tee -a $DESKTOP_PATH/defaults.list > /dev/null
	
else
  # Remove Executable
  $DO rm "$BIN_DIR/$UI_NAME"
  
  # Remove Icons
  $DO rm "$PROG_ICON_PATH/$PROGRAM_ICON_FILE"
  $DO rm "$ICON_PATH/$ICON_RESOURCE_I"
  $DO rm "$ICON_PATH/$ICON_RESOURCE_II"
  
  # Remove Desktop Entry File
  $DO rm "$DESKTOP_PATH/$DESKTOP_FILE"

  # Remove MIME Type XML file
  $DO rm "$MIME_TYPE_PATH/$MIME_TYPE_FILE"
  
  # Remove default application for extension
  $DO sed -i "\|^$UI_FILE_I_MIME_TYPE/$UI_FILE_I_MIME_SUBTYPE=$DESKTOP_FILE|d" $DESKTOP_PATH/defaults.list
  $DO sed -i "\|^$UI_FILE_II_MIME_TYPE/$UI_FILE_II_MIME_SUBTYPE=$DESKTOP_FILE|d" $DESKTOP_PATH/defaults.list
fi


# Update resources
echo -n "Updating MIME database cache... "
$DO update-mime-database "$SHARE_DIR/mime"
echo "Done."

echo -n "Updating icon cache... "
$DO update-icon-caches "$SHARE_DIR"/icons/*
echo "Done."

echo -n "Updating desktop database cache... "
$DO update-desktop-database "$SHARE_DIR/applications"
echo "Done."

