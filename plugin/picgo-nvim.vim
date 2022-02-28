" @author      : aero (2254228017@qq.com)
" @file        : picgo-nvim
" @created     : 星期日 2月 27, 2022 16:09:20 CST 
" @github      : https://github.com/denstiny
" @blog        : https://denstiny.github.io

function s:Init() abort
  function! s:optdef(argument, default)
    if !has_key(g:, a:argument) | let g:{a:argument} = a:default | endif
  endfunction

  "==============================================
  " 启动插件
  call s:optdef("picgo_start", v:false)
  " 自动转换地址
  call s:optdef("picgo_auto_path", v:false)
  " 运行启动的文件类型
  call s:optdef("picgo_run_list", [''])
  call s:optdef("picgo_server", {'遇见图床':{'url':'https://www.hualigs.cn/api/upload','token':'eaa4eb11884f7a60e03f5c2eab3161c8'},'牛图网':{'url':'https://www.niupic.com/api/upload','token':'xxxx'}})

  "==============================================
  command! -nargs=1 -complete=file UpdateImagePath call s:UpdateHiddenSymbols("<args>")
endfunction
call s:Init()
"==============================================
let s:py_file = expand('<sfile>:p:h') . '/../script/imagePost.py' 
if has('python3')
  let s:python_executable = 'python'
elseif has('python')
  let s:python_executable = 'python3'
else
  echo "No \"python\" provider found"
endif
if !g:picgo_start
  nmap <silent><A-p> :call UpdateImageX()<cr> " 上传剪切板图片
  vmap <silent><A-o> :call UpdateImageR()<cr> " 上传指定位置图片
endif
let s:xclip_start = v:false

"==============================================
function! s:picgo_output(jobpid,data,event) abort
  if !empty(a:data)
    echo a:data
  endif
endfunction
let s:line = v:false
let s:g__ = ' '

"==============================================
function! s:on_stdout(id,data,event) abort
  if len(s:g__) > 1
    return
  else
    let s:g__ = join(a:data,' ')
  endif
endfunction
"==============================================
function s:on_exit(id,data,event) abort
  if len(s:g__) > 1
    call append(s:line, s:g__)
    echo ""
  endif
  let s:g__ = ' '
endfunction
"==============================================
function! s:on_stderr(id,data,event) abort
  if len(s:g__) > 1
    return
  else
    let s:g__ = join(a:data,' ')
  endif
endfunction

"==============================================
"=== 有一说一代码改抄还得抄,节省时间干别的 ====
function! s:get_visual_selection()
  let s:line = line('.')
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  call UpdateHiddenSymbols()
  return join(lines, '')
endfunction
"==============================================
function! s:UpdateHiddenSymbols(argcomment) abort
  echo "Ready to upload ..."
  let s:line = line('.')
  let s:loop = s:py_file
  let s:callbacks = {
        \ 'on_stdout':function('s:on_stdout'),
        \ 'on_stderr':function('s:on_stderr'),
        \ 'on_exit':function('s:on_exit')
        \}
  if a:argcomment == v:false
    call jobstart([s:python_executable,s:loop],s:callbacks)
  else
    call jobstart([s:python_executable,s:loop,a:argcomment],s:callbacks)
  endif
endfunction
"==============================================
function g:UpdateImageR() abort
  let s:xclip_start = v:false
  let s:virtual_line = s:get_visual_selection()
  call s:UpdateHiddenSymbols(s:virtual_line)
endfunction
"==============================================
function g:UpdateImageX() abort
  let s:xclip_start = v:true
  call s:UpdateHiddenSymbols(v:false)
endfunction
"==============================================
