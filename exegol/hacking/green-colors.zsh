# Blazepwn: same palette as the host terminal.
# Blazepwn: mint green folder/file colors for lsd and GNU ls.
# Bright mint folders and executables; softer green text and metadata.
export LS_COLORS='rs=0:fi=38;2;220;226;236:di=38;2;96;165;250:ln=38;2;125;211;252:or=38;2;219;234;254:mi=38;2;219;234;254:ex=38;2;79;179;249:pi=38;2;147;197;253:so=38;2;147;197;253:bd=38;2;163;196;243:cd=38;2;163;196;243:su=38;2;219;234;254:sg=38;2;163;196;243:tw=38;2;96;165;250:ow=38;2;96;165;250:st=38;2;96;165;250:mh=38;2;220;226;236:*.zip=38;2;163;196;243:*.tar=38;2;163;196;243:*.gz=38;2;163;196;243:*.7z=38;2;163;196;243:*.rar=38;2;163;196;243:*.xz=38;2;163;196;243:*.zst=38;2;163;196;243'

# Match command highlighting and suggestions to the same palette.
ZSH_HIGHLIGHT_STYLES[command]='fg=#60a5fa'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#60a5fa'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#60a5fa'
ZSH_HIGHLIGHT_STYLES[function]='fg=#60a5fa'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#93c5fd'
ZSH_HIGHLIGHT_STYLES[path]='fg=#dce2ec,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a3c4f3'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a3c4f3'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#dbeafe'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5f6f94'

# fzf follows the terminal palette. bat already uses its ANSI theme.
typeset _green_fzf_colors='--color=fg:#dce2ec,bg:#16181d,hl:#60a5fa,fg+:#dbeafe,bg+:#1e2b45,hl+:#60a5fa,info:#8792a8,prompt:#60a5fa,pointer:#60a5fa,marker:#4fb3f9,spinner:#60a5fa,header:#93c5fd,border:#475a8b'
if [[ ${FZF_DEFAULT_OPTS-} != *"$_green_fzf_colors"* ]]; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }$_green_fzf_colors"
fi
unset _green_fzf_colors
