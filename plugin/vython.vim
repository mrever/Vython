if has('python3')

let $PYPLUGPATH .= expand('<sfile>:p:h') "used to import .py files from plugin directory

command! Vython normal :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr><c-w><c-h>
nnoremap <silent> <F10> :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr><c-w><c-h>

nnoremap <silent> <F5> mPggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <F5> <esc>mPggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <F5> mP<esc>ggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P

nnoremap <silent> <s-enter> mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <s-enter> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <s-enter> mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"alternate mappings for terminal/ssh usage
    nnoremap <silent> <c-\> mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
    inoremap <silent> <c-\> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
    vnoremap <silent> <c-\> mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode()); mout.flushbuff()<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P

nnoremap <silent> <c-b> mPV"py:py3 mout.printexp()<cr>`P
inoremap <silent> <c-b> <esc>mPV"py:py3 mout.printexp()<cr>`Pa
vnoremap <silent> <c-b> mP"py:py3 mout.printexp()<cr>`P
    nnoremap <silent> <m-b> mPV"py:py3 mout.printexp()<cr>`P
    inoremap <silent> <m-b> <esc>mPV"py:py3 mout.printexp()<cr>`Pa
    vnoremap <silent> <m-b> mP"py:py3 mout.printexp()<cr>`P

inoremap <c-u> <C-R>=Pycomplete()<CR>

func! Pycomplete()
    py3 vim.command("call complete(col(\'.\'), " + repr(get_completions()) + ')')
    return ''
endfunc
 
func! Vythonload() 
py3 << EOL
import vim
import sys
import os
import re
import threading

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

sys.argv = ['']
sys.path.append('.') #might be needed to import from current directory
sys.path.append(os.environ['PYPLUGPATH']) # might be needed to import from plugin directory
#on Windows, this is needed for qt stuff like pyplot
os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = sys.exec_prefix.replace('\\','/') + '/Library/plugins/platforms'

def filtcode():
    mout.removeindent()
    mout.tempoutstr = ''
    code = [q for q in vim.eval("@p").split('\n') if len(q)>0]
    if 'fconv' in globals():
        code = [q if q.strip()[0]!='!' else fconv(q) for q in code]
    else:
        code = [q for q in code if q.strip()[0]!='!']
    return '\n'.join(code)

def insertlines(text):
    thisbuf = vim.current.buffer
    pos = vim.current.range.end + 1
    buffstart = thisbuf[:pos]
    buffend =  thisbuf[pos:]
    for line in text.split('\n'):
        buffstart.append(line)
        vim.current.buffer.append('')
    newbuff = buffstart + buffend
    for i, line in enumerate(newbuff):
        vim.current.buffer[i] = line


class outputter():
    def __init__(self):
        self.linecount = 1
        self.pybuf = vim.current.buffer
        self.pywin = vim.current.window
        self.oldlinecount = 0
        self.tempoutstr = ''

    def output(self):
        return
        self.pybuf.append('')
        self.pybuf.append('In [' + str(self.linecount) + ']:')
        z = [q for q in vim.eval("@p").split('\n') if len(q)>0]
        [self.pybuf.append(l) for l in z]
        numlines = len(z)
        self.linecount += 1
        if numlines > 9:
            thiswin = vim.current.window
            for win in vim.current.tabpage.windows:
                if 'pythonbuff' in win.buffer.name:
                    vim.current.window = win
                    vim.command('normal G' + str(numlines-3)+'kV' +str(numlines-5)+'jzf')
            vim.current.window = thiswin
        thiswin = vim.current.window
        if thiswin is self.pywin:
            vim.command('normal gv"ox')

        self.scrollbuffend()


    def mprint(self, *args, **kwargs):
        if 'sep' in kwargs.keys():
            sep = kwargs['sep']
        else:
            sep = ' '
        newlinecount = self.linecount-1
        outstr = ''
        for a in args:
            outstr += str(a) + sep
        if outstr:
            outstr = outstr[:-len(sep)]
#        if newlinecount != self.oldlinecount:
#            self.pybuf.append('') 
#            self.pybuf.append('Out [' + str(newlinecount) + ']:') 
        self.tempoutstr += '\n' + outstr

    def flushbuff(self):
        outstr = self.tempoutstr
        thiswin = vim.current.window
        if thiswin is self.pywin:
            insertlines(outstr)
        else:
            [self.pybuf.append(s) for s in outstr.split('\n')] 
            self.scrollbuffend()
        self.oldlinecount = self.linecount-1
        self.tempoutstr = ''

    #only prints string that has content (for displaying Python execution results)
    def smartprint(self, stringtoprint):
        procstr = stringtoprint.split('\n')
        for dumindex in range(4):
            for line in procstr:
                if not line:
                    procstr.remove('')
                else:
                    break
        if procstr:
            self.mprint('\n'.join(procstr))

    def printexp(self):
        self.pybuf.append('') 
        lines = vim.eval("@p").strip().split('\n')
        for thisline in lines:
            thisexp = thisline.split('=')[0]
            try:
                if thisexp[-1] in '+-*/':
                    thisexp = thisexp[:-1]
                    if thisexp[-1] == '*':
                        thisexp = thisexp[:-1]
                expout = thisexp.strip() + ' = ' + repr(eval(thisexp))
                [self.pybuf.append(exp) for exp in expout.split('\n')] 
            except:
                try:
                    thisexp = thisline.replace('\n','')
                    expout = thisexp + ' = ' + repr(eval(thisexp))
                    [self.pybuf.append(exp) for exp in expout.split('\n')] 
                except:
                    [self.pybuf.append(thisexp.split('=')[0].strip() + " is not defined.")] 
            self.scrollbuffend()

    def scrollbuffend(self):
        thiswin = vim.current.window
        for win in vim.current.tabpage.windows:
            if 'pythonbuff' in win.buffer.name:
                vim.current.window = win
                vim.command('normal G')
        vim.current.window = thiswin

    def readtable(self,delim=' +'):
        try:
            table = vim.eval("@p")
            q = [re.split(delim, l) for l in table.split('\n') if len(l)>0]
            self.table = [[eval(y) for y in l if len(y)>0] for l in q] 
            return self.table
        except:
            pass

    def removeindent(self):
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
            globals()['self_'] = self
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
        completions = [token] + completer.all_completions(token)
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
            
