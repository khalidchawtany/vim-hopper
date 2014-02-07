if exists('g:hopper_loaded')
  finish
endif

function! hopper#search(direction)
  call search('\v^(\s*\zs)'.b:hopper_pattern, a:direction)
  call hopper#centralize()
endfunction

function! hopper#search_with_same_indentation(direction)
  call hopper#save_position()
  let indentation = indent('.')
  call hopper#search(a:direction)
  while !(indentation == indent('.'))
    call hopper#search(a:direction)
  endwhile
endfunction

function! hopper#search_with_changed_scoped(direction)
  call hopper#save_position()
  let operator = a:direction == 'b' ? '>' : '<'
  let indentation = indent('.')
  while eval('!(indentation '.operator.' indent("."))')
    call hopper#search(a:direction)
  endwhile
endfunction

function! hopper#go_to_last_hop()
  if exists('b:hopper_last_hop')
    let last_pos = b:hopper_last_hop
    call hopper#save_position()
    call setpos('.', last_pos)
    call hopper#centralize()
  endif
endfunction

function! hopper#centralize()
  if g:hopper_center_on_jump
    normal zz
  endif
endfunction

function! hopper#save_position()
  let b:hopper_last_hop = getpos('.')
endfunction

function! hopper#next()
  call hopper#save_position()
  call hopper#search('')
endfunction

function! hopper#prev()
  call hopper#save_position()
  call hopper#search('b')
endfunction

function! hopper#prev_outer()
  call hopper#search_with_changed_scoped('b')
endfunction

function! hopper#next_inner()
  call hopper#search_with_changed_scoped('')
endfunction

function! hopper#next_with_same_indentation()
  call hopper#search_with_same_indentation('')
endfunction

function! hopper#prev_with_same_indentation()
  call hopper#search_with_same_indentation('b')
endfunction

function! hopper#load_movement_mode()
  let filetypes = split(&ft, '\.')
  for ft in filetypes
    if index(g:hopper_filetype_modes, ft) > -1
      call b:load_hopper_by_filetype()
      call hopper#define_movement_mode()
      break
    endif
  endfor
endfunction

function! hopper#define_movement_mode()
  let mode_name = b:hopper_movement_mode_name.'-hopper'
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'j', ':call hopper#next()<cr>' )
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'k', ':call hopper#prev()<cr>')
  call submode#map(mode_name, 'n', '', 'j', ':call hopper#next()<cr>')
  call submode#map(mode_name, 'n', '', 'k', ':call hopper#prev()<cr>')
  call submode#map(mode_name, 'n', '', 'h', ':call hopper#prev_outer()<cr>')
  call submode#map(mode_name, 'n', '', 'l', ':call hopper#next_inner()<cr>')
  call submode#map(mode_name, 'n', '', 'J', ':call hopper#next_with_same_indentation()<cr>')
  call submode#map(mode_name, 'n', '', 'K', ':call hopper#prev_with_same_indentation()<cr>')
  call submode#map(mode_name, 'n', '', 'b', ':call hopper#go_to_last_hop()<cr>')
endfunction

function! hopper#load_support_modes()
  for support_mode in g:hopper_support_modes
    exec 'call hopper#load_'.support_mode.'()'
  endfor
endfunction

function! hopper#load_gitgutter()
  let mode = 'gitgutter'
  call submode#enter_with(mode, 'n', '', g:hopper_prefix.'g', '<nop>')

  let gitgutter_map = {
        \ 'j' : 'Next',
        \ 'k' : 'Prev',
        \ 'a' : 'Stage',
        \ 's' : 'Stage',
        \ 'u' : 'Revert',
        \ 'r' : 'Revert',
  \}

  for [k, c] in items(gitgutter_map)
    call submode#map(mode, 'n', '', k, ':GitGutter'.c.'Hunk<cr>')
  endfor

  if exists('g:loaded_fugitive')
    call submode#map(mode, 'n', '', 'c', ':Gcommit<cr>')
  endif
endfunction

function! hopper#load_speed()
  let mode = 'speed'
  call submode#enter_with(mode, 'nv', '', g:hopper_prefix.'s', '<nop>')
  call submode#map(mode, 'nv', '', 'j', '5j')
  call submode#map(mode, 'nv', '', 'k', '5k')
  call submode#map(mode, 'nv', '', 'J', '10j')
  call submode#map(mode, 'nv', '', 'K', '10k')
endfunction

if !exists('g:hopper_prefix')
  let g:hopper_prefix = '<esc>'
endif

if !exists('g:hopper_filetype_modes')
  let g:hopper_filetype_modes = ['ruby', 'vim']
endif

if !exists('g:hopper_support_modes')
  let g:hopper_support_modes = ['gitgutter', 'speed']
endif

if !exists('g:hopper_center_on_jump')
  let g:hopper_center_on_jump = 1
endif

if !exists('g:submode_timeoutlen')
  let g:submode_timeoutlen = 30000
endif

if !exists('g:submode_always_show_submode')
  let g:submode_always_show_submode = 1
endif

if !exists('g:submode_keep_leaving_key')
  let g:submode_keep_leaving_key = 1
endif

au Filetype * call hopper#load_movement_mode()
call hopper#load_support_modes()

let g:hopper_loaded = 1
