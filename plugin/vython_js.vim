command Js normal :call Js()<cr>:echo "m-] to execute javascript"<cr>

func! Js()

nnoremap <silent> <m-]>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(jstrans(jsfiltcode()))<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-]> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(jstrans(jsfiltcode()))<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-]>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(jstrans(jsfiltcode()))<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

py3 << EOL
try:
    import js2py
    from js2py.pyjs import *
    var = Scope( JS_BUILTINS )
    set_global_object(var)
    def jsfiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)
    def jstrans(code):
        trans = js2py.translate_js(code)
        newcode = '\n'.join( trans.split('\n')[4:]  )
        return newcode
    def jsget(varname):
        return var.get(varname).to_python()
    def jsevexpr(expr):
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
    languagemgr.langevals.append(jsevexpr)
except:
    print("js2py not installed")

EOL
endfunc


