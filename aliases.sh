#!/bin/bash
# This will create surfix alias to open a file with the associated application.
# Input:
# - Application name
# - List of file extention
make_alias_open(){
    # App name should be the fisrt input,
    app="$1"

    shift # Ignore the first param, which is the app name.

    # Loop through the rest of argument list to make surfix alias
    for ext; do
      alias -s $ext=$app
    done
}

make_alias_open vim\
  vim md sh c cpp cs css xml rc tex py java scala
make_alias_open zathura\
  pdf
make_alias_open vlc\
  mp4 flv avi mkv

# I still change my configuration a lot, so I wanna soften the typing.
alias so="source"
alias v="view"
alias vw="vim +VimwikiIndeix"
alias vd="vim +VimwikiDiaryIndex"
alias vt="vim +VimwikiMakeDiaryNote +Goyo"
alias sv="sudo vim"
