#!/usr/bin/env bash

open_file() {
    local file="$1"
    local line="${2:-1}"
    if [ -n "${TMUX}" ]; then
        tmux new-window -n "$(basename "$file")" "nvim \"$file\" +$line"
    else
        nvim "$file" "+$line"
    fi
}
fuzzy_find() {
    local mode="files"
    local root="."
    local selected
    while true; do
        local toggle_target="$([ "$root" = "." ] && echo "home (~)" || echo "($(pwd)))")"
        if [ "$mode" = "files" ]; then
            selected=$(rg --files --hidden \
                -g '!.git' \
                -g '!node_modules' \
                -g '!venv' \
                -g '!.venv' \
                "$root" |
                fzf \
                    --bind "ctrl-f:abort+execute(echo 'content')" \
                    --bind "ctrl-r:abort+execute(echo 'toggle-root')" \
                    --bind "ctrl-/:toggle-preview" \
                    --color=gutter:-1 \
                    --preview 'batcat --style=numbers --color=always {}' \
                    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                    --header "CTRL-F: Switch to content search │ CTRL-R: Switch to $toggle_target │ CTRL-/: Toggle preview")
        else
            selected=$(
                rg --line-number --smart-case --hidden --color=never "" \
                    -g '!.git' \
                    -g '!node_modules' \
                    -g '!venv' \
                    -g '!.venv' \
                    "$root" |
                    fzf \
                        --bind "ctrl-f:abort+execute(echo 'files')" \
                        --bind "ctrl-r:abort+execute(echo 'toggle-root')" \
                        --bind "ctrl-/:toggle-preview" \
                        --color=gutter:-1 \
                        --preview '
                            file=$(echo {} | cut -d: -f1);
                            line=$(echo {} | cut -d: -f2);
                            start=$((line > 5 ? line - 5 : 1));
                            batcat --style=numbers --color=always --highlight-line "$line" --line-range "$start": "$file"
                        ' \
                        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                        --header "CTRL-F: Switch to file search │ CTRL-R: Switch to $toggle_target  │ CTRL-/: Toggle preview"
            )
        fi
        if [ "$selected" = "files" ]; then
            mode="files"
            continue
        elif [ "$selected" = "content" ]; then
            mode="content"
            continue
        elif [ "$selected" = "toggle-root" ]; then
            if [ "$root" = "." ]; then
                root="$HOME"
            else
                root="."
            fi
            continue
        fi

        [ -z "$selected" ] && return

        if [ "$mode" = "content" ]; then
            # Set the cursor position in nvim to search result location.
            local file=$(echo "$selected" | cut -d':' -f1)
            local line=$(echo "$selected" | cut -d':' -f2)
            open_file "$file" "$line"
        else
            open_file "$selected"
        fi
        break
    done
}
fuzzy_find
