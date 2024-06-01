command Wolfram normal :call Wolfram()<cr>
command WolframExit normal :py3 _wolfsession.terminate()<cr>

func! Wolfram()

nnoremap <silent> <m-w>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _wolfsession.evaluate(wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-w> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _wolfsession.evaluate(wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-w>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 _wolfsession.evaluate(wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

nnoremap <silent> <m-b>      mPV"py:py3 wolfprintexp()<cr>`P
inoremap <silent> <m-b> <esc>mPV"py:py3 wolfprintexp()<cr>`Pa
vnoremap <silent> <m-b>       mP"py:py3 wolfprintexp()<cr>`P

py3 << EOL
try:
    import vim
    import numpy as np
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
    def wolfcompletefuns(s):
        return [f for f in wolffunclist if len(f) >= len(s) and s == f[:len(s)]]
    def wolfcompleter(token=None):
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        #if not token:
        token = thisline[:oldcursposx]
        token = re.split(';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
        completions = wolfcompletefuns(token)
        return completions
    def wolfshow(istr, ext='png', tf=False, shownum=False):
        tfname = f"{vyth.hometmp}{np.random.randint(10000000)+hash(istr)}.{ext}"
        estr = f'tfname=\"{tfname}\"'
        wolfevexpr( estr )
        if tf:
            estr = f'Export[tfname, TraditionalForm[{istr}]]'
        else:
            estr = f'Export[tfname, {istr}]'
        wolfevexpr( estr )
        vyth.writebuffhtml(istr, br=1, shownum=shownum)
        if ext == 'wav':
            vyth.writebuffhtml(f'<audio controls><source src="{tfname}" type="audio/wav"></audio>',br=3)
        elif ext == 'tex':
            with open(tfname, 'r') as f:
                ltext = f.read().split('\n')
                lstrip = ' '.join(ltext[11:-2]).strip()[2:-2]
                lout = '\\(' + lstrip + '\\)'
                vyth.writebuffhtml('<br>'*2+ lout  +'<br>'*2)
        else:
            vyth.writebuffhtml(f'<a href=""><img src="{os.path.basename(tfname)}"></a>',br=3)
    def wolfshowtf(istr):
        wolfshow(istr, tf=True)
    def wolfaudio(istr):
        wolfshow(istr, ext='wav', tf=False)
    def wolftex(istr):
        wolfshow(istr, ext='tex', tf=True)
    def wolfprintexp():
        vyth.pybuf.append('')
        lines = vim.eval("@p").strip().split('\n')
        for thisline in lines:
            if ':=' in thisline:
                thisexp = thisline.split(':=')[0]
            else:
                thisexp = thisline.split('=')[0]
            try:
                if '==' in thisline:
                    thisexp = thisline
                if thisexp[-1] in '+-*/':
                    thisexp = thisexp[:-1]
                    if thisexp[-1] == '*':
                        thisexp = thisexp[:-1]
                if vyth.outhtml:
                    wolftex(thisexp)
                outstring = repr(wolfevexpr(thisexp))
                expout = thisexp.strip() + ' = ' + outstring
                [vyth.pybuf.append(exp) for exp in expout.split('\n')]
            except Exception as e:
                print(e)
                [vyth.pybuf.append(thisexp.split('=')[0].strip() + " is not defined.")]
            vyth.scrollbuffend()

    languagemgr.langlist.append("wolfram")
    languagemgr.langevals.append(wolfevexpr)
    languagemgr.langcompleters.append(wolfcompleter)

    vim.command('autocmd VimLeave * :py3 _wolfsession.terminate()')

except Exception as e:
    print("wolframclient not installed or working")
    print(e)


EOL
endfunc
