command! Sage normal :call Sage()<cr>
command! Sageoff normal :py3 _sage_On_ = False<cr>

func! Sage()
py3 << EOL
_sage_On_ = True
try:
    from sage.all import *
    def _sageparse(sagestr):
        return '\n'.join(preparse(sagestr).split('\n')[:])
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    languagemgr.langlist.append("sage")
    languagemgr.langevals.append(sage_eval)

    def filtcode():
        global _sage_On_
        voly.removeindent()
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        code = [q for q in code if q and len(q.strip())>0 and q.strip()[0]!='!']
        #try:
        parsedout = '\n'.join(code)
        if _coconut_On_:
            parsedout = cocoparse(parsedout)
        if _sage_On_:
            parsedout = _sageparse(parsedout)
        #except:
            #parsedout = ('\n'.join(code))
        return parsedout
except:
    _sageparse = lambda x: x
    print('sage not installed')

EOL
endfunc
