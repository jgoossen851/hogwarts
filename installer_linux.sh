#!/bin/bash

# ToDo: Add flags (-g, -u, etc.) to enable skipping the interactive part


# Define user-inputs
UI_NAME="newt"
UI_DISPLAY_NAME="N.E.W.T."
UI_COMMENT="A test program for the wizard"
UI_PATH_LINUX="./src/a.out"
UI_PATH_WINDOWS=
UI_ICON="./res/icon_executable.svg"
UI_FILE_I_MIME_TYPE="application"
UI_FILE_I_MIME_SUBTYPE="custom-type-1"
UI_FILE_I_MIME_COMMENT="Sample MIME Type 1"
UI_FILE_I_MIME_EXTENSION=".myext1"
UI_FILE_I_MIME_ICON="./res/icon_file_1.svg"
UI_FILE_II_MIME_TYPE="application"
UI_FILE_II_MIME_SUBTYPE="custom-type-2"
UI_FILE_II_MIME_COMMENT="Sample MIME Type 2"
UI_FILE_II_MIME_EXTENSION=".myext2"
UI_FILE_II_MIME_ICON="./res/icon_file_2.svg"


# Name resources
DESKTOP_FILE="$UI_NAME.desktop"
MIME_TYPE_FILE="$UI_NAME.xml"

# Variables in other files ($DESKTOP_FILE)
EXEC_PLACEHOLDER='<$EXECUTABLE>'
ICON_PLACEHOLDER='<$ICON>'



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

ICON_RESOURCE_I="$UI_FILE_I_MIME_TYPE-$UI_FILE_I_MIME_SUBTYPE.svg"
ICON_RESOURCE_II="$UI_FILE_II_MIME_TYPE-$UI_FILE_II_MIME_SUBTYPE.svg"


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

# Edit files
sed -i.backup \
    -e "s/$EXEC_PLACEHOLDER/$UI_NAME/g" \
    -e "s|$ICON_PLACEHOLDER|$PROG_ICON_PATH/$UI_NAME-icon.svg|g" \
    "$DESKTOP_FILE"

# Copy or remove files
if [ $INSTALL_MODE -eq 1 ]; then
  $DO cp "$UI_PATH_LINUX" "$BIN_DIR/$UI_NAME"
  $DO cp "$UI_ICON" "$PROG_ICON_PATH/$UI_NAME-icon.svg"
  $DO cp "$DESKTOP_FILE" "$DESKTOP_PATH"
  $DO cp "$MIME_TYPE_FILE" "$MIME_TYPE_PATH"
  $DO cp "$UI_FILE_I_MIME_ICON" "$ICON_PATH/$ICON_RESOURCE_I"
  $DO cp "$UI_FILE_II_MIME_ICON" "$ICON_PATH/$ICON_RESOURCE_II"
  
  # Append default application for extension
  echo "$UI_FILE_I_MIME_TYPE/$UI_FILE_I_MIME_SUBTYPE=$DESKTOP_FILE" | \
	$DO tee -a $DESKTOP_PATH/defaults.list > /dev/null
  echo "$UI_FILE_II_MIME_TYPE/$UI_FILE_II_MIME_SUBTYPE=$DESKTOP_FILE" | \
	$DO tee -a $DESKTOP_PATH/defaults.list > /dev/null
else
  $DO rm "$BIN_DIR/$UI_NAME"
  $DO rm "$PROG_ICON_PATH/$UI_NAME-icon.svg"
  $DO rm "$DESKTOP_PATH/$DESKTOP_FILE"
  $DO rm "$MIME_TYPE_PATH/$MIME_TYPE_FILE"
  $DO rm "$ICON_PATH/$ICON_RESOURCE_I"
  $DO rm "$ICON_PATH/$ICON_RESOURCE_II"
  
  # Remove default application for extension
  $DO sed -i "\|^$UI_FILE_I_MIME_TYPE/$UI_FILE_I_MIME_SUBTYPE=$DESKTOP_FILE|d" $DESKTOP_PATH/defaults.list
  $DO sed -i "\|^$UI_FILE_II_MIME_TYPE/$UI_FILE_II_MIME_SUBTYPE=$DESKTOP_FILE|d" $DESKTOP_PATH/defaults.list
fi

# Restore backups
mv "$DESKTOP_FILE.backup" "$DESKTOP_FILE"

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

