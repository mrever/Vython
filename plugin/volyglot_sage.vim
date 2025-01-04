command! Sage normal :call Sage()<cr>
command! Sageoff normal :py3 voly.sage_On = False; voly.filtcode = _origfiltcode<cr>

func! Sage()
py3 << EOL
voly.sage_On = True
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

    def _sagefiltcode():
        voly.removeindent()
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        code = [q for q in code if q and len(q.strip())>0 and q.strip()[0]!='!']
        #try:
        parsedout = '\n'.join(code)
        if voly.coconut_On:
            parsedout = _cocoparse(parsedout)
        if voly.sage_On:
            parsedout = _sageparse(parsedout)
        #except:
            #parsedout = ('\n'.join(code))
        return parsedout
    voly.filtcode = _sagefiltcode
    print = voly._printbak
except:
    _sageparse = lambda x: x
    print('sage not installed')

EOL
endfunc
