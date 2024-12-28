command Wolfram normal :call Wolfram()<cr>:echo "m-w to execute WolframLanguage"<cr>
command WolframExit normal :py3 vywolf.session.terminate()<cr>

func! Wolfram()

nnoremap <silent> <m-w>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 vywolf.session.evaluate(vywolf.wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-w> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 vywolf.session.evaluate(vywolf.wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-w>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 vywolf.session.evaluate(vywolf.wolffiltcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

nnoremap <silent> <m-b>      mPV"py:py3 vywolf.wolfprintexp()<cr>`P
inoremap <silent> <m-b> <esc>mPV"py:py3 vywolf.wolfprintexp()<cr>`Pa
vnoremap <silent> <m-b>       mP"py:py3 vywolf.wolfprintexp()<cr>`P

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
    import wolframclient
    class vython_wolfram:
        def __init__(self):
            from wolframclient.evaluation import WolframLanguageSession
            from wolframclient.deserializers import WXFConsumerNumpy
            from wolframclient.serializers import export as _wlexport
            #from wolframclient.language import wl, wlexpr
            _wolfsession = WolframLanguageSession(consumer=WXFConsumerNumpy)
            self.WolframLanguageSession = WolframLanguageSession
            self.WXFConsumerNumpy = WXFConsumerNumpy
            self.wlexport = _wlexport
            self.session = _wolfsession
            _wtemp = '''firstletters = {"A*", "$A*", "B*", "$B*", "C*", "$C*", "D*", "$D*", 
        "E*", "$E*", "F*", "$F*", "G*", "$G*", "H*", "$H*", "I*", "$I*", 
        "J*", "$J*", "K*", "$K*", "L*", "$L*", "M*", "$M*", "N*", "$N*", 
        "O*", "$O*", "P*", "$P*", "Q*", "$Q*", "R*", "$R*", "S*", "$S*", 
        "T*", "$T*", "U*", "$U*", "V*", "$V*", "W*", "$W*", "X*", "$X*", 
        "Y*", "$Y*", "Z*", "$Z*"};
        functionslist = Flatten[Names[#] & /@ firstletters]; '''
            self.wolfevexpr(_wtemp)
            self.wolffunclist = list(self.wolfevexpr('functionslist'))
        def wolffiltcode(self):
            code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
            return '\n'.join(code)
        def wolfevexpr(self, expr):
            return self.session.evaluate(expr)
        def wolfsetvar(self, vname, dat=None):
            if dat is None:
                dat = eval(vname)
            if type(dat) == np.ndarray:
                outdat = dat.tolist()
            else:
                outdat = dat
            ostr = self.wlexport(outdat).decode()
            cstr = f"{vname}:={ostr}"
            self.wolfevexpr(cstr)
        def wolfsetvars(self): # first attempt, will produce lots of warnings
            wtypes = [int, float, bool, np.ndarray, tuple, list, str, np.matrix] #list
            for k in globals().keys():
                # print(k, type(globals()[k]), type(globals()[k]) in wtypes)
                if type(globals()[k]) in wtypes:
                    self.wolfsetvar(k)
        def wolfsearchfuns(self, s):
            return [f for f in self.wolffunclist if s.lower() in f.lower()]
        def wolfcompletefuns(self, s):
            return [f for f in self.wolffunclist if len(f) >= len(s) and s == f[:len(s)]]
        def wolfcompleter(self, token=None):
            oldcursposy, oldcursposx = vim.current.window.cursor
            thisline = vim.current.line
            #if not token:
            token = thisline[:oldcursposx]
            token = re.split(r';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
            completions = self.wolfcompletefuns(token)
            return completions
        def wolfshow(self, istr, ext='png', tf=False, shownum=False):
            #vyth.vimdebug()
            tfname = f"{vyth.hometmp}{np.random.randint(10000000)+hash(istr)}.{ext}"
            estr = f'tfname=\"{tfname}\"'
            self.wolfevexpr( estr )
            if tf:
                estr = f'Export[tfname, TraditionalForm[{istr}]]'
            else:
                estr = f'Export[tfname, {istr}]'
            self.wolfevexpr( estr )
            vyth.writebuffhtml(istr, br=1, shownum=shownum)
            if ext == 'wav':
                vyth.writebuffhtml(f'<audio controls><source src="{tfname}" type="audio/wav"></audio>',br=3, pre=False)
            elif ext == 'tex':
                with open(tfname, 'r') as f:
                    ltext = f.read().split('\n')
                    lstrip = ' '.join(ltext[11:-2]).strip()[2:-2]
                    lout = '\\(' + lstrip + '\\)'
                    vyth.writebuffhtml('<br>'*2+ lout + '<br>'*2, pre=False)
            else:
                vyth.writebuffhtml(f'<a href=""><img src="{os.path.basename(tfname)}"></a>',br=3, pre=False)
        def wolfshowtf(self, istr):
            self.wolfshow(istr, tf=True)
        def wolfaudio(self, istr):
            self.wolfshow( istr, ext='wav', tf=False)
        def wolftex(self, istr):
            self.wolfshow(istr, ext='tex', tf=True)
        def wolfprintexp(self):
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
                    if self.wolfevexpr(f'Head @ {thisexp}') == wolframclient.language.expression.WLSymbol('Sound'):
                        self.wolfaudio(thisexp)
                        return
                    if self.wolfevexpr(f'Head @ {thisexp}') == wolframclient.language.expression.WLSymbol('Graphics'):
                        self.wolfshow(thisexp)
                        return
                    if vyth.outhtml:
                        self.wolftex(thisexp)
                    outstring = repr(self.wolfevexpr(thisexp))
                    expout = thisexp.strip() + ' = ' + outstring
                    [vyth.pybuf.append(exp) for exp in expout.split('\n')]
                except Exception as e:
                    print(e)
                    [vyth.pybuf.append(thisexp.split('=')[0].strip() + " is not defined.")]
                vyth.scrollbuffend()
    vywolf = vython_wolfram()

    languagemgr.langlist.append("wolfram")
    languagemgr.langevals.append(vywolf.wolfevexpr)
    languagemgr.langcompleters.append(vywolf.wolfcompleter)

    vim.command('autocmd VimLeave * :py3 vywolf.session.terminate()')

except Exception as e:
    print("wolframclient not installed or working")
    print(e)


EOL
endfunc
