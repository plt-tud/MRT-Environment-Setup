#!/bin/bash

# Version     : 0.1
# Author      : J. Pfeffer
# License     : ??


# Variables
WORKSPACE_DIR="workspace"
ARCHITECTURE=`uname -m`

# Cleaning (true/false)
CLEANING=true

# Required packages
REQUIREMENTS="\
build-essential \
git \
openjdk-7-jre \
wget \
"

# Eclipse package solution
ECLIPSE_PACKAGE="http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/luna/SR2/eclipse-cpp-luna-SR2-linux-gtk-x86_64.tar.gz&r=1"

# Functions

function error () { 
 echo " Error: $@" ; 
}

function info () { 
 echo " Info: $@" ; 
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
        error "No need to delete. The folder $folder doesn't exist."
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
        error "No need to delete. The file $file doesn't exist."
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
        error "No need not delete. The symlink $symlink doesn't exist."
    fi
}


##### Some checks #####
# Check architecture
if [ $ARCHITECTURE != "x86_64" ]; then
    error "This script is only for the x86_64 architecture"
    exit 1
fi

# Check if Eclipse is running
if ps ax | grep eclipse.equinox | grep -v grep | grep -v $0 > /dev/null; then
    error "Eclipse is running! Please exit Eclipse!"
    exit 1
fi

##### Setup environment #####
# Install requirements
echo "Installing requirements ..."
sudo apt-get -q --show-progress install $REQUIREMENTS
echo " DONE"
echo ""

# Download eclipse
if [ -d "eclipse" ]; then
    info "The 'eclipse' folder already exists."
    echo ""
else
    echo "Downloading eclipse ..."
    download "$ECLIPSE_PACKAGE" eclipse.tar.gz
    echo "Extracting eclipse ..."
    tar -xzf eclipse.tar.gz
    rm -f eclipse.tar.gz
    ln -s ./eclipse/eclipse ./run-eclipse
    echo " DONE"
    echo ""
fi

# Raspberry Pi cross-compilation tool chain
if [ -d "raspberrypi" ]; then
    info "The folder 'raspberrypi' already exists."
    echo ""
else
    echo "Cloning the Raspberry Pi tools repository. This may take a while, it is big (~200MB download, ~1GB afterwards) ..."
    mkdir raspberrypi
    git clone --depth=1 https://github.com/raspberrypi/tools.git raspberrypi/tools
    echo " DONE"
    echo ""
    echo "Please add the following line to the end of ~/.bashrc"
    echo "and type 'source ~/.bashrc' to activate it or restart the terminal window"
    echo "export PATH=\$PATH:$PWD/raspberrypi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin"
    echo ""
fi

# Create workspace
echo "Creating/updating MRT workspace ..."
if [ ! -d $WORKSPACE_DIR ]; then
    mkdir $WORKSPACE_DIR
fi

# Clone HelloCpp
if [ ! -d "$WORKSPACE_DIR/HelloCpp" ]; then
    git clone https://github.com/plt-tud/MRT-HelloCpp.git workspace/HelloCpp
    eclipse/eclipse -nosplash -data workspace -application org.eclipse.cdt.managedbuilder.core.headlessbuild -import $WORKSPACE_DIR/HelloCpp
else
    git pull
fi

# Clone HelloAssembler
if [ ! -d "$WORKSPACE_DIR/HelloAssembler" ]; then
    git clone https://github.com/plt-tud/MRT-HelloAssembler.git workspace/HelloAssembler
    eclipse/eclipse -nosplash -data workspace -application org.eclipse.cdt.managedbuilder.core.headlessbuild -import $WORKSPACE_DIR/HelloAssembler
else
    git pull
fi

echo " DONE"
echo ""