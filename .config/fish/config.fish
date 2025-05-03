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
alias y='yazi'
alias f='fzf'
