py3 << EOL
import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
import pickle
import os
import re
import sys
import pandas as pd
from glob import glob
from time import time as now, sleep
import inspect
import pyperclip as pp
import plumbum as pb

from numpy import array, linspace, exp, amin, amax, sum as Σ, mean as μ, sin, cos, tan, log, log10, meshgrid, zeros, ones, append, dot, pi, pi as π, sqrt, arange
from numpy.linalg import norm
# inspect.getmodule(zeros)

from matplotlib.pyplot import figure, plot, imshow, show, grid, xlabel, ylabel, title, draw, legend

from shutil import copyfile as cp

cmd = pb.cmd

def ls(*args):
    return [r for r in pb.cmd.ls(args).split('\n') if len(r) > 0]

def mshow(*args, **kwargs):
    h = figure()
    imshow(*args, **kwargs)
    show(block=False)
    return h

def mplot(*args, **kwargs):
    h = figure()
    plot(*args, **kwargs)
    grid()
    show(block=False)
    return h

def pdump(fname, dat):
    with open(fname, 'wb') as f:
        pickle.dump(dat, f)

def pload(fname):
    with open(fname, 'rb') as f:
        dat = pickle.load(f)
    return dat

def toarray(*args):
    if len(args) == 1 and type(args[0]) is list:
        return np.array(args[0])
    return np.array(args)
 
def Copy(dat):
    pp.copy(str(dat))

def Paste():
    return pp.paste()


def rotate_image(img, angle):
    size_reverse = np.array(img.shape[1::-1]) # swap x with y
    M = cv.getRotationMatrix2D(tuple(size_reverse / 2.), angle, 1.)
    MM = np.absolute(M[:,:2])
    size_new = MM @ size_reverse
    M[:,-1] += (size_new - size_reverse) / 2.
    return cv.warpAffine(img, M, tuple(size_new.astype(int)))


    
EOL
