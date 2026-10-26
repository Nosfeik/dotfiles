# Green Black: same palette as the host terminal.
# Green Black: mint green folder/file colors for lsd and GNU ls.
# Bright mint folders and executables; softer green text and metadata.
export LS_COLORS='rs=0:fi=38;2;168;213;191:di=38;2;0;230;154:ln=38;2;82;245;197:or=38;2;213;255;233:mi=38;2;213;255;233:ex=38;2;67;227;167:pi=38;2;101;223;179:so=38;2;101;223;179:bd=38;2;139;213;169:cd=38;2;139;213;169:su=38;2;213;255;233:sg=38;2;139;213;169:tw=38;2;0;230;154:ow=38;2;0;230;154:st=38;2;0;230;154:mh=38;2;168;213;191:*.zip=38;2;139;213;169:*.tar=38;2;139;213;169:*.gz=38;2;139;213;169:*.7z=38;2;139;213;169:*.rar=38;2;139;213;169:*.xz=38;2;139;213;169:*.zst=38;2;139;213;169'

# Match command highlighting and suggestions to the same palette.
ZSH_HIGHLIGHT_STYLES[command]='fg=#00e69a'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#00e69a'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00e69a'
ZSH_HIGHLIGHT_STYLES[function]='fg=#00e69a'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#65dfb3'
ZSH_HIGHLIGHT_STYLES[path]='fg=#a8d5bf,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#8bd5a9'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#8bd5a9'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#d5ffe9'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#58856e'

# fzf follows the terminal palette. bat already uses its ANSI theme.
typeset _green_fzf_colors='--color=fg:#a8d5bf,bg:#101010,hl:#00e69a,fg+:#d5ffe9,bg+:#163a2c,hl+:#00e69a,info:#6b9e87,prompt:#00e69a,pointer:#00e69a,marker:#43e3a7,spinner:#00e69a,header:#65dfb3,border:#426651'
if [[ ${FZF_DEFAULT_OPTS-} != *"$_green_fzf_colors"* ]]; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }$_green_fzf_colors"
fi
unset _green_fzf_colors
