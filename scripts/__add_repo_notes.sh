#!/usr/bin/env bash

NOTES_DIR="$HOME/notes"
PROJECT_NAME=$(basename "$PWD")
NOTES_FILE="$NOTES_DIR/${PROJECT_NAME}-NOTES.md"

if [ ! -f "$NOTES_FILE" ]; then
    echo "# Notes for $PROJECT_NAME" >"$NOTES_FILE"
    echo "Created on $(date)" >>"$NOTES_FILE"
    echo "Notes file created: $NOTES_FILE"
else
    echo "Notes file already exists: $NOTES_FILE"
fi

ln -s "$NOTES_FILE" "NOTES.md"

if [ -f ".gitignore" ]; then
    if ! grep -q "NOTES.md" .gitignore; then
        echo "NOTES.md" >>.gitignore
    fi
else
    echo "NOTES.md" >.gitignore
fi
