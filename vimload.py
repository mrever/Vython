import vim
import sys
import os
import re
import pickle
import threading
import time
import tkinter 
from tkinter import filedialog
from importlib import reload
# from IPython.core.completer import IPCompleter
from pathlib import Path
sys.path.append(str(Path.home()) +'\\Vim')
from completer import IPCompleter

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

sys.argv=['']
sys.path.append('.') #might be needed to import from current directory
#on Windows, this is needed for qt stuff like pyplot
os.environ['QT_QPA_PLATFORM_PLUGIN_PATH']= sys.exec_prefix.replace('\\','/') + '/Library/plugins/platforms'

from ctypes import cdll
try:
    import dill
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
try:
    ahk = cdll.Autohotkey
    ahk.ahktextdll("")
except:
    ahk = None
    print('Failed to load ahk')
try:
    import pyperclip
except:
    pyperclip = None
    print('Failed to import pyperclip')


class outputter():
    def __init__(self):
        self.linecount=1
        self.pybuf = vim.current.buffer
        self.pywin = vim.current.window
        self.oldlinecount = 0

    def output(self):
        self.pybuf.append('')
        self.pybuf.append('In [' + str(self.linecount) + ']:')
        z=[q for q in vim.eval("@p").split('\n') if len(q)>0]
        [self.pybuf.append(l) for l in z]
        numlines=len(z)
        self.linecount+=1

        if numlines>9:
            thiswin=vim.current.window
            vim.current.window = self.pywin
            vim.command('normal G' + str(numlines-3)+'kV' +str(numlines-5)+'jzf')
            vim.current.window = thiswin

        thiswin=vim.current.window
        if thiswin is self.pywin:
            vim.command('normal gv"ox')

        self.scrollbuffend()


    def mprint(self, *args, **kwargs):
        newlinecount = self.linecount-1

        outstr = ''
        for a in args:
            outstr += str(a) + ' '
        if outstr:
            outstr = outstr[:-1]

        if newlinecount != self.oldlinecount:
            self.pybuf.append('') 
            self.pybuf.append('Out [' + str(newlinecount) + ']:') 
        [self.pybuf.append(s) for s in outstr.split('\n')] 
        self.oldlinecount = self.linecount-1
        
        self.scrollbuffend()

    #only prints string that has content (for displaying Python execution results)
    def smartprint(self, stringtoprint):
        procstr=stringtoprint.split('\n')
        for dumindex in range(4):
            for line in procstr:
                if not line:
                    procstr.remove('')
                else:
                    break

        if procstr:
            self.mprint('\n'.join(procstr))

        # for line in stringtoprint.split('\n'):
            # if line:
                # self.mprint(stringtoprint)
                # break


    def printexp(self):
        self.pybuf.append('') 
        thisline = vim.eval("@p")
        thisexp = thisline.split('=')[0].replace(' ', '').replace('\n','')
        if thisexp[-1] in '+-*/':
            thisexp = thisexp[:-1]
            if thisexp[-1] == '*':
                thisexp = thisexp[:-1]
        # try:
        # expout = str(eval(thisexp)).replace('\n',' ')
        # expout = repr(eval(thisexp)).replace('\n',' ')
        expout = thisexp + ' = ' + repr(eval(thisexp))
        [self.pybuf.append(exp) for exp in expout.split('\n')] 
        # except:
            # pass

        self.scrollbuffend()

    def scrollbuffend(self):
        thiswin=vim.current.window
        vim.current.window = self.pywin
        vim.command('normal G')
        vim.current.window = thiswin

    def readtable(self,delim=' +'):
        try:
            table = vim.eval("@p")
            q=[re.split(delim, l) for l in table.split('\n') if len(l)>0]
            self.table=[[eval(y) for y in l if len(y)>0] for l in q] 
            return self.table
        except:
            pass

mout=outputter()

# def print(*args, **kwargs):
    # mout.mprint(*args, **kwargs)

def get_completions():
    # completer = IPCompleter()
    completer = IPCompleter(namespace=locals(),global_namespace=globals())
    oldcursposy, oldcursposx = vim.current.window.cursor
    thisline=vim.current.line
    token = thisline[:oldcursposx]
    token = re.split(';| |:|~|%|,|\+|-|\*|/|&|\||=|\(|\)',token)[-1]
    # token = re.split('[^A-Za-z0-9_.]',token)[-1]
    completions= [token] + completer.all_completions(token)
    thistoken=token

    replaceline = thisline[:(oldcursposx-len(thistoken))] + thisline[(oldcursposx):]
    vim.current.line = replaceline
    newpos = (oldcursposy, oldcursposx-len(thistoken))
    vim.current.window.cursor = newpos

    return completions



def runfile(filename):
    with open(filename) as f:
        exec(f.read())
    temp=locals()
    for k in temp.keys():
        globals()[k] = temp[k]

def runfbackg(filename):
    t = threading.Thread(target=runfile, args=(filename,))
    t.start()

def plot(*args, **kwargs):
    plt.figure()
    plt.plot(*args, **kwargs)
    plt.show(block=False)

def imshow(*args, **kwargs):
    plt.figure()
    plt.imshow(*args, **kwargs)
    plt.show(block=False)

root = tkinter.Tk()
root.withdraw()
def mchdir():
    dirname = filedialog.askdirectory(parent=root,initialdir=os.getcwd(),title='Change directory...')
    os.chdir(dirname)
    return dirname

 
def bplot(x=None,y=None,outfile='lines.html',title='',xlab='',ylab='',legend=None,linew=2):
    output_file(outfile)
    p = figure(title=title, x_axis_label=xlab, y_axis_label=ylab)
    p.line(x,y, legend=legend, line_width=linew)
    p.toolbar.logo = None #don't show Bokeh icon/link
    show(p)


def sendblenderstr():
    if ahk:
        stosend = vim.eval("@r")
        ahk.ahkexec('WinActivate, Blender')
        ahk.ahkexec('sleep, 200')
        if pyperclip:
            pyperclip.copy(stosend)
            ahk.ahkexec('send, {ctrl down}v{ctrl up}{enter}{enter}')
        else:
            for line in stosend.split('\n'):
                if len(line)>0:
                    if line[0]==' ' or line[0]=='\t':
                        ahk.ahkexec('send, {space}{space}{space}{space}')
                    ahk.ahkexec('sendraw, ' + line)
                ahk.ahkexec('send, {enter}' )
        ahk.ahkexec('sleep, 200')
        ahk.ahkexec('WinActivate, ahk_class Vim')


