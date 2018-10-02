command! Vythonutil normal :call Vythonutil()<cr>

nnoremap <silent> <F8> mP{V}"py:py3 mout.readtable()<cr>`P
vnoremap <silent> <F8> mP"py:py3 mout.readtable()<cr>`P

func! Vythonutil()
py3 << EOL
import vim
import sys
import os
import re
import threading
import tkinter 
from tkinter import filedialog
from importlib import reload


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

EOL
endfunc "end Vythonutil
