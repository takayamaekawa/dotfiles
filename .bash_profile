export BASH_SILENCE_DEPRECATION_WARNING=1

# Load .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/tk/.sdkman"
[[ -s "/Users/tk/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/tk/.sdkman/bin/sdkman-init.sh"

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/tk/.lmstudio/bin"
# End of LM Studio CLI section

