# HZDDowngrader
A bash shell script that downgrades Steam's Horizon Zero Dawn to the 1.10 Hotfix patch. Use this on Linux if you are experiencing graphical errors on the most recent version of Horizon Zero Dawn.

### Disclaimer

This is a fork of https://github.com/PercentBoat4164/HZDDowngrader, all kudos goes to @PercentBoat4164.

### What I have added is the following:

* Make it work for Fedora and other Debian based distros like Mint, Ubuntu, Debian (Debian based part needs proper testing though as I only tested it on Ubuntu)
* Took out the "clear" part to be able to see complete script output
* Make the installed packages removal optional as with default dnf settings it could remove along many other dependencies or break some dependencies for already installed packgages eg with using rpm --nodeps option instead etc. Either way these packages (only unzip, wget and snapd in particular) are not that big and most likely needed in general, so uninstalling them is not really necessary in my opinion. Only automaticaly removed part would be dotnet-runtime-60.
* Minor variable tweaks
* Minor script output tweaks

### Running the script
To run this script:
1. Download the code, or the latest release file.
2. Extract the *.sh file.
3. Open a terminal and navigate to the location that you saved the file.
4. Type in `bash HorizonZeroDawnDowngradeScript.sh`.
5. Follow the on-screen instructions from there.

### Restoring Horizon Zero Dawn to the latest version
If you wish to restore Horizon Zero Dawn back to the latest version:
1. Click "Settings -> Properties" under Horizon Zero Dawn's library page in Steam.
2. On the left of the window that appears click "Local Files -> Verify integrity of game files...".
3. Wait for this process to finish, it may take a few minutes.

*Voilà*, Horizon Zero Dawn is restored to the latest version.
