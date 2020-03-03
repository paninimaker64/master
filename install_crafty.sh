#!/bin/bash

# NOTE - do NOT run this as root. use a normal user account
# DOUBLE NOTE - Make sure you have access to the folder you are setting below. 
# Normally a user doesn't have access to /var/opt . so either chmod to your user, or choose another dir

# Please setup the variables below to your liking before running the script!

# This is where crafty will be installed. 
# We suggest: /var/opt/minecraft/crafty <-- make sure you have access to this folder

CRAFTY_INSTALL_LOC=/var/opt/minecraft/crafty

# Set this to the branch you wish to run - Option are:
# MASTER = The stable branch, until 2.0 don't use this
# BETA = The Beta branch
# SNAPS = The Snapshot branch - Bleeding Edge!
BRANCH=SNAPS

# Set this to TRUE when you are ready to actually install
# USE CAPS HERE - TRUE/FALSE
INSTALLER_READY=FALSE

# INSTALL REQUIRED SOFTWARE (This will also update your system)
# USE CAPS HERE - TRUE/FALSE
INSTALL_SOFTWARE=TRUE

############### DO NOT EDIT BELOW THIS LINE ########################

printf "\n\n"
printf "########################################################\n"
printf "Welcome to the Crafty Linux Installer!\n\n"
printf "This script will automatically setup your Crafty Install!\n"


if [ "$INSTALLER_READY" = FALSE ]; then
	printf "Installer_Ready is still set to FALSE!!!\n"
	printf "Please edit the variables in this script first!\n\n\n"
	exit 1
fi


printf "########################################################\n\n"

#echo location we are installing to
printf "Crafty will be installed here: $CRAFTY_INSTALL_LOC\n"

#are we doing dev or master?
if [ "$BRANCH" == SNAPS ]; then
	printf "You are installing the SNAPSHOT BRANCH!\n"
fi

if [ "$BRANCH" == BETA ]; then
	printf "You are installing the BETA BRANCH!\n"
else
	printf "You are installing the MASTER BRANCH \n"
fi

#are we installing software for them?
if [ "$INSTALL_SOFTWARE" == TRUE ]; then
	printf "We are installing / upgrading software for you\n"
else
	printf "We are NOT installing required dependancies for you\n"
fi

#are we ready to install?
printf "Do you wish to install this program?\n\n"
printf "Type 1 for Yes - or - 2 for No then press enter\n\n"

select yn in "Yes" "No"; do
    case $yn in
	Yes ) break;;
        No ) exit;;
    esac
done

#do we want to install software / upgrade system?
if [ "$INSTALL_SOFTWARE" == TRUE ]; then

	echo "Installing Required Software"
	echo "Updating Apt"
	sudo apt update -y
	sudo apt install git python3.7 python3.7-dev python3-pip software-properties-common default-jre openjdk-8-jdk openjdk-8-jre-headless virtualenv -y

	echo "Installing Virtualenv"
	pip3 install virtualenv > /dev/null 2>&1
fi

#make the dir
echo "Creating directory $CRAFTY_INSTALL_LOC"
mkdir -p $CRAFTY_INSTALL_LOC > /dev/null 2>&1

cd $CRAFTY_INSTALL_LOC > /dev/null 2>&1

#build the virt env
echo "Creating Virtual Environment for Crafty"
virtualenv --python=/usr/bin/python3 $CRAFTY_INSTALL_LOC/venv > /dev/null 2>&1

#clone
echo "Cloning the Repo"

git clone http://gitlab.com/Ptarrant1/crafty-web.git > /dev/null 2>&1

#activate virt env
echo "Activating Virtual Env"
source venv/bin/activate > /dev/null 2>&1

cd $CRAFTY_INSTALL_LOC > /dev/null 2>&1
cd crafty-web > /dev/null 2>&1

#switch branches if they want
if [ "$BRANCH" == SNAPS ]; then

	echo "Switching to snapshot branch"
	git checkout snapshot > /dev/null 2>&1
fi

if [ "$BRANCH" == BETA ]; then

	echo "Switching to beta snapshot branch"
	git checkout beta > /dev/null 2>&1
fi


#install pip stuffs
echo "Installing Required Python Packages to the Virtual Environment"
pip3 install -r requirements.txt > /dev/null 2>&1

#make a launcher for them
echo "#!/bin/bash" > "$CRAFTY_INSTALL_LOC/run_crafty.sh"
echo "cd $CRAFTY_INSTALL_LOC" >> "$CRAFTY_INSTALL_LOC/run_crafty.sh"
echo "source venv/bin/activate" >> "$CRAFTY_INSTALL_LOC/run_crafty.sh"
echo "cd crafty-web" >> "$CRAFTY_INSTALL_LOC/run_crafty.sh"
echo "python crafty.py" >> "$CRAFTY_INSTALL_LOC/run_crafty.sh"
chmod +x "$CRAFTY_INSTALL_LOC/run_crafty.sh"

#make update file for them
echo "#!/bin/bash" > "$CRAFTY_INSTALL_LOC/update_crafty.sh"
echo "cd $CRAFTY_INSTALL_LOC\crafty-web" >> "$CRAFTY_INSTALL_LOC/update_crafty.sh"
echo "git pull" >> "$CRAFTY_INSTALL_LOC/update_crafty.sh"
echo "source venv/bin/activate" >> "$CRAFTY_INSTALL_LOC/update_crafty.sh"
echo "pip3 install -r requirements.txt > /dev/null 2>&1" >> "$CRAFTY_INSTALL_LOC/update_crafty.sh"
chmod +x "$CRAFTY_INSTALL_LOC/update_crafty.sh"

#say we are done!
echo "Crafty is now installed!"
echo "Crafty is installed here: $CRAFTY_INSTALL_LOC"
echo "You can launch Crafty by running this script: $CRAFTY_INSTALL_LOC/run_crafty.sh"

