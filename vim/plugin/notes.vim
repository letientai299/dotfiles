" Helper function to help taking daily notes
" Requires a $NOTE env configured to a folder.
function NoteToday() abort
  let l:note_path = $NOTE . '/diary/' . strftime('%Y') . '/' . strftime('%Y-%m-%d') . '.md'
  if !filereadable(l:note_path)
    " Create the necessary directories
    call mkdir(fnamemodify(l:note_path, ':h'), 'p')
    " Create the file, and write the h1 header, followed by an empty line
    call writefile(['# ' . strftime('%Y-%m-%d') . ' - ' . strftime('%A'), ''], l:note_path)
  endif

  " Append a h2 header with the current time to the end of the file,
  " follow with a new line
  call writefile(['## ' . strftime('%H:%M'), ''], l:note_path, 'a')

  " Open the file and the move cursor to the end
  execute 'edit ' . l:note_path
  normal! G
endfunction

" register the function to be callable via ex command
command! NoteToday call NoteToday()
