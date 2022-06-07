if has('python3')

let $PYPLUGPATH .= expand('<sfile>:p:h') "used to import .py files from plugin directory

command! Vython normal  :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr>:sp<cr>:e test.py<cr><c-w><c-h>
nnoremap <silent> <F10> :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr>:sp<cr>:e test.py<cr><c-w><c-h>

func! Vythonload()

nnoremap <silent> <F5>      mPggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <F5> <esc>mPggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <F5> mP<esc>ggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P

nnoremap <silent> <s-enter>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <s-enter> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <s-enter>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"alternate mappings for terminal/ssh usage
nnoremap <silent> <c-\>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <c-\> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <c-\>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P

" If you want to be able to use languages other than Python...
" Python will still work even if you don't have these other languages/environments.
" But everything still requires Python to be set up properly
"
"hy, coconut, ans js2py require their respective Python packages to be
"installed (pip install hy/coconut/js2py should be fine)
"hy support
command! Coconut normal :py3 _coconut_On_    = True<cr>
command! Coconutoff normal :py3 _coconut_On_ = False<cr>
nnoremap <silent> <c-]>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 hy.eval( hy.read_str(hyfiltcode()) )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <c-]> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 hy.eval( hy.read_str(hyfiltcode()) )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <c-]>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 hy.eval( hy.read_str(hyfiltcode()) )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"js2py support
nnoremap <silent> <m-]>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(jstrans(jsfiltcode()))<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-]> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(jstrans(jsfiltcode()))<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-]>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(jstrans(jsfiltcode()))<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"Julia, Octave, and R require their respective packages to be installed
" (pip install julia/oc2py/rpy2) as well as their interpreters (you need Julia
" on your system to run Julia here).  Consult the documentation for those
" packages for more details.
"julia support
nnoremap <silent> <m-\>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 _jeval(juliafiltcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-\> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 _jeval(juliafiltcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-\>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 _jeval(juliafiltcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"octave support
nnoremap <silent> <m-;>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 _oct.eval( octfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-;> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 _oct.eval( octfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-;>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 _oct.eval( octfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"R support
nnoremap <silent> <m-'>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 robjects.r( rfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-'> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 robjects.r( rfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-'>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 robjects.r( rfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"
""APL support
"nnoremap <silent> <m-,>      mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 apl.eval( aplfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"inoremap <silent> <m-,> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 apl.eval( aplfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
"vnoremap <silent> <m-,>       mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 apl.eval( aplfiltcode() )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P


nnoremap <silent> <c-b>      mPV"py:py3 mout.printexp()<cr>`P
inoremap <silent> <c-b> <esc>mPV"py:py3 mout.printexp()<cr>`Pa
vnoremap <silent> <c-b>       mP"py:py3 mout.printexp()<cr>`P
"alternate mappings for tmux users
nmap <m-b> <c-b>
imap <m-b> <c-b>
vmap <m-b> <c-b>

inoremap <c-u> <C-R>=Pycomplete()<CR>

func! Pycomplete()
    py3 vim.command("call complete(col(\'.\'), " + repr(get_completions()) + ')')
    return ''
endfunc


py3 << EOL
import vim
import sys
import os
import re
import threading
import numpy as np
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

class _blank: pass
languagemgr = _blank()
languagemgr.list = []


try:
    import hy
    languagemgr.list.append('hy')
except:
    hy = _blank()
    def _dumfun(*args, **kwargs): pass
    hy.read_Str = _dumfun
    hy.eval = _dumfun
    print('hy not installed')

try:
    import sys as _coconut_sys
    from coconut.__coconut__ import *
    from coconut.__coconut__ import _coconut_tail_call, _coconut_tco, _coconut_call_set_names, _coconut_handle_cls_kwargs, _coconut_handle_cls_stargs, _coconut, _coconut_MatchError, _coconut_igetitem, _coconut_base_compose, _coconut_forward_compose, _coconut_back_compose, _coconut_forward_star_compose, _coconut_back_star_compose, _coconut_forward_dubstar_compose, _coconut_back_dubstar_compose, _coconut_pipe, _coconut_star_pipe, _coconut_dubstar_pipe, _coconut_back_pipe, _coconut_back_star_pipe, _coconut_back_dubstar_pipe, _coconut_none_pipe, _coconut_none_star_pipe, _coconut_none_dubstar_pipe, _coconut_bool_and, _coconut_bool_or, _coconut_none_coalesce, _coconut_minus, _coconut_map, _coconut_partial, _coconut_get_function_match_error, _coconut_base_pattern_func, _coconut_addpattern, _coconut_sentinel, _coconut_assert, _coconut_mark_as_match, _coconut_reiterable, _coconut_self_match_types, _coconut_dict_merge, _coconut_exec
    from coconut.convenience import parse as _cocoparsetemp
    def cocoparse(cocostr):
        return '\n'.join(_cocoparsetemp(cocostr).split('\n')[6:])
    languagemgr.list.append('coconut')
except:
    cocoparse = lambda x: x
    print('coconut not installed')

# javascript to py stuff
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
        trans = js2py.translate_js(expr)
        lline = trans.split('\n')[-2]
        result = eval(lline).to_python()
        return result
    languagemgr.list.append('javascript')
except:
    print("js2py not installed")
# end javascript to py stuff

#julia stuff
try:
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
    languagemgr.list.append('julia')
except:
    print('julia bridge not installed or working')
#end julia stuff


# octave oct2py
try:
    from oct2py import Oct2Py
    _oct = Oct2Py()
    def octfiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)
    def octevexpr(expr):
        _oct.eval('_dum_ =' + expr + ';')
        return _oct.pull('_dum_')
    languagemgr.list.append('octave')
except:
    print("oct2py not installed or working")
# end octave stuff

# R rpy2
try:
    import rpy2
    import rpy2.robjects as robjects
    def rfiltcode():
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        return '\n'.join(code)
    def revexpr(expr):
        return robjects.r(expr)
    languagemgr.list.append('R')
except:
    print("rpy2 not installed or working")
# end R stuff

# # pynapl Python APL bridge
# try:
    # from pynapl import APL
    # apl = APL.APL()
    # def aplfiltcode():
        # code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        # return '\n'.join(code)
    # def aplevexpr(expr):
        # return apl.eval(expr)
    # languagemgr.list.append('apl')
# except:
    # print("pynapl not installed or working")
# # end APL stuff

# try to evaluate expressions for different languages
def pjeval(expr):
    try: 
        return eval(expr)
    except Exception as e:
        pass
    if 'hy' in languagemgr.list:
        try:
             return hy.eval( hy.read_str(expr) )
        except:
             pass
    if 'julia' in languagemgr.list:
        try:
            return jumain.eval(expr)
        except Exception as e:
            pass
    if 'javascript' in languagemgr.list:
        try:
            return jsevexpr(expr)
        except Exception as e:
            pass
    if 'octave' in languagemgr.list:
        try:
            return octevexpr(expr)
        except Exception as e:
            pass
    if 'R' in languagemgr.list:
        try:
            return revexpr(expr)
        except Exception as e:
            pass
    if 'apl' in languagemgr.list:
        try:
            return apl.eval(expr)
        except Exception as e:
            pass


#work-around for Python3.7/tensorflow
if not hasattr(vim, 'find_module'):
    def _dumfun(*args, **kwargs): pass
    vim.find_module = _dumfun

sys.argv = ['']
sys.path.append('.') #might be needed to import from current directory
sys.path.append(os.environ['PYPLUGPATH']) # might be needed to import from plugin directory
#on Windows, this is needed for qt stuff like pyplot
os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = sys.exec_prefix.replace('\\','/') + '/Library/plugins/platforms'

if os.getcwd().lower() == 'C:\\WINDOWS\\system32'.lower():
    os.chdir(os.path.expanduser('~'))


_coconut_On_ = False
def filtcode():
    global _coconut_On_
    mout.removeindent()
    code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
    if 'fconv' in globals():
        code = [q if q.strip()[0]!='!' else fconv(q) for q in code]
    else:
        code = [q for q in code if q and len(q.strip())>0 and q.strip()[0]!='!']
    #try:
    if _coconut_On_:
        parsedout = cocoparse('\n'.join(code))
    else:
        parsedout = ('\n'.join(code))
    #except:
        #parsedout = ('\n'.join(code))
    return parsedout

def hyfiltcode():
    code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
    return '(do ' + '\n'.join(code) + ' )'


class outputter():
    def __init__(vyself):
        vyself.linecount = 1
        vyself.pybuf = vim.current.buffer
        vyself.pywin = vim.current.window
        vyself.oldlinecount = 0
        vyself.languages = ['python']
        lappend = vyself.languages.append
        vyself.languages += languagemgr.list
        # if 'js2py' in globals():
            # lappend('javascript')
        # if 'hy' in globals():
            # lappend('hy')
        # if 'coconut' in globals():
            # lappend('coconut')
        # if 'julia' in globals():
            # lappend('julia')
        # if 'oct2py' in globals():
            # lappend('octave')
        # if 'rpy2' in globals():
            # lappend('r')

    def output(vyself):
        vyself.pybuf.append('')
        vyself.pybuf.append('# In [' + str(vyself.linecount) + ']:')
        z = [q for q in vim.eval("@p").split('\n') if len(q)>0]
        [vyself.pybuf.append(l) for l in z]
        numlines = len(z)
        vyself.linecount += 1
        if numlines > 9:
            thiswin = vim.current.window
            for win in vim.current.tabpage.windows:
                if 'pythonbuff' in win.buffer.name:
                    vim.current.window = win
                    vim.command('normal G' + str(numlines-3)+'kV' +str(numlines-5)+'jzf')
            vim.current.window = thiswin
        thiswin = vim.current.window
        #if thiswin is vyself.pywin:
        #    vim.command('normal gv"ox')

        vyself.scrollbuffend()
        #vim.command('normal zz')


    def mprint(vyself, *args, **kwargs):
        if 'sep' in kwargs.keys():
            sep = kwargs['sep']
        else:
            sep = ' '
        newlinecount = vyself.linecount-1
        outstr = ''
        for a in args:
            outstr += str(a) + sep
        if outstr:
            outstr = outstr[:-len(sep)]
        if newlinecount != vyself.oldlinecount:
            vyself.pybuf.append('') 
            vyself.pybuf.append('# Out [' + str(newlinecount) + ']:') 
        [vyself.pybuf.append(s) for s in outstr.split('\n')] 
        vyself.oldlinecount = vyself.linecount-1
        vyself.scrollbuffend()

    #only prints string that has content (for displaying Python execution results)
    def smartprint(vyself, stringtoprint):
        procstr = stringtoprint.split('\n')
        for dumindex in range(4):
            for line in procstr:
                if not line:
                    procstr.remove('')
                else:
                    break
        if procstr:
            vyself.mprint('\n'.join(procstr))

    def printexp(vyself):
        vyself.pybuf.append('') 
        lines = vim.eval("@p").strip().split('\n')
        for thisline in lines:
            thisexp = thisline.split('=')[0]
            try:
                if thisexp[-1] in '+-*/':
                    thisexp = thisexp[:-1]
                    if thisexp[-1] == '*':
                        thisexp = thisexp[:-1]
                expout = thisexp.strip() + ' = ' + repr(pjeval(thisexp))
                [vyself.pybuf.append(exp) for exp in expout.split('\n')] 
            except Exception as e1:
                try:
                    thisexp = thisline.replace('\n','')
                    expout = thisexp + ' = ' + repr(pjeval(thisexp))
                    [vyself.pybuf.append(exp) for exp in expout.split('\n')] 
                except Exception as e:
                    print(e)
                    [vyself.pybuf.append(thisexp.split('=')[0].strip() + " is not defined.")] 
            vyself.scrollbuffend()

    def scrollbuffend(vyself):
        thiswin = vim.current.window
        for win in vim.current.tabpage.windows:
            if 'pythonbuff' in win.buffer.name:
                vim.current.window = win
                vim.command('normal G')
        vim.current.window = thiswin

    def readtable(vyself,delim=' +'):
        try:
            table = vim.eval("@p")
            q = [re.split(delim, l) for l in table.split('\n') if len(l)>0]
            vyself.table = [[eval(y) for y in l if len(y)>0] for l in q] 
            return vyself.table
        except:
            pass

    def removeindent(vyself):
        code = vim.eval("@p").split('\n')
        code = [line for line in code if len(line)>0]
        minindent = 500
        for line in code:
            spaces = re.search('^ +' , line)
            if spaces:
                indent = len(spaces.group())
                if indent < minindent:
                    minindent = indent
            else:
                minindent = 0
                break
        code = '\n'.join([line[minindent:] for line in code])
        code = code.replace('\\', '\\\\')
        code = code.replace('\'', '\\\'')
        code = code.replace('\"', '\\\"')
        vim.command('let @p="' + code + '"')

def print(*args, **kwargs):
    mout.mprint(*args, **kwargs)
    vim.command('redraw')

mout = outputter()

def vimdebug():
    vim.debug = sys._getframe().f_back
    if '<module>' not in vim.debug.f_code.co_name:
        vim.oldglobals = list(globals().keys())
        for k in vim.debug.f_locals.keys():
            globals()[k] = vim.debug.f_locals[k]
        try:
            globals()['self_'] = vyself
        except:
            pass
    else:
        vim.oldglobals = None
    vim.command('normal ' + str(vim.debug.f_lineno) + 'gg')
    raise Exception('Debugging in "' + vim.debug.f_code.co_name + '" at line number   ' 
                        + str(vim.debug.f_lineno) )

def endvimdebug():
    if vim.oldglobals:
        gkeys = list(globals().keys())
        for k in gkeys:
            if k not in vim.oldglobals:
                globals().pop(k)

try:
    from completer import IPCompleter # requires IPython; will use simpler rlcompleter if not available
    def get_completions():
        completer = IPCompleter(namespace=locals(),global_namespace=globals())
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        token = thisline[:oldcursposx]
        token = re.split(';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
        completions = [token] 
        try:
            completions += completer.all_completions(token)
        except:
            pass
        if 'julia' in mout.languages:
            try:
                jcompstr = 'jcompletions = REPL.REPLCompletions.completions("' + token +  '", ' + str(len(token)) + '); [string(jcompletions[1][i].mod) for i = 1:length(jcompletions[1])  ]'
                jcomps = jumain.eval(jcompstr)
                if token[-1] == '.':
                    jcomps = [token + jc for jc in jcomps]
                completions += jcomps
            except Exception as e:
                pass
        if 'octave' in mout.languages:
            try:
                ocompstr ='_ocomps = completion_matches("' + token + '")' 
                _oct.eval(ocompstr)
                ocomps = list(_oct.pull('_ocomps'))
                completions += ocomps
            except Exception as e:
                pass
        thistoken = token
        replaceline = thisline[:(oldcursposx-len(thistoken))] + thisline[(oldcursposx):]
        vim.current.line = replaceline
        newpos = (oldcursposy, oldcursposx-len(thistoken))
        vim.current.window.cursor = newpos
        return completions
except:
    print('loading rlcompleter')
    import rlcompleter
    def get_completions():
        rlcmpltr = rlcompleter.Completer()
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        token = thisline[:oldcursposx][::-1]
        if token[:2] == "'[":
            token = token[2:]
            getkeys = True
        else:
            getkeys = False
        try:
            stop = re.search('[^A-Za-z0-9_.]', token).start()
        except:
            stop = None
        thistoken = token[:stop][::-1]
        completions = [thistoken]
        if getkeys:
            try:
                completions += list( eval(thistoken + '.keys()') )
                completions = completions[1:]
                completions = [c +"']" for c in completions]
            except:
                pass
        else:
            cindex = 0
            comp = rlcmpltr.complete(thistoken,cindex)
            while comp != None:
                completions.append(comp)
                cindex += 1
                comp = rlcmpltr.complete(thistoken,cindex)
            try:
                completions += dir(eval(thistoken))
                completions = list(set(completions))
            except:
                pass
            replaceline = thisline[:(oldcursposx-len(thistoken))] + thisline[(oldcursposx):]
            vim.current.line = replaceline
            newpos = (oldcursposy, oldcursposx-len(thistoken))
            vim.current.window.cursor = newpos
        return completions

def runfile(filename):
    with open(filename) as f:
        exec(f.read())
    temp = locals()
    for k in temp.keys():
        globals()[k] = temp[k]

def runfbackg(filename):
    t = threading.Thread(target=runfile, args=(filename,))
    t.start()

EOL
endfunc "end Vythonload

endif "end if has("python3")
            
