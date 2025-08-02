export BASH_SILENCE_DEPRECATION_WARNING=1

# Load .zshrc if it exists
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/tk/.sdkman"
[[ -s "/Users/tk/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/tk/.sdkman/bin/sdkman-init.sh"