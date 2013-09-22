#!/usr/bin/env bash

session="coffee"
# 创建一个tmux 的 session
tmux -2 new-session -d -s $session

# mongodb 
#tmux new-window -t $session:1 -n 'mongodb' '$HOME/bin/mongo/mongod --dbpath=$HOME/bin/mongo/data' 
#
#tmux split-window -h
#tmux select-pane -t 1
#tmux send-keys '$HOME/bin/mongo/mongo' C-m
#
## coffee
#tmux new-window -t $session:2 -n 'run' 'coffee -cw ./'
#
##supervisor app.js 
#tmux new-window -t $session:3 -n 'supervisor' 'supervisor app.js'
#
## vim 
#tmux new-window -t $session:4 -n 'vim' 'vim'
#
#tmux -2 attach -t $session

# mongodb 
tmux new-window -t $session:1 -n 'mongodb' 
# coffee
tmux new-window -t $session:2 -n 'run' 
#supervisor app.js 
tmux new-window -t $session:3 -n 'supervisor' 
# vim 
tmux new-window -t $session:4 -n 'vim'


tmux select-window -t $session:1
tmux split-window -h
tmux select-pane -t 0
tmux send-keys '$HOME/bin/mongo/mongod --dbpath=$HOME/bin/mongo/data' C-m
tmux select-pane -t 1
tmux send-keys '$HOME/bin/mongo/mongo' C-m

tmux send-keys -t $session:1 '$HOME/bin/mongo/mongo' C-m
tmux send-keys -t $session:2 'coffee -cw ./' C-m
tmux send-keys -t $session:3 'supervisor app.js' C-m
tmux send-keys -t $session:4 'vim' C-m

tmux select-window -t $session:4


tmux -2 attach -t $session
