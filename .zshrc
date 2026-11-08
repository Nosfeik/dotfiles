
# Source Powerlevel10k theme for both users
if [[ -r /root/.powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /root/.powerlevel10k/powerlevel10k.zsh-theme
elif [[ -r /home/nosfeik/.powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /home/nosfeik/.powerlevel10k/powerlevel10k.zsh-theme
fi
# Maximum lines kept in memory
export HISTSIZE=100000
# Maximum lines saved to $HISTFILE
export SAVEHIST=100000
# Like INC_APPEND_HISTORY + re-read history whenever accessing it
setopt SHARE_HISTORY
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Manual configuration
PATH=/root/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/nosfeik/.local/bin/ctgen:/home/nosfeik/go/bin:/home/nosfeik/.cargo/bin:/opt/android-studio/bin:/usr/local/bin/platform-tools

# Manual aliases
alias xxx='exegol start hacking'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='bat'
alias catn='/usr/bin/cat'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 
source /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh

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

# Created by `pipx` on 2026-09-21 21:45:27
export PATH="/home/nosfeik/.local/bin:$PATH"
alias exegol="$HOME/.local/bin/exegol"
autoload -U compinit && compinit
eval "$(register-python-argcomplete --no-defaults exegol)"

# Neovim as the default editor.
alias vim='nvim'
export EDITOR=nvim
export VISUAL=nvim
