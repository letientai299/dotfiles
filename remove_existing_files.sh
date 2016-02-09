#!/bin/bash

# This function check and REMOVE existing file. Yes, it'll remove the file, as
# I'm the only one who using my machine, and I don't care if I lose some of my
# local custom
remove_if_existed(){
    # First assume the input is a file
    if [ -f $1 ]; then
        echo "File $1 existed. Try to remove it..."
        rm $1
    fi
}


remove_if_existed ~/.zshrc
remove_if_existed ~/.vrapperrc
remove_if_existed ~/.ideavimrc

