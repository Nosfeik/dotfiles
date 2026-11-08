# Blazepwn: match the host terminal's mint palette.
() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs prompt_char)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(exegol_context)
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND='#60a5fa'
  typeset -g POWERLEVEL9K_OS_ICON_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='hacking'

  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#60a5fa'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#8792a8'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#4fb3f9'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#60a5fa'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#a3c4f3'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#93c5fd'

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#60a5fa'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#dbeafe'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  # Exegol runs initialization commands that may write to the terminal.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # Preserve Exegol's selected user/domain and session recording indicator.
  function prompt_exegol_context() {
    local context=${USER:-}
    [[ -z $context || -z ${DOMAIN:-} ]] || context+="@${DOMAIN}"
    [[ -z ${LOGGING:-} ]] || context="${LOGGING} ${context}"
    [[ -z $context ]] || p10k segment -f '#8792a8' -t "${context//\%/%%}"
    return 0
  }

  (( ! $+functions[p10k] )) || p10k reload
}
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
