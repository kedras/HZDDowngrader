#!/bin/sh

DEPOTDOWNLOADER_VERSION="2.4.5"
REQUIRED_APT_PACKAGES="wget unzip snapd"  # Used to store all tools needed to be installed.
PACKAGES_TO_FETCH=""  # Used to store all tools that need to be installed, used, then removed.
FILE1="1151642"
FILE2="1151641"

# Check Linux distribution
if [ -e /etc/os-release ]; then
  OS_ID=$(grep "^ID=" /etc/os-release | awk -F= '{print $2}' | tr -d '"')
  if [ -n "${OS_ID}" ]; then
    case ${OS_ID} in
      "ubuntu"|"debian"|"linuxmint")
        DIST_TYPE="Debian"
        HORIZON_ZERO_DAWN_DIRECTORY="$HOME/.steam/debian-installation/steamapps/common/Horizon Zero Dawn" # Default Horizon Zero Dawn install directory.
      ;;
      "fedora")
        DIST_TYPE="Fedora"
        HORIZON_ZERO_DAWN_DIRECTORY="$HOME/.steam/steam/steamapps/common/Horizon Zero Dawn" # Default Horizon Zero Dawn install directory.
      ;;
      *)
        echo "OS Detection - Unsupported Linux distribution found in /etc/os-release"
        exit 1
      ;;
    esac
  fi
fi

# Install required tools
echo -e "\n###### Checking system for required tools... ######"

# For every required package that is not installed, add it to PACKAGES_TO_FETCH.
for PACKAGE in $REQUIRED_APT_PACKAGES
do
  if [ $DIST_TYPE = "Debian" ]; then
    if ! dpkg-query -W "$PACKAGE" &> /dev/null; then
      PACKAGES_TO_FETCH="$PACKAGES_TO_FETCH $PACKAGE"
    fi
  elif [ $DIST_TYPE = "Fedora" ]; then
    if ! rpm -q "$PACKAGE" &> /dev/null ; then
      PACKAGES_TO_FETCH="$PACKAGES_TO_FETCH $PACKAGE"
    fi
  fi
done

# If any packages are not installed, install them all in one go.
if [ -n "${PACKAGES_TO_FETCH}" ]; then
  echo -e "These required packages are missing $PACKAGES_TO_FETCH, instaling now...\n"
  if [ $DIST_TYPE = "Debian" ]; then
    sudo apt -y install $PACKAGES_TO_FETCH
  elif [ $DIST_TYPE = "Fedora" ]; then
    sudo dnf install $PACKAGES_TO_FETCH -y
  fi
fi

# Install the dotnet-sdk to run the DepotDownloader.dll file if it is not already there.
DOTNET_RUNTIME_INSTALLED=$(snap list | grep dotnet-runtime-60)
if [ -z "$DOTNET_RUNTIME_INSTALLED" ]; then
  sudo snap install dotnet-runtime-60 --classic
fi

# Download DepotDownloader
echo -e "\n###### Downloading DepotDownloader... ######"
wget -q https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_$DEPOTDOWNLOADER_VERSION/depotdownloader-$DEPOTDOWNLOADER_VERSION.zip

# Unzip DepotDownloader
echo -e "\n###### Unzipping DepotDownloader... ######"
unzip -q -o depotdownloader-$DEPOTDOWNLOADER_VERSION.zip -d depotDownloader

# Create files for -filelist DepotDownloader argument
echo -e "\n###### Creating files for -filelist DepotDownloader argument... ######"
echo "HorizonZeroDawn.exe" > $FILE1.txt
echo "LocalCacheDX12/HashDB.bin" > $FILE2.txt
echo "LocalCacheDX12/ShaderLocationDB.bin" >> $FILE2.txt
echo "Packed_DX12/Patch.bin" >> $FILE2.txt

# Get Steam username and prepare user for two passwords and two-factor authentication
echo -e "\n###### Steam authentication... ######"
echo -e "\nYour Steam username and password as well as two-factor authentication are required to download from the depot."
echo "Please input your Steam username."
read -r USERNAME
echo "Please input your Steam password. The console will not print anything but your keystrokes are being read."
stty -echo
read -r PASSWORD
stty echo

# Get real install directory if default install directory does not exist
echo -e "\n###### Steam game install directory check... ######"
while [ ! -d "$HORIZON_ZERO_DAWN_DIRECTORY" ]
do
  echo "The directory $HORIZON_ZERO_DAWN_DIRECTORY does not exist."
  echo "Please input the directory in which you installed Horizon Zero Dawn."
  read -r HORIZON_ZERO_DAWN_DIRECTORY
done
echo "Using directory $HORIZON_ZERO_DAWN_DIRECTORY as Horizon Zero Dawn install directory."

# Perform downloads
echo -e "\n###### Performing files download for the downgrade... ######"
dotnet-runtime-60.dotnet depotDownloader/DepotDownloader.dll -app 1151640 -depot $FILE1 -manifest 2110572734960666938 -username "$USERNAME" -password "$PASSWORD" -filelist $FILE1.txt
dotnet-runtime-60.dotnet depotDownloader/DepotDownloader.dll -app 1151640 -depot $FILE2 -manifest 8564283306590138028 -username "$USERNAME" -password "$PASSWORD" -filelist $FILE2.txt

# Copy files to Horizon Zero Dawn install directory
echo -e "\n###### Copying files to Horizon Zero Dawn's install directory... ######"
cp depots/$FILE1/7874181/HorizonZeroDawn.exe "$HORIZON_ZERO_DAWN_DIRECTORY/HorizonZeroDawn.exe"
cp -rT depots/$FILE2/7874181/LocalCacheDX12 "$HORIZON_ZERO_DAWN_DIRECTORY/LocalCacheDX12"
cp -rT depots/$FILE2/7874181/Packed_DX12 "$HORIZON_ZERO_DAWN_DIRECTORY/Packed_DX12"

# Remove files that are no longer needed.
echo -e "\n###### Removing files used by this script that are no longer needed... ######"
rm -rf depotDownloader depots $FILE2.txt $FILE1.txt depotdownloader-$DEPOTDOWNLOADER_VERSION.zip

# Uninstall packages that were installed by this script. Let user decide if these should be removed as this might remove some dependencies with default dnf settings applied.
if [ -n "${PACKAGES_TO_FETCH}" ]; then
  while true; do
    echo -e "\nThese packages were installed by this script: $PACKAGES_TO_FETCH"
    read -p "Do you wish to uninstall them? " yn
    case $yn in
        [Yy]* )
          echo "USE WITH CAUTION: Before uninstalling pls check the dependencies which might be also removed within this action!"
          if [ $DIST_TYPE = "Debian" ]; then
            sudo apt remove $PACKAGES_TO_FETCH
          elif [ $DIST_TYPE = "Fedora" ]; then
            sudo dnf remove $PACKAGES_TO_FETCH
          fi
          break
        ;;
        [Nn]* )
          break
        ;;
        * )
          echo "Please answer yes(Y|y) or no(N|n)."
        ;;
    esac
  done
fi
if [ -z "$DOTNET_RUNTIME_INSTALLED" ]; then
  sudo snap remove dotnet-runtime-60
fi

# Finish
echo -e "\n###### Finished. Horizon Zero Dawn has been rolled back to the 1.10 hotfix patch. ######\n"
