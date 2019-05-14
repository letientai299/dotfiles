#!/bin/sh

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_WATSON_SHOW="${SPACESHIP_WATSON_SHOW=true}"
SPACESHIP_FOOBAR_SYMBOL="${SPACESHIP_WATSON_SYMBOL="🔨 "}"
SPACESHIP_WATSON_PREFIX="${SPACESHIP_WATSON_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_WATSON_SUFFIX="${SPACESHIP_WATSON_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_WATSON_COLOR="${SPACESHIP_WATSON_COLOR="green"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show watson status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_watson() {
  # If SPACESHIP_WATSON_SHOW is false, don't show watson section
  [[ $SPACESHIP_WATSON_SHOW == false ]] && return

  # Check if watson command is available for execution
  spaceship::exists watson || return

  # Use quotes around unassigned local variables to prevent
  # getting replaced by global aliases
  # http://zsh.sourceforge.net/Doc/Release/Shell-Grammar.html#Aliasing
  local 'watson_status'
  watson_status=$(watson status | perl -pe 's/(Project | started.*\(.*\))//g')

  # Exit section if variable is empty
  [[ -z $watson_status ]] && return
  [[ $watson_status = 'No project started' ]] && return

  # Display watson section
  spaceship::section \
    "$SPACESHIP_WATSON_COLOR" \
    "$SPACESHIP_WATSON_PREFIX" \
    "$SPACESHIP_WATSON_SYMBOL$watson_status" \
    "$SPACESHIP_WATSON_SUFFIX"

}
