export BASH_SILENCE_DEPRECATION_WARNING=1

# Load .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/tk/.sdkman"
[[ -s "/Users/tk/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/tk/.sdkman/bin/sdkman-init.sh"
