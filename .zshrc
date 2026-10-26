
# Powerlevel10k is loaded below after plugins and keybindings.

# Match the live shell's history limits and sharing between sessions.
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Manual configuration
typeset -U path PATH
path=("$HOME/.local/bin" $path)
# Conservo estas rutas históricas como opcionales: no está documentado si
# volveré a usar esas herramientas. No añado directorios inexistentes al PATH.
for dotfiles_optional_bin in "$HOME/.local/bin/ctgen" "$HOME/go/bin" \
                             "$HOME/.cargo/bin" /opt/android-studio/bin; do
    [[ -d $dotfiles_optional_bin ]] && path+=("$dotfiles_optional_bin")
done
unset dotfiles_optional_bin
export PATH

# Manual aliases
alias exegol="$HOME/.local/bin/exegol"
alias xxx='exegol start hacking'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='bat'
alias catn='/usr/bin/cat'
alias vim='nvim'
export EDITOR=nvim
export VISUAL=nvim

# Optional completion for the pipx installation of Exegol.
if [[ -x "$HOME/.local/bin/exegol" ]] && (( $+commands[register-python-argcomplete] )); then
    autoload -Uz compinit
    compinit
    eval "$(register-python-argcomplete --no-defaults exegol)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh

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

# fzf improvement
function fzf-lovely(){

  if [ "$1" = "h" ]; then
    fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
                echo {} is a binary file ||
                 (bat --style=numbers --color=always {} ||
                  highlight -O ansi -l {} ||
                  coderay {} ||
                  rougify {} ||
                  cat {}) 2> /dev/null | head -500'

  else
          fzf -m --preview '[[ $(file --mime {}) =~ binary ]] &&
                           echo {} is a binary file ||
                           (bat --style=numbers --color=always {} ||
                            highlight -O ansi -l {} ||
                            coderay {} ||
                            rougify {} ||
                            cat {}) 2> /dev/null | head -500'
  fi
}

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.zshrc.
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize

# Keybindings
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

source ~/.powerlevel10k/powerlevel10k.zsh-theme
