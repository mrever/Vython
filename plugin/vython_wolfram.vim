command Wolfram normal :call Wolfram()<cr>
command WolframExit normal :py3 _wolfsession.terminate()<cr>

func! Wolfram()

nnoremap <silent> <m-w>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _wolfsession.evaluate(wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-w> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _wolfsession.evaluate(wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-w>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _wolfsession.evaluate(wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

py3 << EOL
try:
    import vim
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    from wolframclient.evaluation import WolframLanguageSession
    from wolframclient.deserializers import WXFConsumerNumpy
    from wolframclient.serializers import export as _wlexport
    _wolfsession = WolframLanguageSession(consumer=WXFConsumerNumpy)
    #from wolframclient.language import wl, wlexpr
    def wolffiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)
    def wolfevexpr(expr):
        return _wolfsession.evaluate(expr)
    def wolfsetvar(vname, dat):
        if type(dat) == np.ndarray:
            outdat = dat.tolist()
        else:
            outdat = dat
        ostr = _wlexport(outdat).decode()
        cstr = f"{vname}:={ostr}"
        wolfevexpr(cstr)
    _wtemp = '''firstletters = {"A*", "$A*", "B*", "$B*", "C*", "$C*", "D*", "$D*", 
"E*", "$E*", "F*", "$F*", "G*", "$G*", "H*", "$H*", "I*", "$I*", 
"J*", "$J*", "K*", "$K*", "L*", "$L*", "M*", "$M*", "N*", "$N*", 
"O*", "$O*", "P*", "$P*", "Q*", "$Q*", "R*", "$R*", "S*", "$S*", 
"T*", "$T*", "U*", "$U*", "V*", "$V*", "W*", "$W*", "X*", "$X*", 
"Y*", "$Y*", "Z*", "$Z*"};
functionslist = Flatten[Names[#] & /@ firstletters]; '''
    wolfevexpr(_wtemp)
    wolffunclist = list(wolfevexpr('functionslist'))
    def wolfsearchfuns(s):
        return [f for f in wolffunclist if s.lower() in f.lower()]
    def wolfcompleter(token=None):
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        #if not token:
        token = thisline[:oldcursposx]
        token = re.split(';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
        completions = wolfsearchfuns(token)
        return completions
    def wolfshow(istr, ext='png', tf=False):
        tfname = f"{vyth.hometmp}{np.random.randint(10000000)+hash(istr)}.{ext}"
        estr = f'tfname=\"{tfname}\"'
        wolfevexpr( estr )
        if tf:
            estr = f'Export[tfname, TraditionalForm[{istr}]]'
        else:
            estr = f'Export[tfname, {istr}]'
        wolfevexpr( estr )
        vyth.writebuffhtml(istr, br=1)
        if ext == 'wav':
            vyth.writebuffhtml(f'<audio controls><source src="{tfname}" type="audio/wav"></audio>',br=3)
        else:
            vyth.writebuffhtml(f'<a href=""><img src="{os.path.basename(tfname)}"></a>',br=3)
    def wolfshowtf(istr):
        wolfshow(istr, tf=True)
    def wolfaudio(istr):
        wolfshow(istr, ext='wav', tf=False)

    languagemgr.langlist.append("wolfram")
    languagemgr.langevals.append(wolfevexpr)
    languagemgr.langcompleters.append(wolfcompleter)

    vim.command('autocmd VimLeave * :py3 _wolfsession.terminate()')

except Exception as e:
    print("wolframclient not installed or working")
    #print(e)


EOL
endfunc
