command Hy normal :call Hy()<cr>

func! Hy()

nnoremap <silent> <c-]>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 hy.eval( hy.reader.read(hyfiltcode()) )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <c-]> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 hy.eval( hy.reader.read(hyfiltcode()) )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <c-]>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 hy.eval( hy.reader.read(hyfiltcode()) )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

py3 << EOL

try:
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    import hy
    def hyfiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '(do ' + '\n'.join(code) + ' )'

    def hyeval(expr):
        try:
            _hyexpr = hy.eval( hy.reader.read(expr) )
            return _hyexpr
        except Exception as e:
            return e

    languagemgr.langlist.append("hy")
    languagemgr.langevals.append(hyeval)

except:
    print('hy not installed or working')

EOL
endfunc
