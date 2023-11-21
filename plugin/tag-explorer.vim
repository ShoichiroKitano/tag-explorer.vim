vim9script

var previousBuffer = 0
var searchedTagName = ''
var curpos = []

def JumpTag()
  var tagNumber = split(getline('.'))[0]
  exec printf(":buffer %d", previousBuffer)
  cursor(slice(curpos, 1, len(curpos)))
  exec printf(":%stag %s", tagNumber, searchedTagName)
  curpos = []
  previousBuffer = 0
  searchedTagName = ''
enddef

def TagExplorerExact()
  searchedTagName = expand('<cword>')
  var tags = taglist(printf("\\<%s\\>", searchedTagName))
  if empty(tags)
    return
  endif
  previousBuffer = bufnr("%") + 0
  curpos = getpos('.')

  execute 'silent keepjumps hide edit ' .. '[TagExplorer]'
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal wrap
  setlocal nolist
  setlocal nonumber
  setlocal modifiable

  var i = 1
  for tag in tags
    var cmd = tag['cmd']
    if cmd[1] == '^'
      cmd = slice(cmd, 2)
    else
      cmd = slice(cmd, 1)
    endif
    if cmd[len(cmd) - 2] == '$'
      cmd = slice(cmd, 0, len(cmd) - 2)
    else
      cmd = slice(cmd, 0, -1)
    endif
    cmd = substitute(cmd, "\t", ' ', 'g')
    setline(i, printf(" %2d\t%s\t%s", i, cmd, tag['filename']))
    i += 1
  endfor

  silent exec ":%!column -s $'\t' -t"

  setlocal nomodifiable

  nnoremap <script> <silent> <nowait> <buffer> <CR> :call <SID>JumpTag()<CR>
enddef

command! TagExplorerExact :call TagExplorerExact()
