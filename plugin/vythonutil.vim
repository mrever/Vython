command! Vythonutil normal :call Vythonutil()<cr>

nnoremap <silent> <F8> mP{V}"py:py3 mout.readtable()<cr>`P
vnoremap <silent> <F8> mP"py:py3 mout.readtable()<cr>`P

nnoremap <silent> <c-enter> :py3 exec(fconv(vim.current.line))<cr>
inoremap <silent> <c-enter> <esc>:py3 exec(fconv(vim.current.line))<cr>a
"alternate mappings for terminal/ssh usage
    "nnoremap <silent> <c-]> :py3 exec(fconv(vim.current.line))<cr>
    "inoremap <silent> <c-]> <esc>:py3 exec(fconv(vim.current.line))<cr>a
nnoremap <silent> <F7> :py3 fconv(vim.current.line, replace=True)<cr>
inoremap <silent> <F7> <esc>:py3 fconv(vim.current.line, replace=True)<cr>a

nnoremap <silent> <c-F10> :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr>:call Vythonutil()<cr><c-w><c-h>

func! Vythonutil()
py3 << EOL
import vim
import sys
import os
import re
import shutil
import shlex
import subprocess
import glob
import threading
import tkinter 
from tkinter import filedialog
from importlib import reload

#############shell-like support
def pwd(display=True):
    d = os.getcwd().replace('\\', '/')
    if display:
        print(d)
        print()
    return d

fis = glob.glob('*')
dirs = [pwd(display=False)]
def cd(cdir='.'):
    if not cdir:
        cdir = '.'
    global fis, dirs
    try:
        vim.command('cd ' + cdir)
        #os.chdir(cdir)
        dirs.append(pwd(display=False))
        print(os.getcwd().replace('\\', '/'))
        fis = glob.glob('*')
        print(fis)
        print()
        return cdir
    except:
        print('Unable to cd to ' + str(cdir))

def mv(*args):
    cpmv('mv', *args)
def cp(*args):
    cpmv('cp', *args)
def ln(*args):
    cpmv('ln', *args)
def cpmv(*args):
    cmd = args[0]
    args = list(args[1:])
    sym = ' -> '
    if cmd == 'mv':
        sym = ' --> '
    try:
        call([cmd] + args, display=False)
        files = [os.path.abspath(f).replace('\\','/') for f in args if os.path.exists(f)]
        p1 = files[0]
        p2 = files[1]
        print(p1 + sym + p2)
        print()
    except:
        ostr = repr(args).replace('[','').replace(']','').replace("'",'')
        print('Failure: ' + cmd + ' ' + ostr)

def rm(*args):
    args = list(args)
    files = [os.path.abspath(f).replace('\\','/') for f in args if os.path.exists(f)]
    try:
        ret = call(['rm'] + args, display=False)
        [print('removed ' + f) for f in files]
    except:
        ostr = repr(args).replace('[','').replace(']','').replace("'",'')
        print('Failure: rm ' + ostr)
    print()

def call(*args, display=True):
    ret = subprocess.check_output(*args).decode()
    if display:
        print(ret)
    return ret

def fconv(cmd, replace=False, disp=False):
    numspaces = len(cmd) - len(cmd.lstrip(' '))
    string = list(shlex.split(cmd))
    string = [s.replace('"','') for s in string]
    command = string[0]
    if command[0] == '!':
        command = command[1:]
        string[0] = command
    if command in ['cd', 'pwd', 'cp', 'mv', 'rm', 'ln']: 
        rstr = command + "(" + ','.join(["'"+s+"'" if s[0]!='$' else s[1:] for s in string[1:]]) + ")"
    else:
        if '>' in string:
            rstr = ' '.join([s if s[0]!='$' else s[1:] for s in string])
            rstr = "os.system('" + rstr + "')"
        else:
            rstr = "call([" + ','.join(["'"+s+"'" if s[0]!='$' else s[1:] for s in string]) + "])"
    rstr = ' '*numspaces + rstr
    if replace:
        vim.current.line = rstr
    if disp:
        print(string)
    print(rstr)
    return rstr

def loadenvvariables():
    for envvar in list(os.environ.keys()):
        if envvar:
            globals()[envvar] = os.environ[envvar]
loadenvvariables()



root = tkinter.Tk()
root.withdraw()
def mchdir():
    dirname = filedialog.askdirectory(parent=root,initialdir=os.getcwd(),title='Change directory...')
    os.chdir(dirname)
    return dirname




#############numerical support
try:
    import cv2
except:
    pass
try:
    import numpy as np
    from bokeh.plotting import figure, output_file, show
    import matplotlib
    import matplotlib.pyplot as plt
except:
    print('Failed to import numerical libraries!')
    pass


def plot(*args, **kwargs):
    plt.figure()
    plt.plot(*args, **kwargs)
    plt.show(block=False)

def imshow(*args, **kwargs):
    plt.figure()
    plt.imshow(*args, **kwargs)
    plt.show(block=False)

 
def bplot(x=None,y=None,outfile='lines.html',title='',xlab='',ylab='',legend=None,linew=2):
    output_file(outfile)
    p = figure(title=title, x_axis_label=xlab, y_axis_label=ylab)
    p.line(x,y, legend=legend, line_width=linew)
    p.toolbar.logo = None #don't show Bokeh icon/link
    show(p)

EOL
endfunc "end Vythonutil
