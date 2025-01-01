command Js normal :call Js()<cr>:echo "m-] to execute javascript"<cr>

func! Js()

nnoremap <silent> <m-]>      mPV"py:py3 voly.output()<cr>:redir @b<cr>:py3 exec(_jstrans(_jsfiltcode()))<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-]> <esc>mPV"py:py3 voly.output()<cr>:redir @b<cr>:py3 exec(_jstrans(_jsfiltcode()))<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-]>       mP"py:py3 voly.output()<cr>:redir @b<cr>:py3 exec(_jstrans(_jsfiltcode()))<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P

py3 << EOL
try:
    import js2py
    from js2py.pyjs import *
    _jsvar = Scope( JS_BUILTINS )
    set_global_object(_jsvar)
    def _jsfiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)
    def _jstrans(code):
        trans = js2py.translate_js(code)
        newcode = '\n'.join( trans.split('\n')[4:]  )
        return newcode
    def _jsget(varname):
        return _jsvar.get(varname).to_python()
    def _jsevexpr(expr):
        try:
            trans = js2py.translate_js(expr)
            lline = trans.split('\n')[-2]
            result = eval(lline).to_python()
            return result
        except Exception as e:
            return e
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    languagemgr.langlist.append("javascript")
    languagemgr.langevals.append(_jsevexpr)
except:
    print("js2py not installed")

EOL
endfunc


