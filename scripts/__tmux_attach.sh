#!/usr/bin/env bash

session_name="$(basename "$PWD" | tr . -)"

session_exists() {
    tmux list-sessions | sed -E 's/:.*$//' | grep -q "^$session_name$"
}

if [ -z "$TMUX" ]; then
    tmux new-session -As "$session_name"
else
    if ! session_exists; then
        (TMUX='' tmux new-session -Ad -s "$session_name")
    fi
    tmux switch-client -t "$session_name"
fi
