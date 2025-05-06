# DISABLES GREETING MESSAGE 
set -g fish_greeting ''

# FASTFETCH
if status is-interactive
    fastfetch
end

# DEFAULTS
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx TERMINAL kitty
set -gx BROWSER firefox

# PROMPT
function fish_prompt
    set_color blue
    echo -n "┌  "
    set_color yellow
    echo (prompt_pwd)
    set_color blue
    echo -n "└➤ "
    set_color normal
end

#ALIASES  
alias update='sudo pacman -Syu'
alias search='pacman -Ss'
alias c='clear'

alias nv='nvim'
alias f='fzf'

# YAZI SHELL WRAPPER 
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
