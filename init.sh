#!/bin/bash

#GitHub mirror of the latest AOS code
GIT_ETHZ_OBERON="https://github.com/harrisonpartch/ethzoberonmirror.git"

#Precompiled AOS needed for first compilation
AOS_TGZ="http://www.informatik.uni-bremen.de/~fld/UnixAos/rev.5600/LinuxAos.tgz"
AOS_INSTALL="http://www.informatik.uni-bremen.de/~fld/UnixAos/rev.5600/install.UnixAos"
AOS_README="http://www.informatik.uni-bremen.de/~fld/UnixAos/rev.5600/Readme.Debian.txt"
AOS_REVISION="r5600"

#Home folder
DIR=`pwd`

#Check flags
if [ $# -ge 2 ] && [ $1 == "-f" ]; then
    rm -f .installed
fi

#Only install once
if [ -f .installed ]; then
    echo "Build system is already installed,"
    echo "    run upgrade to upgrade AOS to the newest version, or"
    echo "    run $0 -f to force isntallation."
    exit 0
fi

#Grab precompiled AOS
echo "Installing AOS $AOS_REVISION from uni-bremen.de..."
mkdir $AOS_REVISION
cd $AOS_REVISION
wget $AOS_TGZ $AOS_INSTALL $AOS_README
if [ -f "LinuxAos.tgz" ] && [ -f "install.UnixAos" ] && [ -f "Readme.Debian.txt" ]; then
    chmod +x "install.UnixAos"
    sudo ./install.UnixAos "LinuxAos.tgz"
else
    echo "ERROR: wget failed to download the necessary files."
    exit 1;
fi
cd $DIR

#Grab AOS source
echo "Cloning AOS source..."
git clone $GIT_ETHZ_OBERON

#Create build directory
echo "Creating build directory..."
mkdir "build"
cd "build"
mkdir "NewAos"
ln -sT ../ethzoberonmirror/trunk/source/ source
ln -sT Unix/BuildTools Tools
ln -sT ../ethzoberonmirror/trunk/UnixAos/ Unix
cd $DIR

#Finish
touch .installed
echo "AOS build automation initialized."
