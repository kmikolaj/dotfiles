setlocal ai ts=4 sts=4 et sw=4
"setlocal foldmethod=indent
"setlocal foldnestmax=2
setlocal makeprg=pylint\ --reports=n\ --output-format=parseable\ %:p
setlocal efm=%A%f:%l:\ [%t%.%#]\ %m,%Z%p^^,%-C%.%#
noremap <buffer> <F3> :SyntasticCheck<CR>
