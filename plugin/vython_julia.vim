command Julia normal :call Julia()<cr>:echo "m-\\ to execute julia"<cr>

func! Julia()

nnoremap <silent> <m-\>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _jeval(juliafiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-\> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _jeval(juliafiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-\>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _jeval(juliafiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

py3 << EOL
try:
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    import vim
    from julia import Main as jumain

    nprint = '''
    import Base.print
    import Base.println
    pyoutstr = ""
    function apptxtout(txt)
    global pyoutstr *= string(txt)
    end
    function print(txt, args...; kwargs...)
    apptxtout(txt)
    for arg in args
    apptxtout(arg)
    end
    pyoutstr
    end
    function println(txt, args...; kwargs...)
    apptxtout(txt)
    for arg in args
    apptxtout(arg)
    end
    apptxtout("\n")
    pyoutstr
    end
    using REPL
    '''

    jumain.eval(nprint)
    def _resjprint():
        jumain.eval('pyoutstr = ""')
    _resjprint()

    def _jeval(jcode):
        _resjprint()
        julout = jumain.eval(jcode)
        out = jumain.eval('print("")')
        print(out)
        return julout

    def juliafiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)

    def juliacompleter(token=None):
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        #if not token:
        token = thisline[:oldcursposx]
        token = re.split(r';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
        completions = [] 
        try:
            jcompstr = 'jcompletions = REPL.REPLCompletions.completions("' + token +  '", ' + str(len(token)) + '); [string(jcompletions[1][i].mod) for i = 1:length(jcompletions[1])  ]'
            jcomps = jumain.eval(jcompstr)
            if token[-1] == '.':
                jcomps = [token + jc for jc in jcomps]
            completions += jcomps
            return completions
        except Exception as e:
            return []

    languagemgr.langlist.append("julia")
    languagemgr.langevals.append(_jeval)
    languagemgr.langcompleters.append(juliacompleter)

except Exception as e:
    print('julia bridge not installed or working')
    #print(e)
EOL
endfunc
