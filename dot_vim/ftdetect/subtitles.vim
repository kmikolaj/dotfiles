au BufNewFile,BufRead *.srt setf srt
au BufNewFile,BufRead *.sub setf sub
au BufNewFile,BufRead *.txt call s:FTsub()


function! s:FTsub()
  let n = 1
  while n < 5
    let line = getline(n)
    let n = n + 1
    if line =~ '{[0-9]\+}{[0-9]\+}.*$'
      continue
    else
      return
    endif
  endwhile
  setlocal ft=sub
endfunction

" vim: et sw=2 ts=2 sts=2:
