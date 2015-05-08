#!/bin/bash

# Version     : 0.1
# Author      : J. Pfeffer
# License     : ??

# Variables
ARCHITECTURE=`uname -m`

# Cleaning on/off
CLEANING=true

# Required packages
REQUIREMENTS="\
binfmt-support \
git \
qemu-user-static \
wget \
"

# Eclipse
# Eclipse package solution
ECLIPSE_PACKAGE="http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/luna/SR2/eclipse-cpp-luna-SR2-linux-gtk-x86_64.tar.gz&r=1"

# Functions

function error () { 
 echo "Error: $@" ; 
}

function timestamp () {
 date --rfc-3339=seconds
}

function download()
{
    local url=$1
    local target=$2
    echo -n "    "
    wget --progress=dot $url -O $target 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo -ne "\b\b\b\b"
    echo " DONE"
}

function delete_folder()
{
    local folder=$1
    echo "Deleting folder: $folder"
    if [ -d $folder ]; then
        rm -r -f $folder
        echo " DONE"
    else
        error "Could delete. The folder $folder doesn't exist."
    fi
}

function delete_file()
{
    local file=$1
    echo "Deleting file: $file"
    if [ -d $file ]; then
        rm -f $file
        echo " DONE"
    else
        error "Could delete. The file $file doesn't exist."
    fi
}

function delete_symlink()
{
    local symlink=$1
    echo "Deleting symlink: $symlink"
    if [ -h $symlink ]; then
        rm -f $symlink
        echo " DONE"
    else
        error "Could delete. The symlink $symlink doesn't exist."
    fi
}


##### Some checks #####
# Check for root or sudo
if [[ $EUID -ne 0 ]]; then
    error "This script should be run using sudo or as the root user"
    exit 1
fi

# Check architecture
if [ $ARCHITECTURE != "x86_64" ]; then
    error "This script is only for the x86_64 architecture"
    exit 1
fi

##### Clean #####
# This section undoes most of the changes made by the script
if [ "$CLEANING" = true ]; then
    echo "CLEANING"
    delete_folder eclipse
    delete_folder raspberrypi
    delete_symlink run-eclipse
echo ""
fi

##### Setup environment #####
# Install requirements
echo "Installing requirements ..."
apt-get -s -q --show-progress install $REQUIREMENTS
echo " DONE"
echo ""

# Download eclipse
echo "Downloading eclipse ..."
download "$ECLIPSE_PACKAGE" eclipse.tar.gz
echo "Extracting eclipse ..."
tar -xzf eclipse.tar.gz
rm -f eclipse.tar.gz
ln -s ./eclipse/eclipse ./run-eclipse
echo " DONE"
echo ""

# Raspberry Pi cross-compilation tool chain
mkdir raspberrypi
git clone --depth=1 https://github.com/raspberrypi/tools.git raspberrypi/tools
echo ""
echo "Please add the following line to the end of ~/.bashrc"
echo "and type 'source ~/.bashrc' to activate it or restart the terminal window"
echo "export PATH=\$PATH:$PWD/raspberrypi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin"
echo ""

