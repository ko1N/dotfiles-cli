#!/usr/bin/env bash
dir=$(dirname "$0")
selected=`cat $dir/.tmux-cht-languages $dir/.tmux-cht-command | fzf`
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter Query: " query

query=`echo $query | tr ' ' '+'`
tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"

