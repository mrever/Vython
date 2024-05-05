command Octave normal :call Octave()<cr>

func! Octave()

nnoremap <silent> <m-;>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _oct.eval( octfiltcode() )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-;> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _oct.eval( octfiltcode() )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-;>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _oct.eval( octfiltcode() )<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

py3 << EOL
try:
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    os.environ['PYDEVD_DISABLE_FILE_VALIDATION'] = '1'
    from oct2py import Oct2Py
    _oct = Oct2Py()
    def octfiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)
    def octevexpr(expr):
        _oct.eval('_dum_ =' + expr + ';')
        return _oct.pull('_dum_')
    def octavecompleter(token=None):
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        #if not token:
        token = thisline[:oldcursposx]
        token = re.split(r';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
        completions = [] 
        try:
            ocompstr ='_ocomps = completion_matches("' + token + '")' 
            _oct.eval(ocompstr)
            ores = _oct.pull('_ocomps')
            len(ores)
            if len(ores) == 0:
                ocomps = []
            elif type(ores) == str:
                ocomps = [ores]
            else:
                ocomps = list(ores)
            completions += ocomps
            return completions
        except Exception as e:
            return []
    languagemgr.langlist.append("octave")
    languagemgr.langevals.append(octevexpr)
    languagemgr.langcompleters.append(octavecompleter)
except Exception as e:
    print("oct2py not installed or working")
    #print(e)
EOL

endfunc
