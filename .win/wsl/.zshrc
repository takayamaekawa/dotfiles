if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
  source $HOME/.win/wsl/distro/ubuntu/.zshrc
else
  source $HOME/.win/wsl/distro/arch/.zshrc
fi

if [ -d "/opt/nvim" ] && [ -f "/opt/nvim/nvim" ]; then
  export PATH="$PATH:/opt/nvim"
fi

if [ ! -f $HOME/.inputrc ]; then
  echo 'set bell-style none' >~/.inputrc
fi

# 以下を関数化する
export_to_dynamic_zshrc() {
  if [ ! -f "$HOME/.dynamic_zshrc" ]; then
    echo "export NVIM_DISCORD_RICH_PRESENCE_IGNORE=true" >"$HOME/.dynamic_zshrc"
  else
    # もし、export NVIM_DISCORD_RICH_PRESENCE_IGNORE=trueがなければ、追加する。
    if ! grep -q "export NVIM_DISCORD_RICH_PRESENCE_IGNORE=true" "$HOME/.dynamic_zshrc"; then
      echo "export NVIM_DISCORD_RICH_PRESENCE_IGNORE=true" >>"$HOME/.dynamic_zshrc"
    fi
  fi
  source "$HOME/.dynamic_zshrc"
}

nvim() {
  # NVIM_DISCORD_RICH_PRESENCEが設定されていなければ
  if [ -z "$NVIM_DISCORD_RICH_PRESENCE_IGNORE" ]; then
    # neovimとdiscord-rich-presenceを連携するかどうか聞く。答えが、yもしくはY以外であれば、動的読み込み.dynamic_zshrcを$HOME内になければ作成し、export NVIM_DISCORD_RICH_PRESENCE_IGNORE=trueを追加する。そして、source ~/.dynamic_zshrcを実行する。
    read "answer?Do you want to setup to enable Neovim Discord Rich Presence? (y/n): "
    if [[ "$answer" != [Yy] ]]; then
      export_to_dynamic_zshrc
      echo "Neovim Discord Rich Presence is disabled."
      command nvim "$@"
      return 0
    fi
    # もし、discordというコマンドが存在しなければ、Do you want to install it?と英語でプロンプトを出し、y/nでインストールする。Ubuntuなら、sudo snap install discord -y、それ以外なら、sudo pacman -Sy --noconfirm discordを実行する。また、neovimとdiscord-rich-presenceを連携させるためには、discordでログインしている必要があるので、それをechoで表示し、一度、returnする。
    if ! command -v discord >/dev/null 2>&1; then
      read "answer?discord is not installed. Do you want to install it? (y/n): "
      if [[ "$answer" == [Yy] ]]; then
        if [ -n "$WSL_DISTRO_NAME" ]; then
          if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
            sudo snap install discord -y
            echo "Discord is installed. Please log in to Discord before proceeding."
            return 1
          else
            sudo pacman -Sy --noconfirm discord
            echo "Discord is installed. Please log in to Discord before proceeding."
            return 1
          fi
        else
          echo "discord is required for this script to run. Exiting."
          return 1
        fi
      else
        echo "Discord is required for this script to run. Exiting."
        return 1
      fi
    fi

    # discordを自動起動するかどうかを尋ねる。
    # WSL環境では、ホストOSであるWindowsで起動しているDiscordを利用するため、WSL内での自動起動は不要。
    # read "answer?Do you want to enable Discord to start automatically? (y/n): "
    # if [[ "$answer" == [Yy] ]]; then
    #   mkdir -p ~/.config/systemd/user
    #   if [ -n "$WSL_DISTRO_NAME" ]; then
    #     if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
    #       cp ~/.win/wsl/distro/ubuntu/services/user/discord.service ~/.config/systemd/user/
    #     else
    #       cp ~/.win/wsl/distro/arch/services/user/discord.service ~/.config/systemd/user/
    #     fi
    #   else
    #     echo "WSL_DISTRO_NAME is not set. Please ensure you are running this script in WSL."
    #     return 1
    #   fi

    #   systemctl --user daemon-reload
    #   systemctl --user enable --now discord.service
    # fi

    # もし、socatというコマンドが存在しなければ、Do you want to install it?と英語でプロンプトを出し、y/nでインストールする
    if ! command -v socat >/dev/null 2>&1; then
      read "answer?socat is not installed. Do you want to install it? (y/n): "
      if [[ "$answer" == [Yy] ]]; then
        if [ -n "$WSL_DISTRO_NAME" ]; then
          if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
            sudo apt install socat -y
          else
            sudo pacman -Sy --noconfirm socat
          fi
        else
          echo "socat is required for this script to run. Exiting."
          return 1
        fi
      fi

      # もし、npirelay.exeが存在しなければ、Do you want to install it?と英語でプロンプトを出し、y/nでインストールする。インストール元は、https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_386.zip とし、それをunzipで解凍し、中には、LICENSE、README.md、npiperelay.exeがあるので、npirelay.exeのみを~/.global/binへコピーする。なお、解凍にあたり、UUIDより一時ディレクトリを作成し、そこに解凍するとよいかも。終わったら、その一時ディレクトリは削除すればよい。
      if ! which npiperelay.exe >/dev/null 2>&1; then
        read "answer?npiperelay.exe is not installed. Do you want to install it? (y/n): "
        if [[ "$answer" == [Yy] ]]; then
          temp_dir=$(mktemp -d)
          wget -q https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_386.zip -O "$temp_dir/npiperelay.zip"
          if [ $? -ne 0 ]; then
            echo "Failed to download npiperelay. Please check your internet connection."
            rm -rf "$temp_dir"
            return 1
          fi
          unzip -q "$temp_dir/npiperelay.zip" -d "$temp_dir"
          if [ $? -ne 0 ]; then
            echo "Failed to unzip npiperelay. Please ensure you have unzip installed."
            rm -rf "$temp_dir"
            return 1
          fi
          if [ -d "$HOME/.global/bin" ]; then
            cp "$temp_dir/npiperelay.exe" "$HOME/.global/bin/"
            if [ $? -ne 0 ]; then
              echo "Failed to copy npiperelay.exe to ~/.global/bin. Please check permissions."
              rm -rf "$temp_dir"
              return 1
            fi
          else
            echo "~/.global/bin does not exist. Please create it first."
            rm -rf "$temp_dir"
            return 1
          fi
          rm -rf "$temp_dir"
        else
          echo "npiperelay.exe is required for this script to run. Exiting."
          return 1
        fi
      fi
    fi

    # セットアップが完了したため、次回、このスクリプトを実行する際には、NVIM_DISCORD_RICH_PRESENCE_IGNOREが設定されているので、セットアップをスキップする。
    export_to_dynamic_zshrc
  fi

  # reference: https://github.com/vyfor/cord.nvim/wiki/Troubleshooting#-running-inside-wsl
  # reference: https://gist.github.com/mousebyte/af45cbecaf0028ea78d0c882c477644a#aliasing-nvim
  if ! pidof socat >/dev/null 2>&1; then
    [ -e /tmp/discord-ipc-0 ] && rm -f /tmp/discord-ipc-0
    socat UNIX-LISTEN:/tmp/discord-ipc-0,fork \
      EXEC:"npiperelay.exe //./pipe/discord-ipc-0" 2>/dev/null &
  fi

  command nvim "$@"
}

if command -v win32yank.exe &>/dev/null; then
  alias wl-copy="win32yank.exe -i"
fi

if [ -d "$HOME/.win/wsl/bin" ]; then
  export PATH="$PATH:$HOME/.win/wsl/bin"
fi