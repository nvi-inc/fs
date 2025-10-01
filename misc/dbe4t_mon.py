#!/usr/bin/python3

import socket 
import time 
import getopt
import string
import sys
import struct
import tkinter as Tk
import tkinter.font
import matplotlib
import warnings
import os
matplotlib.use('TkAgg')
from matplotlib.figure import Figure
import numpy as np
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
from ctypes import *

class TSYS(BigEndianStructure):
    _fields_ = [('read_time', c_char * 32),
    ('pkt_size', c_uint16),
    ('epoch_ref', c_uint16),
    ('epoch_sec', c_uint32),
    ('tsys_header', c_char * 20),
    ('tsys0_on', c_uint32 * 64),
    ('tsys0_off', c_uint32 * 64),
    ('tsys1_on', c_uint32 * 64),
    ('tsys1_off', c_uint32 * 64), 
    ('pcal_header', c_char * 20),
    ('pcal_ifx', c_uint16),
    ('pcal_freq', c_double),
    ('pcal_sin', c_int32 * 4096),
    ('pcal_cos', c_int32 * 4096),
    ('raw_header', c_char * 20),
    ('mu0', c_double),
    ('sigma0', c_double),
    ('mu1', c_double),
    ('sigma1', c_double),
    ('pps_offset', c_double),
    ('gps_offset', c_double),
    ('lbc0', c_double * 64),
    ('lbc1', c_double * 64)]

parms = {'-h':"239.0.2.29", '-p':"20020", '-l':"off"}
try:
    opts, pargs = getopt.getopt(sys.argv[1:], "h:p:l:", ["multicast host", "multicast port", "logging"])
except getopt.GetoptError as msg:
    sys.exit(msg)
for o,v in opts:
    parms[o] = v
MCAST_ADDR = str(parms['-h'])
MCAST_PORT = int(parms['-p'])
LOGGING = str(parms['-l'])
print("MCAST Host:", MCAST_ADDR, "MCAST Port:", MCAST_PORT, "logging:", LOGGING)
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sock.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
sock.bind((MCAST_ADDR,MCAST_PORT))
sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 255)
mreg = struct.pack("=4sl",socket.inet_aton(MCAST_ADDR), socket.INADDR_ANY)
status = sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreg)
def handle_input(sock, state):
    if state == Tk.READABLE:
        data, addr = sock.recvfrom(60000,socket.MSG_WAITALL)
        tsys=TSYS();
        memmove(addressof(tsys), data, min(sizeof(tsys), len(data)))
        if LOGGING == 'on':
            flogdat.write(data)
        rtm=tsys.read_time.decode()
        prtm=time.strptime(rtm, "%Y%j%H%M%S")
        frtm=time.strftime("%a %b %d",prtm)
        output = "%s : %d : %d : %s : %s" % (addr[0], tsys.epoch_ref, tsys.epoch_sec, frtm, rtm[0:4]+ '-' + rtm[4:7] + '-' + rtm[7:9] + '-' + rtm[9:11] + '-' + rtm[11:13] )
        label1.config(text=output)
        mustr0= "IF%d mu %.2f sigma %.2f" % (0, tsys.mu0, tsys.sigma0)
        mustr1= "IF%d mu %.2f sigma %.2f" % (1, tsys.mu1, tsys.sigma1) 
        label2.config(text=mustr0 + ' ' + mustr1)

        pcaltmp = np.array(np.zeros(4096), dtype=complex)
        for i in range(4096):
            pcaltmp[i] = tsys.pcal_cos[i]+1j*tsys.pcal_sin[i] 
        for n in range(8):
            for i in range(n, 4096, 8):
                pcaltmp[i] = pcaltmp[i]*np.exp(-1j*2*np.pi*tsys.pcal_freq*n/4096e6)
        pcaltmpfft=np.fft.fft(pcaltmp)
        tones= np.arange(550, 1500, 5)
        xf=tones*1e6
        ph=np.unwrap(np.angle(pcaltmpfft[tones]))
        z1 = np.polyfit(2*np.pi*xf, ph, 1)
        phresid=ph-z1[1]-z1[0]*2*np.pi*xf

        if tsys.pcal_ifx == 0:
          axa=axpcal0
          axb=axpcalfft0
        else:
          axa=axpcal1
          axb=axpcalfft1
        axa.cla()
        axa.plot(pcaltmp.real,'r')
        axa.plot(pcaltmp.imag,'b')
        axa.set_title('pulse cal IF' + str(tsys.pcal_ifx))
        canvaspcal.draw()
        axb.cla()
        axb.plot(np.log10(np.abs(pcaltmpfft[0:2048])),'b')
        axb.set_title('pulse cal fft IF' + str(tsys.pcal_ifx))
        axb.set_ylim([6,12])
        canvaspcalfft.draw()
        pcalstr="pcal freq %.6f pps offset %7.0e gps offset %7.0e" % (tsys.pcal_freq, tsys.pps_offset, tsys.gps_offset)
        label3.config(text=pcalstr)

        axtsys0.cla()
        axtsys1.cla()
        with np.errstate(divide = 'ignore'):
            axtsys0.plot(np.log10(tsys.tsys0_on) ,'r')
        with np.errstate(divide = 'ignore'):
            axtsys0.plot(np.log10(tsys.tsys0_off),'b')
        with np.errstate(divide = 'ignore'):
            axtsys1.plot(np.log10(tsys.tsys1_on) ,'r')
        with np.errstate(divide = 'ignore'):
            axtsys1.plot(np.log10(tsys.tsys1_off) ,'b')
        axtsys0.set_title('diode pwr IF0')
        axtsys1.set_title('diode pwr IF1')
        axtsys0.set_ylim([2,8])
        axtsys1.set_ylim([2,8])
        canvastsys.draw()

        axtemp0.cla()
        axtemp1.cla()
        with np.errstate(divide='ignore',invalid='ignore'):
            axtemp0.plot(np.array(tsys.tsys0_on)/(np.array(tsys.tsys0_on)-np.array(tsys.tsys0_off)))
        with np.errstate(divide='ignore',invalid='ignore'):
            axtemp1.plot(np.array(tsys.tsys1_on)/(np.array(tsys.tsys1_on)-np.array(tsys.tsys1_off)))
        axtemp0.set_title('tsys IF0')
        axtemp1.set_title('tsys IF1')
        axtemp0.set_ylim([0,100])
        axtemp1.set_ylim([0,100])
        canvastemp.draw()

        axbst0.cla()
        axbst1.cla()
        axbst0.plot(np.array(tsys.lbc0))
        axbst1.plot(np.array(tsys.lbc1))
        axbst0.set_title('Bstate IF0')
        axbst1.set_title('Bstate IF1')
        axbst0.set_ylim([0,1])
        axbst1.set_ylim([0,1])
        canvasbst.draw()

root = Tk.Tk()
root.tk_setPalette(background='white')
default_font = tkinter.font.Font(family="Helvetica", size=12)
text_font = tkinter.font.Font(family="Helvetica", size=12)
fixed_font = tkinter.font.Font(family="Helvetica", size=12)
matplotlib.rc('figure',figsize=(4,1.6),dpi=96)
matplotlib.rcParams['figure.subplot.bottom']=0.2
matplotlib.rcParams['figure.subplot.top']=0.8
matplotlib.rc('font',size=10)

root.createfilehandler(sock,Tk.READABLE, handle_input)
root.title('R2DBE Monitor svn 10261 ' + MCAST_ADDR + ' ' + str(MCAST_PORT))
label1=Tk.Label(root, justify='left')
label1.pack(anchor='w')  
label2=Tk.Label(root, justify='left')
label2.pack(anchor='w')  
label3=Tk.Label(root, justify='left')
label3.pack(anchor='w')  

figpcal = Figure()
axpcal0 = figpcal.add_subplot(121)
axpcal1 = figpcal.add_subplot(122)
with warnings.catch_warnings():
    warnings.simplefilter("ignore",matplotlib.MatplotlibDeprecationWarning)
    figpcal.tight_layout()
figpcalfft = Figure()
axpcalfft0 = figpcalfft.add_subplot(121)
axpcalfft1 = figpcalfft.add_subplot(122)
with warnings.catch_warnings():
    warnings.simplefilter("ignore",matplotlib.MatplotlibDeprecationWarning)
    figpcalfft.tight_layout()
figtsys = Figure()
axtsys0 = figtsys.add_subplot(121)
axtsys1 = figtsys.add_subplot(122)
with warnings.catch_warnings():
    warnings.simplefilter("ignore",matplotlib.MatplotlibDeprecationWarning)
    figtsys.tight_layout()
figtemp = Figure()
axtemp0 = figtemp.add_subplot(121)
axtemp1 = figtemp.add_subplot(122)
with warnings.catch_warnings():
    warnings.simplefilter("ignore",matplotlib.MatplotlibDeprecationWarning)
    figtemp.tight_layout()
figbst = Figure()
axbst0 = figbst.add_subplot(121)
axbst1 = figbst.add_subplot(122)
with warnings.catch_warnings():
    warnings.simplefilter("ignore",matplotlib.MatplotlibDeprecationWarning)
    figbst.tight_layout()

canvaspcal = FigureCanvasTkAgg(figpcal, master=root)
canvaspcal.get_tk_widget().pack(fill='both', expand=1)
canvaspcalfft = FigureCanvasTkAgg(figpcalfft, master=root)
canvaspcalfft.get_tk_widget().pack(fill='both', expand=1)
canvastsys = FigureCanvasTkAgg(figtsys, master=root)
canvastsys.get_tk_widget().pack(fill='both', expand=1)
canvastemp = FigureCanvasTkAgg(figtemp, master=root)
canvastemp.get_tk_widget().pack(fill='both', expand=1)
canvasbst = FigureCanvasTkAgg(figbst, master=root)
canvasbst.get_tk_widget().pack(fill='both', expand=1)

if LOGGING == 'on':
    flogdat=open('dbe4t_mon_dat_' + MCAST_ADDR + '.log','ab',0)

root.mainloop()
root.deletefilehandler(sock)
