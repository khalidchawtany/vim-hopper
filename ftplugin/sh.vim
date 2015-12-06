function! Load_hopper_by_filetype()
  let b:hopper_pattern = '\w+\s?\(\)\s*(\{\s*|\{.*\}\s*)$'
  let b:hopper_movement_mode_name = 'sh'
endfunction

function! Hop_to_special_end()
  normal! f{
  normal %
endfunction
