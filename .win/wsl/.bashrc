if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
  source $HOME/.win/wsl/distro/ubuntu/.bashrc
else
  source $HOME/.win/wsl/distro/arch/.bashrc
fi

if [ -d "/opt/nvim" ] && [ -f "/opt/nvim/nvim" ]; then
  export PATH="$PATH:/opt/nvim"
fi

if [ ! -f $HOME/.inputrc ]; then
  echo 'set bell-style none' >~/.inputrc
fi

# 以下を関数化する
export_to_dynamic_bashrc() {
  if [ ! -f "$HOME/.dynamic_bashrc" ]; then
    echo "export NVIM_DISCORD_RICH_PRESENCE_IGNORE=true" >"$HOME/.dynamic_bashrc"
  else
    # もし、export NVIM_DISCORD_RICH_PRESENCE_IGNORE=trueがなければ、追加する。
    if ! grep -q "export NVIM_DISCORD_RICH_PRESENCE_IGNORE=true" "$HOME/.dynamic_bashrc"; then
      echo "export NVIM_DISCORD_RICH_PRESENCE_IGNORE=true" >>"$HOME/.dynamic_bashrc"
    fi
  fi
  source "$HOME/.dynamic_bashrc"
}

nvim() {
  # NVIM_DISCORD_RICH_PRESENCEが設定されていなければ
  if [ -z "$NVIM_DISCORD_RICH_PRESENCE_IGNORE" ]; then
    # neovimとdiscord-rich-presenceを連携するかどうか聞く。答えが、yもしくはY以外であれば、動的読み込み.dynamic_bashrcを$HOME内になければ作成し、export NVIM_DISCORD_RICH_PRESENCE_IGNORE=trueを追加する。そして、source ~/.dynamic_bashrcを実行する。
    read -p "Do you want to setup to enable Neovim Discord Rich Presence? (y/n): " answer
    if [[ "$answer" != [Yy] ]]; then
      export_to_dynamic_bashrc
      echo "Neovim Discord Rich Presence is disabled."
      command nvim "$@"
      return 0
    fi
    # もし、discordというコマンドが存在しなければ、Do you want to install it?と英語でプロンプトを出し、y/nでインストールする。Ubuntuなら、sudo snap install discord -y、それ以外なら、sudo pacman -Sy --noconfirm discordを実行する。また、neovimとdiscord-rich-presenceを連携させるためには、discordでログインしている必要があるので、それをechoで表示し、一度、returnする。
    if ! command -v discord >/dev/null 2>&1; then
      read -p "discord is not installed. Do you want to install it? (y/n): " answer
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
    read -p "Do you want to enable Discord to start automatically? (y/n): " answer
    if [[ "$answer" == [Yy] ]]; then
      mkdir -p ~/.config/systemd/user
      if [ -n "$WSL_DISTRO_NAME" ]; then
        if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
          cp ~/.win/wsl/distro/ubuntu/services/user/discord.service ~/.config/systemd/user/
        else
          cp ~/.win/wsl/distro/arch/services/user/discord.service ~/.config/systemd/user/
        fi
      else
        echo "WSL_DISTRO_NAME is not set. Please ensure you are running this script in WSL."
        return 1
      fi

      systemctl --user daemon-reload
      systemctl --user enable --now discord.service
    fi

    # もし、socatというコマンドが存在しなければ、Do you want to install it?と英語でプロンプトを出し、y/nでインストールする
    if ! command -v socat >/dev/null 2>&1; then
      read -p "socat is not installed. Do you want to install it? (y/n): " answer
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
      if ! command -v npiperelay.exe >/dev/null 2>&1; then
        read -p "npiperelay.exe is not installed. Do you want to install it? (y/n): " answer
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
    export_to_dynamic_bashrc
  fi

  if ! pidof socat >/dev/null 2>&1; then
    if [ -S /tmp/discord-ipc-0 ]; then
      rm /tmp/discord-ipc-0
    fi
    socat UNIX-LISTEN:/tmp/discord-ipc-0,fork EXEC:"npiperelay.exe //./pipe/discord-ipc-0" &
  fi

  # socatプロセスがまだ起動していない場合のみ、以下の処理を検討する
  if ! pidof socat >/dev/null 2>&1; then
    # Windows側でDiscord.exeが実行中かどうかをtasklist.exeで確認する
    # `2>/dev/null`でエラー出力を抑制し、`grep -iq`で大文字小文字を区別せずに行を検索
    if [ -e "//./pipe/discord-ipc-0" ]; then
      # Discordが実行中であれば、socatを起動する

      # 念のため、古いソケットファイルが残っていれば削除
      if [ -S /tmp/discord-ipc-0 ]; then
        rm /tmp/discord-ipc-0
      fi
      # WSLのUNIXソケットとWindowsの名前付きパイプを中継するためにsocatをバックグラウンドで起動
      socat UNIX-LISTEN:/tmp/discord-ipc-0,fork EXEC:"npiperelay.exe //./pipe/discord-ipc-0" &
    fi
  fi

  command nvim "$@"
}

if command -v win32yank.exe &>/dev/null; then
  alias wl-copy="win32yank.exe -i"
fi
