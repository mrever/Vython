command! R normal :call R()<cr>

func! R()

nnoremap <silent> <m-'>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 robjects.r( rfiltcode() )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-'> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 robjects.r( rfiltcode() )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-'>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 robjects.r( rfiltcode() )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

py3 << EOL
try:
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    import rpy2
    import rpy2.robjects as robjects
    def rfiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)
    def revexpr(expr):
        return robjects.r(expr)
    languagemgr.langlist.append("R")
    languagemgr.langevals.append(revexpr)
except Exception as e:
    print("rpy2 not installed or working")
    #print(e)
EOL
endfunc
