#!/bin/bash

# ToDo: Add flags (-g, -u, etc.) to enable skipping the interactive part

echo -e "\033[33m"
echo "ToDo:  Add my program as the default application"
echo "Global: in /usr/share/applications/defaults.list"
echo "Local:  in $HOME/.local/share/applications/defaults.list"
echo "* Append the line "
echo "      application/custom-program-file-mime-type=program.desktop"
echo "  under the heading [Default Applications], or create the file."
echo "* If creating the file, make sure to print the heading."
echo "* Find a way to somehow add the default under the specified heading,"
echo "  even if other headings exist in the file."
echo "* When uninstalling, remove the line from the file (DON''T DELETE!)"
echo "* You can delete the file if it was the only entry, but you can keep it too..."
echo -e "\033[0m"


# Name resources
EXECUTABLE_FILE="a.out"
DESKTOP_FILE="program.desktop"
MIME_TYPE_FILE="sample-program-mime-type.xml"
ICON_FILE="my_custom_icon.svg"
PROG_ICON_FILE="my_program_icon.svg"

# Variables in other files ($DESKTOP_FILE)
EXEC_PLACEHOLDER='<$EXECUTABLE>'
ICON_PLACEHOLDER='<$ICON>'

# Other configurable values (Must match $MIME_TYPE_FILE)
MIME_TYPE="application"
MIME_TYPE_NAME="custom-program-file-mime-type"



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

ICON_RESOURCE="$MIME_TYPE-$MIME_TYPE_NAME.svg"


# Create directories as needed
if [ $INSTALL_MODE -eq 1 ]; then
  $DO mkdir -p "$BIN_DIR"
  $DO mkdir -p "$DESKTOP_PATH"
  $DO mkdir -p "$MIME_TYPE_PATH"
  $DO mkdir -p "$ICON_PATH"
  $DO mkdir -p "$PROG_ICON_PATH"
fi

# Edit files
sed -i.backup \
    -e "s/$EXEC_PLACEHOLDER/$EXECUTABLE_FILE/g" \
    -e "s|$ICON_PLACEHOLDER|$PROG_ICON_PATH/$PROG_ICON_FILE|g" \
    "$DESKTOP_FILE"

# Copy or remove files
if [ $INSTALL_MODE -eq 1 ]; then
  $DO cp "$EXECUTABLE_FILE" "$BIN_DIR"
  $DO cp "$PROG_ICON_FILE" "$PROG_ICON_PATH"
  $DO cp "$DESKTOP_FILE" "$DESKTOP_PATH"
  $DO cp "$MIME_TYPE_FILE" "$MIME_TYPE_PATH"
  $DO cp "$ICON_FILE" "$ICON_PATH/$ICON_RESOURCE"
else
  $DO rm "$BIN_DIR/$EXECUTABLE_FILE"
  $DO rm "$PROG_ICON_PATH/$PROG_ICON_FILE"
  $DO rm "$DESKTOP_PATH/$DESKTOP_FILE"
  $DO rm "$MIME_TYPE_PATH/$MIME_TYPE_FILE"
  $DO rm "$ICON_PATH/$ICON_RESOURCE"
fi

# Restore backups
mv "$DESKTOP_FILE.backup" "$DESKTOP_FILE"

# Update resources
echo -n "Updating MIME database ... "
$DO update-mime-database "$SHARE_DIR/mime"
echo "Done."

echo -n "Updating icon cache ... "
$DO update-icon-caches "$SHARE_DIR"/icons/*
echo "Done."

