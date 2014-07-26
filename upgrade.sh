#!/bin/bash

IDIR=""

function aclean(){
    echo "Cleaning build directory..."
    cd build
    rm -f *.Obj LinuxAosCore AOS*Log .aoshome
    cd NewAos
    rm -f AOS*Log .aoshome
    cd $IDIR
}

function apull(){
    echo "Pulling newest AOS..."
    cd ethzoberonmirror
    git pull
    cd $IDIR
}

function abuild(){
    echo "ERROR: UNIMPLEMENTED"
    exit 1

    echo "Compiling aos..."
    cd build
    aos -x "" #TODO
    mv *.Obj NewAos/

    echo "Linking aos..."
    aos -x "" #TODO

    if [ ! -f NewAos/LinuxAosCore ]; then
        echo "Error: LinuxAosCore was not found! Something gone terribly wrong!"
        exit 1
    fi

    cd $IDIR
}

function atest(){
    echo "Testing aos..."
    if [ -f build/NewAos/LinuxAosCore ]; then
        cd build/NewAos && aos
        cd $IDIR
    else
        echo "LinuxAosCore was not found! Please build first!"
        exit 1
    fi
}

function adeploy(){
    echo "Deploying aos into /usr/aos..."
    if [ -f build/NewAos/LinuxAosCore ]; then
        cd build/NewAos
        sudo rm /usr/aos/obj/*
        sudo cp *.Obj LinuxAosCore /usr/aos/obj/
        cd $IDIR
    else
        echo "LinuxAosCore was not found! Please build first!"
        exit 1
    fi
}

function ahelp(){
    echo "AOS build procedure automation."
    echo "Usage: $0 commands or $0 command0 [command1 [...]] or $0 help"
    echo "E.g.: \"$0 cpbt\" equals \"$0 clean pull build test\""
    echo "Available commands:"
    echo "    c = clean  : cleans build directory"
    echo "    p = pull   : pulls newest AOS source form harrison's GitHub mirror"
    echo "    b = build  : builds newest AOS from source"
    echo "    t = test   : tests newest AOS"
    echo "    d = deploy : deploys newest AOS into /usr/aos"
}

function main(){
    if [ ! -f .installed ]; then
        echo "Please run init.sh first!"
#        exit 1
    fi

    #Installation directory
    IDIR=$PWD

    #Default: clean, pull, build and deploy
    params="cpbd"

    #Process parameters
    if [ $# -eq 1 ]; then
        if [ "$1" = "help" ]; then
            #HALP!
            ahelp
            exit 0
        else
            #Got them as characters
            params=$1
        fi
    elif [ $# -gt 1 ]; then
        #Got them as commands
        params=""
        for c in $@; do
            l=""
            case $c in
                 "clean") l="c";;
                  "pull") l="p";;
                 "build") l="b";;
                  "test") l="t";;
                "deploy") l="d";;
                       *) echo "Invalid command: $c" && exit 1;;
            esac
            params="$params$l"
        done
    fi

    #Verify parameters
    for i in $(seq 0 ${#params}); do
        l=${params:$i:1}
        [ ${#l} -gt 0 ] &&  if [[ "cpbtd" != *$l* ]]; then
            echo "Invallid command character: $l" && exit 1
        fi
    done

    #Execute commands
    for i in $(seq 0 ${#params}); do
        l=${params:$i:1}
        [ ${#l} -gt 0 ] && case $l in
            "c")  aclean $@;;
            "p")   apull $@;;
            "b")  abuild $@;;
            "t")   atest $@;;
            "d") adeploy $@;;
              *) echo "FATAL ERROR, this should never ever happen, pls contact Garmine" && exit 1;;
        esac
    done
}

main $@
