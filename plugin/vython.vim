if has('python3')

let $PYPLUGPATH .= expand('<sfile>:p:h') "used to import .py files from plugin directory

command! Vython normal  :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr>:sp<cr>:e test.py<cr><c-w><c-h>:set filetype=python<cr>
nnoremap <silent> <F10> :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr>:sp<cr>:e test.py<cr><c-w><c-h>:set filetype=python<cr>

func! Vythonload()

nnoremap <silent> <F5>      mPggVG"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <F5> <esc>mPggVG"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <F5> mP<esc>ggVG"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

nnoremap <silent> <s-enter>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <s-enter> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <s-enter>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
"alternate mappings for terminal/ssh usage
nnoremap <silent> <c-\>      mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <c-\> <esc>mPV"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <c-\>       mP"py:py3 vyth.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 vyth.smartprint(vim.eval("@b"))<cr>`P

nnoremap <silent> <c-b>      mPV"py:py3 vyth.printexp()<cr>`P
inoremap <silent> <c-b> <esc>mPV"py:py3 vyth.printexp()<cr>`Pa
vnoremap <silent> <c-b>       mP"py:py3 vyth.printexp()<cr>`P
"alternate mappings for tmux users
nmap <m-b> <c-b>
imap <m-b> <c-b>
vmap <m-b> <c-b>

nnoremap <silent> <F8> mP{V}"py:py3 vyth.readtable()<cr>`P
vnoremap <silent> <F8> mP"py:py3 vyth.readtable()<cr>`P
"nmap <F9> <s-insert>V}<F8>gvx:py3 vim.current.buffer.append(repr(vyth.table))<cr>j
nmap <F9> mpGo<cr><s-insert><esc>V{<F8>uu:py3 vim.current.buffer.append("arr = " + repr(vyth.table))<cr>Gdd`pp

inoremap <c-u> <C-R>=Pycomplete()<CR>

func! Pycomplete()
    py3 vim.command("call complete(col('.'), " + repr(get_completions()) + ')')
    return ''
endfunc

py3 __nvim__ = False
if has('nvim')
    py3 __nvim__ = True
endif

py3 << EOL
import vim
import sys
import os
import re
import threading
import numpy as np
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

if '_blank' not in globals():
    class _blank: pass
    languagemgr = _blank()
    languagemgr.langlist  = []
    languagemgr.langevals = []
    languagemgr.langcompleters = []

# try to evaluate expressions for different languages
def pjeval(expr):
    vyth.vyth_errlist = []
    try: 
        return eval(expr)
    except Exception as e:
        excpt = e
        vyth.vyth_errlist.append(e)

    for langeval in languagemgr.langevals:
        val = langeval(expr)
        if 'error' in str(type(val)).lower():
            vyth.vyth_errlist.append(val)
        else:
            return val

    print(excpt)

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


if 'filtcode' not in globals():
    def filtcode():
        vyth.removeindent()
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        code = [q for q in code if q and len(q.strip())>0 and q.strip()[0]!='!']
        #try:
        parsedout = ('\n'.join(code))
        #except:
            #parsedout = ('\n'.join(code))
        return parsedout


class vyth_outputter():
    def __init__(vyself):
        vyself.linecount = 1
        vyself.pybuf = vim.current.buffer
        vyself.pywin = vim.current.window
        vyself.oldlinecount = 0
        vyself.languages = ['python']
        lappend = vyself.languages.append
        vyself.languages += languagemgr.langlist
        vyself.vyth_errlist = [] 
        # vyself.hometmp = os.path.expanduser('~') + '/tmp/'
        vyself.hometmp = '/tmp/'
        if not os.path.exists(vyself.hometmp):
            os.mkdir(vyself.hometmp)
        vyself.outhtml = False
        vyself.htmlbuff = []

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
        vyself.scrollbuffend()


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
        if vyself.outhtml:
            vyself.writebuffhtml(outstr, shownum=True)

    # only prints string that has content (for displaying Python execution results)
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
                if '==' in thisline:
                    thisexp = thisline
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

    def readtable(vyself, delim=' +'):
        try:
            table = vim.eval("@p")
            table = table.replace(',', ' ')
            table = ''.join([t for t in table if t.isdigit() or t.isspace() 
                                              or t=='-' or t=='.'])
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

    def writebuffhtml(vyself, string, br=2, shownum=False):
        with open(vyself.hometmp + "pythonbuff.html", 'a') as f:
            if shownum:
                string = 'Out [' + str(len(vyself.htmlbuff)+1) + ']: ' + string
            f.write(string)
            f.write('<br>'*br)
            vyself.htmlbuff.append(string)

    def clearbuffhtml(vyself, string=''):
        with open(vyself.hometmp + "pythonbuff.html", 'w') as f:
            f.write(string)
            if string:
                f.write('<br>'*5)


def print(*args, **kwargs):
    vyth.mprint(*args, **kwargs)
    vim.command('redraw')

vyth = vyth_outputter()

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
        pycompleter = IPCompleter(namespace=locals(),global_namespace=globals())
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        token = thisline[:oldcursposx]
        token = re.split(';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
        completions = [token] 
        try:
            completions += pycompleter.all_completions(token)
        except:
            pass
        for lcompleter in languagemgr.langcompleters:
            completions += lcompleter()
        completions += []
        trunccomp = []
        for c in completions:
            if len(c) > len(token):
                trunccomp.append(c[len(token):])
        return trunccomp
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
        for lcompleter in languagemgr.langcompleters:
            completions += lcompleter()
        trunccomp = []
        for c in completions:
            if len(c) > len(token):
                trunccomp.append(c[len(token):])
        return trunccomp


EOL
endfunc "end Vythonload

endif
