" Windows
"$HOME/AppData/Local/nvim/vimrc
" Linux
" $HOME/.config/nvim/vimrc
let s:my_vimrc = expand('$HOME/.config/nvim/vimrc')
if filereadable(s:my_vimrc)
  execute 'source ' . s:my_vimrc
endif
