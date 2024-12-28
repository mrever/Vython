"" provide a way to execute vimscript from the buffer
""this works without python/volyglot
"nnoremap <silent> <m-enter> V"py:@p<cr>
"inoremap <silent> <m-enter> <esc>mPV"py:@p<cr>`Pa
"vnoremap <silent> <m-enter> mP"py:@p<cr>`P

""this requires python/volyglot, but has nicer output
nnoremap <silent> <m-enter>      mPV"py:py3 voly.output()<cr>:redir @b<cr>:@p<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-enter> <esc>mPV"py:py3 voly.output()<cr>:redir @b<cr>:@p<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-enter>       mP"py:py3 voly.output()<cr>:redir @b<cr>:@p<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P
