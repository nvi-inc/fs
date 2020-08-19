#
# Copyright (c) 2020 NVI, Inc.
#
# This file is part of VLBI Field System
# (see http://github.com/nvi-inc/fs).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
from decimal import Decimal
import os
import math
import mpmath
import copy
import numpy as np
import pandas as pd
import time
import random
import re
from io import StringIO
import getopt
import itertools
import gzip
from datetime import datetime
from scipy.optimize import curve_fit
from lmfit import minimize, Parameters, Model, Minimizer, fit_report


def extracter(infile):
    """Take in a log file, or zipped log file, and extract a dataframe from it. If '$$' in the spot for data then defaults to 1000 (a placeholder as it will never be included in calculations since ii or jj will be zero). Also returns a string including the site of the log file, and the type of antenna used.
    """

    site='sitetest'
    sourcetype='sourcetest'
    dfcolumns=['indicator','az','el','az_off','el_off','az_sigma','el_sigma','ii','jj','det','source', 'time']
    df=pd.DataFrame(columns=dfcolumns)
    sourcetypeflag=0
    siteflag=0
    pdwriteflag = 0
    dfindex=0
    if infile.endswith('.gz'):
        f = gzip.open(infile, 'r')
        file_content = f.read()
        file_content = file_content.decode('latin-1')
        filefinal = StringIO(file_content)
        for line in filefinal:
            if 'fivpt' in line and 'source' in line:
                source=line.split()[1]
            if 'fivpt' in line and 'fivept' in line:
                det=line.split()[6]
            if 'fivpt' in line and 'latfit' in line:
                el_offset=line.split()[1]
                if '$$' in el_offset:
                    el_offset=1000
                el_offset=float(el_offset)
            if 'fivpt' in line and 'laterr' in line:
                el_sigma=line.split()[1]
                if '$$' in source:
                    el_sigma=10000
                el_sigma=float(el_sigma)
            if 'fivpt' in line and 'lonfit' in line:
                az_offset=line.split()[1]
                if '$$' in az_offset:
                    az_offset=10000
                az_offset=float(az_offset)
            if 'fivpt' in line and 'lonerr' in line:
                az_sigma=line.split()[1]
                if '$$' in az_sigma:
                    az_sigma=10000
                az_sigma=float(az_sigma)
            if 'fivpt' in line and 'offset' in line and 'xoffset' not in line:
                offsetdata = line.split()
                indicator = offsetdata [0]
                az = line.split()[1]
                el = line.split()[2]
                ii = offsetdata[5]
                jj = offsetdata[6]
                rowtime = datetime.strptime(line.split()[0][:20], '%Y.%j.%H:%M:%S.%f')
                if '$$' in az:
                    az=10000
                if '$$' in el:
                    el=10000
                az=float(az)
                el=float(el)
                pdwriteflag = 1
            if bool(pdwriteflag):
                df.loc[dfindex]=[indicator, az ,el, az_offset, el_offset, az_sigma, el_sigma, ii, jj, det, source, rowtime]
                dfindex+=1
                pdwriteflag=0
            if siteflag==0 and 'site' in line:
                site=re.search(r'site\s([a-zA-Z1-9]+)', line).group(1)
                siteflag=1
            if sourcetypeflag==0 and 'fivpt#fivept' in line:
                sourcetype=re.search(r'fivpt#fivept\s([a-zA-Z1-9]+)', line).group(1)
                sourcetypeflag=1
    else:
        with open(infile, 'r', encoding='latin-1') as f:
            for line in f:
                if 'fivpt' in line and 'source' in line:
                   source=line.split()[1]
                if 'fivpt' in line and 'fivept' in line:
                    det=line.split()[6]
                if 'fivpt' in line and 'latfit' in line:
                    el_offset=line.split()[1]
                    if '$$' in el_offset:
                        el_offset=1000
                    el_offset=float(el_offset)
                if 'fivpt' in line and 'laterr' in line:
                    el_sigma=line.split()[1]
                    if '$$' in source:
                        el_sigma=10000
                    el_sigma=float(el_sigma)
                if 'fivpt' in line and 'lonfit' in line:
                    az_offset=line.split()[1]
                    if '$$' in az_offset:
                        az_offset=10000
                    az_offset=float(az_offset)
                if 'fivpt' in line and 'lonerr' in line:
                    az_sigma=line.split()[1]
                    if '$$' in az_sigma:
                        az_sigma=10000
                    az_sigma=float(az_sigma)
                if 'fivpt' in line and 'offset' in line and 'xoffset' not in line:
                    offsetdata = line.split()
                    indicator = offsetdata [0]
                    az = line.split()[1]
                    el = line.split()[2]
                    ii = offsetdata[5]
                    jj = offsetdata[6]
                    rowtime = datetime.strptime(line.split()[0][:20], '%Y.%j.%H:%M:%S.%f')
                    if '$$' in az:
                        az=10000
                    if '$$' in el:
                        el=10000
                    az=float(az)
                    el=float(el)
                    pdwriteflag = 1
                if bool(pdwriteflag):
                    df.loc[dfindex]=[indicator, az ,el, az_offset, el_offset, az_sigma, el_sigma, ii, jj, det, source, rowtime]
                    dfindex+=1
                    pdwriteflag=0
                if siteflag==0 and 'site' in line:
                    site=re.search(r'site\s([a-zA-Z1-9]+)', line).group(1)
                    siteflag=1
                if sourcetypeflag==0 and 'fivpt#fivept' in line:
                    sourcetype=re.search(r'fivpt#fivept\s([a-zA-Z1-9]+)', line).group(1)
                    sourcetypeflag=1
    return df, str('  '+site+' '+sourcetype)


def xtracprinter(name, dfin, dfstats,all_info, flagstring, oldmodel_all, logfile):
    """Takes in a place to save, a dataframe, a list of statistics, a string of info, a flagstring, a model, and the name of a logfile, and prints an extract file, depending on whether we have v2 or v1 data
    """

    hexval= '{:x}'.format(int(flagstring, 2))
    df=copy.deepcopy(dfin)
    try:
        df["time"]=[i.strftime("%Y.%j.%H.%M.%S") for i in df["time"]]
        with open("/usr2/log/"+name, 'w') as f:
            f.write('$antenna\n')
            f.write(all_info+'   '+str(hexval)+'   v2   '+os.path.basename(logfile))
            f.write('\n$data\n')
            f.write(df.to_string(header=False,index=False, float_format="{:10.5f}".format, columns=['indicator','az','el','az_off','el_off','az_sigma','el_sigma','source','e_e', 'time']))
            f.write('\n$stats\n')
            f.write('   '+''.join(list(map(lambda x: str(x), dfstats))))
            f.write('\n$model')
            f.write(oldmodel_all)
        return 0
    except:
        df["time"]=0
        with open("/usr2/log/"+name, 'w') as f:
            f.write('$antenna\n')
            f.write(all_info+'   '+str(hexval)+'   v1   '+os.path.basename(logfile))
            f.write('\n$data\n')
            f.write(df.to_string(header=False,index=False, float_format="{:10.5f}".format, columns=['indicator','az','el','az_off','el_off','az_sigma','el_sigma','source','e_e']))
            f.write('\n$stats\n')
            f.write('   '+''.join(list(map(lambda x: str(x), dfstats))))
        return 0


def simxtrac():
    """Takes in lists of desired data and creates a simulated xtr file with those as the only values in the dataframe
    """
    phi=90
    p=[.0001,0,.0001,.0001,.0001,.0001,.0001,.0001,.0001,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    p=[i/600 for i in np.arange(30)]
    df=pd.DataFrame(columns=['indicator','az','el','az_off','el_off','az_sigma','el_sigma','source','e_e', 'time'])
    dfindex=0
    for i in np.linspace(0,2*math.pi-.1,20):
        for j in np.linspace(0,math.pi/2-.1,20):
            df.loc[dfindex]=[1, i, j, 0, 0, np.random.normal(0, .001), np.random.normal(0,.001), 'unk', j, 0]
            dfindex+=1
    print(df["az_sigma"])
    df['az_off'], df['el_off'] = correctfunc(df, phi, p)
    df["xel_off"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_off"], df["el"])]
    df["xel_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_sigma"], df["el"])]
    df["off_vector"]=[np.sqrt(float(a)**2*float(b)**2) for a,b in zip(df["xel_off"], df["el_off"])]
    df_stats = dfstater(df, len(df.index), len(df.index))
    print(df_stats)
    name="xtrsim"
    all_info = "  simulation  none        3"
    flagstring='0011'
    dfstats=[0,0,0,0,0,0,0]
    dfdeg = unradiafy(df)
    xtracprinter(name, dfdeg,dfstats,all_info,flagstring, '\nNo Old Model', 'simulatedlogname')
    return 0


def reader1(xtrfile):
    """Takes in an xtr file and creates a dataframe, a list of statistics, and a string of information
    """

    old_model=''
    datafile = open(xtrfile, 'r')
    alltext = datafile.read()
    lines = alltext.splitlines()
    all_info = lines[1]
    all_info_lst = all_info.split()
    if len(all_info_lst)==5:
        vnumber=2
        old_model=re.search(r'\$model((.|\n)*)', alltext).group(1)
        filename = all_info_lst[-1]
        datas=re.search(r'\$data((.|\n)*)\$stats', alltext).group(1)
        df=pd.read_csv(StringIO(datas), index_col=False, names=['indicator','az','el','az_off','el_off','az_sigma','el_sigma','source','e_e', 'time'], sep='\s+')
        df["time"]=[datetime.strptime(i, "%Y.%j.%H.%M.%S") for i in df["time"]]
    else:
        vnumber=1
        datas=re.search(r'\$data((.|\n)*)\$stats', alltext).group(1)
        df=pd.read_csv(StringIO(datas), index_col=False, names=['indicator','az','el','az_off','el_off','az_sigma','el_sigma','source','e_e'], sep='\s+')
        df["time"]=0


    dfstats = re.search(r'\$stats\s+(.*)', alltext).group(1)
    flags = all_info_lst[2]
    all_info = '  '+'  '.join(all_info_lst[:2])+'  '
    try:
        flagstring = "{0:b}".format(int(flags,16))
        flagstring = flagstring.rjust(4,'0')
        datafile.close()
    except:
        flagstring = '0011'

    dfstats = dfstats.split()
    dfstats = [float(i) for i in dfstats]
    return df, dfstats, all_info, flagstring, old_model, vnumber


def radiafy(dfin):
    """Take in a dataframe and return dataframe with all relevant values converted to radians
    """

    df=copy.deepcopy(dfin)
    for i in ['az','el','az_off','el_off','az_sigma','el_sigma','xel_off', 'xel_sigma', 'az_input_sigma', 'az_prior_sigma','az_post_sigma', 'el_input_sigma', 'el_prior_sigma','el_post_sigma', 'xel_input_sigma', 'xel_prior_sigma','xel_post_sigma', 'e_e']:
        if i in df.columns:
            df[i]=[float(mpmath.radians(float(k))) for k in df[i]]
    #df["off_vector"]=[np.sqrt(float(j)**2+float(k)**2) for j,k in zip(df['xel_off'], df['el_off'])]
    return df


def unradiafy(dfin):
    """Take in dataframe and return dataframe with all relevant data converted to degrees
    """

    df=copy.deepcopy(dfin)
    for i in ['az','el','az_off','el_off','az_sigma','el_sigma','xel_off', 'xel_sigma', 'az_input_sigma', 'az_prior_sigma','az_post_sigma', 'el_input_sigma', 'el_prior_sigma','el_post_sigma', 'xel_input_sigma', 'xel_prior_sigma','xel_post_sigma', 'e_e']:
        if i in df.columns:
            df[i]=[float(mpmath.degrees(float(k))) for k in df[i]]
    df["off_vector"]=[np.sqrt(float(j)**2+float(k)**2) for j,k in zip(df['xel_off'], df['el_off'])]
    return df


def handler(dfin):
    """Take in dataframe, if from xtr add blank ii,jj, and det columns. Create dataframe columns for xel_off, xel_sigma, and off_vector. Put *bad, 0 , or 1 in indicator column depending on context, and add up good records (goodcounter, generalcounter). Ensure all columns of data are numeric, and then calculate statistics for all non *bad records. Also setup input, prior, and post sigma categories for use in finalfitter
    """

    df=copy.deepcopy(dfin)
    init_columns = df.columns
    df['xel_off']=0
    df['xel_sigma']=0
    df['off_vector']=0

    #These are just placeholders until finalfitter is called and they will all be overwritten
    df['xel_input_sigma']=0
    df['xel_prior_sigma']=0
    df['xel_post_sigma'] =0
    df['el_input_sigma'] =0
    df['el_prior_sigma'] =0
    df['el_post_sigma']  =0
    df['az_input_sigma'] =0
    df['az_prior_sigma'] =0
    df['az_post_sigma']  =0


    if 'ii' not in init_columns:
        df['ii']=""
        df['jj']=""
        df['det']=""
    goodcounter=0
    generalcounter=0
    df["xel_off"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_off"], df["el"])]
    df["xel_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_sigma"], df["el"])]
    df["off_vector"]=[np.sqrt(float(a)**2*float(b)**2) for a,b in zip(df["xel_off"], df["el_off"])]

    for index,row in df.iterrows():
        if 'ii' in init_columns:
            if int(row['ii']) == 0 or int(row['jj'])==0:
                df.at[index,'indicator']='*bad'
                generalcounter+=1
            else:
                df.at[index,'indicator']=1
                generalcounter+=1
                goodcounter+=1
        else:
            df.at[index,'det']="Unk"
            if df.at[index, 'indicator']!='*bad':
                df.at[index, 'ii']=1
                df.at[index, 'jj']=1
                generalcounter+=1
                if df.at[index, 'indicator']=='1':
                    goodcounter+=1
            else:
                df.at[index, 'ii']=0
                df.at[index, 'jj']=0
    df["az_off"] = pd.to_numeric(df["az_off"])
    df["az_sigma"] = pd.to_numeric(df["az_sigma"])
    df["el_off"] = pd.to_numeric(df["el_off"])
    df["el_sigma"] = pd.to_numeric(df["el_sigma"])
    df["xel_off"] = pd.to_numeric(df["xel_off"])
    df["xel_sigma"] = pd.to_numeric(df["xel_sigma"])
    df["off_vector"] = pd.to_numeric(df["off_vector"])
    df['e_e']=df['el']

    dfstats = dfstater(df, goodcounter, generalcounter)
    df = df.reset_index(drop=True)
    return df, dfstats


def dfstater(dfin, goodcounter, generalcounter):
    """take in dataframe, number of good records, and overall number of records, returning a list of formatted statistics fitting format in "error" documentation
    """

    df = copy.deepcopy(dfin)
    df = df[df["indicator"]!="*bad"]
    df['indicator']=pd.to_numeric(df['indicator'])
    df = unradiafy(df[df['indicator']==1])

    #Calculate mean, and rms of az
    az_off_list=df['az_off'].values.tolist()
    az_off_mean=weightedavg(az_off_list, df["az_sigma"])
    az_off_rms=np.sqrt(weightedrms(az_off_list, df["az_sigma"], az_off_mean))

    #Calculate mean, and rms of el
    el_off_list= df['el_off'].values.tolist()
    el_off_mean=weightedavg(el_off_list, df["el_sigma"])
    el_off_rms=np.sqrt(weightedrms(el_off_list, df["el_sigma"], el_off_mean))

    #Calculate mean, and rms of xel
    xel_off_list= df['xel_off'].values.tolist()
    xel_off_mean=weightedavg(xel_off_list, df['xel_sigma'])
    xel_off_rms=np.sqrt(weightedrms(xel_off_list, df["xel_sigma"], xel_off_mean))

    #Create list of vector magnitudes of offset vectors (xel, el)
    avg_off_vector=np.linalg.norm(np.array([xel_off_mean,el_off_mean]))
    offset_vectorlist=[]
    for i in range(0,len(az_off_list)):
        offset_vectorlist.append(np.array([xel_off_list[i], el_off_list[i]]))
    for i in range(0, len(offset_vectorlist)):
        offset_vectorlist[i]=np.linalg.norm(offset_vectorlist[i])

    #Calculate sigma and rms for the offset vector
    off_vector_sigma = [np.sqrt((els**2)+(xels**2)) for els,xels in zip(df['el_sigma'], df['xel_sigma'])]
    off_vector_rms = np.sqrt(weightedrms(offset_vectorlist, off_vector_sigma, 0))
    dfstats = [az_off_mean, az_off_rms, el_off_mean, el_off_rms, off_vector_rms, goodcounter, generalcounter, xel_off_mean, xel_off_rms]
    dfstats = statsnumformatter(dfstats)
    return dfstats


def weightedavg(data, weights):
    """Take in list of data and corresponding weights, and calculate weighted average
    """

    num1 = sum([a/(b**2) for a,b in zip(data, weights)])
    den1 = sum([1/(b**2) for b in weights])
    return float(num1/den1)


def weightedrms(data, weights, mean):
    """Take in list of data, and weighs, and single mean value, and calculate weighted rms
    """

    num1 = sum([((d-mean)**2)/(w**2) for d,w in zip(data, weights)])
    den1 = sum([1/(i**2) for i in weights])
    return float(num1/den1)


def modelreader(infile):
    """Take in file name of model (mdlpo) and return string of entire final section (old model) of that file, return phi from the model, return a list of flags for the parameters from the model, and return a list of parameter values from that model. Also return version number, so can be incremented
    """
    if os.path.isfile(infile):
        with open(infile, 'r') as f:
            lines = f.read().splitlines()
            model_all = '\n'.join(lines[-17:])
            model_all= '\n'+model_all+'\n'
    else:
        model_all=infile
    vals = re.findall(r'-?\d+\.?\d*', model_all, re.M)
    version = vals[0]
    model_phi = vals[7]
    model_flags = vals[8:38]
    model_params= vals[38:]
    model_params = [(float(mpmath.radians(float(i)))) for i in model_params]
    return model_all, model_phi, model_flags, model_params, version


def corrector(dfin, phi, paramvallist):
    """Take in dataframe, phi from model, and list of parameter values, and returns new dataframe, and stats with those parameters applied to the corrective model using correctfunc
    """

    df = copy.deepcopy(dfin)
    df = df[df['indicator']!='*bad']
    df["indicator"]=pd.to_numeric(df["indicator"])

    az_offcor, el_offcor = correctfunc(df, phi, paramvallist)
    df["az_off"]=[a+b for a,b in zip(az_offcor,df['az_off'])]
    df["el_off"]=[a+b for a,b in zip(el_offcor,df['el_off'])]

    df = df.reset_index(drop=True)
    goodcounter=0
    generalcounter=0
    df["off_vector"]=""
    generalcounter = len(df.index)
    goodcounter = len(df[df["indicator"]==1].index)

    df["xel_off"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_off"], df["el"])]
    df["xel_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_sigma"], df["el"])]
    df["xel_input_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_input_sigma"], df["el"])]
    df["xel_prior_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_prior_sigma"], df["el"])]
    df["xel_post_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df["az_post_sigma"], df["el"])]
    df["off_vector"]=[np.sqrt(float(a)**2*float(b)**2) for a,b in zip(df["xel_off"], df["el_off"])]

    dfstats = dfstater(df, goodcounter, generalcounter)
    df = df.reset_index(drop=True)

    df_deg = unradiafy(df)
    return df, dfstats


def func(az_offset, el_offset, az, el, azsin, az2sin, azcos, az2cos, elsin, el8sin, elcos, el8cos, elsec,
         eltan, phi_cos, phi_sin, p1, p2, p3 , p4, p5 , p6, p7, p8 ,p9, p10, p11, p12, p13, p14, p15, p16,p17,
         p18, p19, p20, p21, p22, p23):
    """The function used in modelcreator to fit. Returns concatenated set of np arrays which is the form required from lmfit to minimze both parts (azoffresid, and eloffresid)
    """

    az_off_resid= (p1
                  -p2*phi_cos*azsin*elsec
                  +p3*eltan
                  -p4*elsec
                  +p5*azsin*eltan
                  -p6*azcos*eltan
                  +p12*az
                  +p13*azcos
                  +p14*azsin
                  +p17*az2cos
                  +p18*az2sin)
    el_off_resid = (p5*azcos
                  +p6*azsin
                  +p7
                  -p8*(phi_cos*azcos*elsin-phi_sin*elcos)
                  +p9*el
                  +p10*elcos
                  +p11*elsin
                  +p15*az2cos
                  +p16*az2sin
                  +p19*el8cos
                  +p20*el8sin
                  +p21*azcos
                  +p22*azsin
                  +p23*eltan)

    return np.concatenate((az_off_resid,el_off_resid))


def correctfunc(dfin, phi, p):
    """Takes in dataframe, phi value, and list of parameters (p), and return two lists of values which are the corrections which must be applied to each term of az_off, el_off respectively to correct using model
    """

    df = copy.deepcopy(dfin)
    azoff = np.array([float(i) for i in df['az_off'].values.tolist()])
    eloff = np.array([float(i) for i in df['el_off'].values.tolist()])
    phi_radc = float(mpmath.radians(float(phi)))
    phirad = np.full_like(azoff, phi_radc)
    phi_cos = np.array([float(mpmath.cos(i)) for i in phirad])
    phi_sin = np.array([float(mpmath.sin(i)) for i in phirad])
    az = np.array([float(i) for i in df['az'].values.tolist()])
    el = np.array([float(i) for i in df['el'].values.tolist()])
    azsin = [float(mpmath.sin(i)) for i in az]
    az2sin = [float(mpmath.sin(2*i)) for i in az]
    azcos = [float(mpmath.cos(i)) for i in az]
    az2cos = [float(mpmath.cos(2*i)) for i in az]
    elsin = [float(mpmath.sin(i)) for i in el]
    el8sin = [float(mpmath.sin(8*i)) for i in el]
    elcos = [float(mpmath.cos(i)) for i in el]
    el8cos = [float(mpmath.cos(8*i)) for i in el]
    elsec = [float(mpmath.sec(i)) for i in el]
    eltan = [float(mpmath.tan(i)) for i in el]
    p=[0]+p
    az_off_corrections=[]
    el_off_corrections=[]
    for i in range(len(azoff)):
        if i>1 and az_off_corrections[-1]>100:
            i=i-1
            print(az_off_corrections[-1])
            print(eltan[i])
            print(p[1]-p[2]*phi_cos[i]*azsin[i]*elsec[i]
                     +p[3]*eltan[i]
                     )
            exit()
        az_off_corrections.append(p[1]
                     -p[2]*phi_cos[i]*azsin[i]*elsec[i]
                     +p[3]*eltan[i]
                     -p[4]*elsec[i]
                     +p[5]*azsin[i]*eltan[i]
                     -p[6]*azcos[i]*eltan[i]
                     +p[12]*az[i]
                     +p[13]*azcos[i]
                     +p[14]*azsin[i]
                     +p[17]*az2cos[i]
                     +p[18]*az2sin[i])
        el_off_corrections.append(p[5]*azcos[i]
                      +p[6]*azsin[i]
                      +p[7]
                      -p[8]*(phi_cos[i]*azcos[i]*elsin[i]-phi_sin[i]*elcos[i])
                      +p[9]*el[i]
                      +p[10]*elcos[i]
                      +p[11]*elsin[i]
                      +p[15]*az2cos[i]
                      +p[16]*az2sin[i]
                      +p[19]*el8cos[i]
                      +p[20]*el8sin[i]
                      +p[21]*azcos[i]
                      +p[22]*azsin[i]
                      +p[23]*eltan[i])
    return az_off_corrections, el_off_corrections


def modelcreator(dfin, model_phi, model_flags, oldmodel_params, func):
    """take in dataframe, information for fitting, and the function to fit to. Formats data for the fit, does the fitting using lmfit. It then creates and returns a list of the values and errors of the parameters, a formatted version of the correlation matrix for printing to error file after matrixprinter, and the residuals of the fit (modified since lmfit multiplies them by the weights by default)
    """
    df = copy.deepcopy(dfin)
    df = df[df["indicator"]!="*bad"]
    df['indicator']=pd.to_numeric(df['indicator'])
    df=df[df["indicator"]==1]

    az_weights = np.array([1/float(i) for i in df["az_sigma"].values.tolist()])
    el_weights = np.array([1/float(i) for i in df["el_sigma"].values.tolist()])
    final_weights = np.concatenate((az_weights, el_weights))
    azoff = np.array([float(i) for i in df['az_off'].values.tolist()])
    eloff = np.array([float(i) for i in df['el_off'].values.tolist()])
    negazoff = np.array([float(-i) for i in df['az_off'].values.tolist()])
    negeloff = np.array([float(-i) for i in df['el_off'].values.tolist()])
    modelfinaldata = np.concatenate((negazoff, negeloff))
    phi_radc = float(mpmath.radians(float(model_phi)))
    phirad = np.full_like(azoff, phi_radc)
    phi_cos = np.array([float(mpmath.cos(i)) for i in phirad])
    phi_sin = np.array([float(mpmath.sin(i)) for i in phirad])
    az = np.array([float(i) for i in df['az'].values.tolist()])
    el = np.array([float(i) for i in df['el'].values.tolist()])
    azsin = [float(mpmath.sin(i)) for i in az]
    az2sin = [float(mpmath.sin(2*i)) for i in az]
    azcos = [float(mpmath.cos(i)) for i in az]
    az2cos = [float(mpmath.cos(2*i)) for i in az]
    elsin = [float(mpmath.sin(i)) for i in el]
    el8sin = [float(mpmath.sin(8*i)) for i in el]
    elcos = [float(mpmath.cos(i)) for i in el]
    el8cos = [float(mpmath.cos(8*i)) for i in el]
    elsec = [float(mpmath.sec(i)) for i in el]
    eltan = [float(mpmath.tan(i)) for i in el]
    params = Parameters()
    if 3 not in [float(i) for i in model_flags]:
        for i in range(0, len(model_flags)):
            if float(model_flags[i]) == 1:
                params.add('p'+str(i+1), value = 0)
            elif float(model_flags[i]) == 2:
                params.add('p'+str(i+1), value = oldmodel_params[i], vary=False)
            else: #if float(model_flags[i]) == 4:
                params.add('p'+str(i+1), value = 0, vary=False)
    else:
        for i in range(0, len(model_flags)):
            if float(model_flags[i]) == 1 or float(model_flags[i]) == 2:
                params.add('p'+str(i+1), value = oldmodel_params[i], vary=False)
            elif float(model_flags[i]) == 3:
                params.add('p'+str(i+1), value = 0)
            else:
                params.add('p'+str(i+1), value = 0, vary=False)
    gmodel = Model(func, independent_vars=['az_offset', 'el_offset','az','el', 'azsin','az2sin',
                                           'azcos', 'az2cos','elsin','el8sin', 'elcos', 'el8cos',
                                           'elsec', 'eltan', 'phi_cos', 'phi_sin'])
    fit = gmodel.fit(modelfinaldata, params,az_offset=azoff, el_offset=eloff, az=az, el=el,
                     azsin=azsin, az2sin=az2sin, azcos=azcos, az2cos=az2cos, elsin=elsin, el8sin=el8sin,
                     elcos=elcos, el8cos=el8cos, elsec=elsec, eltan=eltan, phi_cos=phi_cos, phi_sin=phi_sin, weights=final_weights, scale_covar=True)
    real_residuals = [a/b for a,b in zip(fit.residual, final_weights)]
    paramvallist=[]
    paramerrlist=[]
    paramcorlist=[]
    cormatrix = np.array([])
    for key, value in fit.params.items():
        paramcorlist.append([value.name ,value.correl])
        paramvallist.append(value.value)
        paramerrlist.append(value.stderr)
    cornum = 0
    for i in range(len(paramcorlist)):
        if isinstance(paramcorlist[i][1], dict):
            atmdict = dict(paramcorlist[i][1])
            atmdict = dict(atmdict)
            listofcors=[]
            for key, value in atmdict.items():
                listofcors.append(value)
            listofcors=listofcors[:cornum]+[1.00]+listofcors[cornum:]
            cormatrix = np.append(cormatrix, listofcors)
            cornum+=1
    cormatrix = np.array(["{:7.3f}".format(i) for i in cormatrix])
    cormatrix.shape = (cornum,cornum)
    return paramvallist, paramerrlist, fit, cormatrix, real_residuals


def dfun(phi, row, azflag):
    """Takes in an angle, a row of data, and a flag for az vs el. Returns jacobian in list form for that data point.
    """

    phirad = float(mpmath.radians(float(phi)))
    phi_cos = float(mpmath.cos(phirad))
    phi_sin = float(mpmath.sin(phirad))
    az = row['az']
    el = row['el']
    azsin = float(mpmath.sin(az))
    az2sin = float(mpmath.sin(2*az))
    azcos = float(mpmath.cos(az))
    az2cos = float(mpmath.cos(2*az))
    elsin = float(mpmath.sin(el))
    el8sin = float(mpmath.sin(8*el))
    elcos = float(mpmath.cos(el))
    el8cos = float(mpmath.cos(8*el))
    elsec = float(mpmath.sec(el))
    eltan = float(mpmath.tan(el))
    if azflag==1:
        return [1, -1*phi_cos*azsin*elsec,eltan,-1*elsec,azsin*eltan,
                -1*azcos*eltan, 0,0,0,0,0, az,azcos,azsin,0,0,az2cos,az2sin, 0,0,0,0,0,0,0,0,0,0,0,0]
    else:
        return [0, 0, 0, 0, azcos, azsin,1,-1*(phi_cos*azcos*elsin-phi_sin*elcos),el,elcos,elsin, 0,0,0,
                az2cos,az2sin,0,0,el8cos,el8sin,azcos,azsin,eltan,0,0,0,0,0,0,0]


def finalfitter(dfin, model_phi, model_flags, func, flagstring, oldmodel_params):
    """Take in dataframe, information about model, and function for model
    to fit, a flag string and a list of old params. Then, depending on the
    flagstring it finds formal error constants, then fit the model, and return
    a list of parameter values, parameter errors, a fit, the formatted cor matrix
    from modelcreator, the dataframe with the formal error constants incorporated,
    the formal error constants, and the number of iterations required to find the
    formal error constants. Also apply new sigmas to input prior and post columns.
    """

    #df_original serves as the reference from which the sigmas are adjusted each time the fec change

    df_original = dfin[dfin["indicator"]!="*bad"]
    df_original['indicator']=pd.to_numeric(df_original['indicator'])
    df_original = df_original.reset_index(drop=True)
    df_original["az_input_sigma"]=df_original["az_sigma"]
    df_original["el_input_sigma"]=df_original["el_sigma"]
    df_original["xel_input_sigma"]=df_original["xel_sigma"]
    df_original["az_prior_sigma"] = 0
    df_original["el_prior_sigma"] = 0
    df_original["xel_prior_sigma"] = 0
    df_original["az_post_sigma"] = 0
    df_original["el_post_sigma"] = 0
    df_original["xel_post_sigma"] = 0

    #df_diffsigs is the dataframe in which the sigmas are actually being changed, and from which the fitting is actually done. This only contains 1's.
    df_diffsigs = copy.deepcopy(df_original)
    oldazsigmas = df_original["az_sigma"]
    oldelsigmas = df_original["el_sigma"]

    #setting up variables
    az_fec0 = 1000
    el_fec0 = 1000
    az_fec1 = -1000
    el_fec1 = -1000
    fec_count=0

    if float(flagstring[-3])==0:
        #While the fecs havent stabilized
        while np.absolute(az_fec0-az_fec1)>.000001 or (el_fec0-el_fec1)>.000001:
            az_fec0=az_fec1
            el_fec0=el_fec1
            #calculate a new fit with the new sigmas in df_diffsigs
            paramvallist, paramerrlist, fit, cormatrix, real_residuals = modelcreator(df_diffsigs, model_phi, model_flags, oldmodel_params, func)

            #get a corrected version of df_diffsigs
            df_feccor, dffecstats = corrector(df_diffsigs, model_phi, paramvallist)

            #reset the sigmas of that corrected model to the originals
            df_feccor['az_sigma']=oldazsigmas
            df_feccor['el_sigma']=oldelsigmas

            #Create formal error constants, and then create list of new sigmas for df_diffsigs, and list of full sigmas for the final dataframe (aka the one including 0's)

            #if/else checks if az or xel should be used
            if float(flagstring[-1])==0:
                az_fec1, el_fec1 = secondmodel(df_feccor, 0)
                newazsigmas = [np.sqrt(azs**2+az_fec1**2) for azs in oldazsigmas]
            else:
                az_fec1, el_fec1 = secondmodel(df_feccor, 1)
                newazsigmas = [np.sqrt(azs**2+(az_fec1/math.cos(el))**2) for azs,el in zip(df_original["az_sigma"], df_original["el"])]

            #In either case of az/xel the el_sigmas are calculated the same
            newelsigmas = [np.sqrt(els**2+el_fec1**2) for els in df_original["el_sigma"]]

            #apply the new sigmas before calculating the new fit
            df_diffsigs["el_sigma"]= newelsigmas
            df_diffsigs["az_sigma"]= newazsigmas
            df_diffsigs["el_prior_sigma"]= newelsigmas
            df_diffsigs["az_prior_sigma"]= newazsigmas
            fec_count += 1

        df_diffsigs["az_post_sigma"]=df_diffsigs["az_prior_sigma"]
        df_diffsigs["el_post_sigma"]=df_diffsigs["el_prior_sigma"]
        paramerrsqr=[i**2 for i in paramerrlist]
        for index, row in df_diffsigs.iterrows():
            derivaz=dfun(model_phi, row, 1)
            derivel=dfun(model_phi, row, 0)
            finalderivaz=np.array([])
            finalderivel=np.array([])
            for i in range(len(model_flags)):
                if 3 not in [float(i) for i in model_flags]:
                    if float(model_flags[i])==1:
                        finalderivaz= np.append(finalderivaz, derivaz[i])
                        finalderivel= np.append(finalderivel, derivel[i])
                else:
                    if float(model_flags[i])==3:
                        finalderivaz= np.append(finalderivaz, derivaz[i])
                        finalderivel= np.append(finalderivel, derivel[i])

            finalderivaz = finalderivaz[np.newaxis]
            finalderivel = finalderivel[np.newaxis]
            intermediateaz = np.dot(finalderivaz, fit.covar)
            intermediateel = np.dot(finalderivel, fit.covar)
            finalpostaz = np.dot(intermediateaz, finalderivaz.T)
            finalpostel = np.dot(intermediateel, finalderivel.T)
            df_diffsigs.at[index, "az_post_sigma"]=np.sqrt(np.absolute(df_diffsigs.at[index,"az_sigma"]**2-finalpostaz))
            df_diffsigs.at[index,"el_post_sigma"]=np.sqrt(np.absolute(df_diffsigs.at[index,"el_sigma"]**2-finalpostel))
    else:
        az_fec1=0
        el_fec1=0
        df_diffsigs["az_prior_sigma"]=df_diffsigs["az_input_sigma"]
        df_diffsigs["el_prior_sigma"]=df_diffsigs["el_input_sigma"]
        df_diffsigs["xel_prior_sigma"]=df_diffsigs["xel_input_sigma"]
        df_diffsigs["az_post_sigma"]=df_diffsigs["az_prior_sigma"]
        df_diffsigs["el_post_sigma"]=df_diffsigs["el_prior_sigma"]


    paramvallist, paramerrlist, fit, cormatrix, real_residuals = modelcreator(df_diffsigs, model_phi, model_flags, oldmodel_params, func)
    df_cor_rad, df_cor_stats = corrector(df_diffsigs, model_phi, paramvallist)

    df_cor_rad["xel_input_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df_cor_rad["az_input_sigma"], df_cor_rad["el"])]
    df_cor_rad["xel_prior_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df_cor_rad["az_prior_sigma"], df_cor_rad["el"])]
    df_cor_rad["xel_post_sigma"]=[float(a)*math.cos(float(b)) for a,b in zip(df_cor_rad["az_post_sigma"], df_cor_rad["el"])]

    return paramvallist, paramerrlist, fit, cormatrix, df_cor_rad, df_cor_stats, az_fec1, el_fec1, fec_count


def secondmodel(dfin, xel_flag):
    """Do binary search on the data depending on xel vs az FEC, and return FEC's
    """

    df=dfin[dfin["indicator"]==1]
    az_fec = specbinary(df['az_off'], df["az_sigma"], df["el"], xel_flag, 0, 100)
    el_fec = specbinary(df['el_off'], df["el_sigma"], df["el"], 0, 0, 100)
    return az_fec, el_fec


def specbinary(data, sigma, el_data, xel_flag, mini,maxi):
    """The actual binary search, taking in data, sigma, whether to use xel or az, and then the limits of the search.
    """

    combined_lst=[s**2-d**2 for d,s in zip(data, sigma)]
    n = len(data)
    cutoff=.000001
    top = maxi
    bottom = mini
    while (top-bottom)>cutoff:
        middle = (top+bottom)/2
        if xel_flag==0:
            testval = sum([d**2/(middle**2+s**2) for d,s in zip(data, sigma)])
        else:
            testval = sum([d**2/((middle/math.cos(el))**2+s**2) for d,s,el in zip(data, sigma, el_data)])
        if testval<n:
        #if np.mean([i+middle**2 for i in combined_lst])>0:
            top = middle
        else:
            bottom = middle
    return middle


def chunks(lst, n):
    """Yield successive chunks of length from inputed lst
    """

    for i in range(0, len(lst), n):
        yield lst[i:i + n]


def fitdata(model_phi, model_flags, paramvallist, paramerrlist, fit, version):
    """Take in phi, list of flags, list of parameter values, list of parameter errors, and the fit from modelcreator. Returns a string of fit_data as specified in 'error' documentation
    """

    now = datetime.today()
    #Must be negative since when evaluating I add the offset instead of subtracting (see corrector), so when displaying must show negatives

    paramvallist=[float(mpmath.degrees(-i)) for i in paramvallist]
    paramerrlist=[float(mpmath.degrees(i)) for i in paramerrlist]
    paramvallist=[str("{:15.10f}".format(float(i))) for i in paramvallist]
    paramerrlist=[str("{:15.10f}".format(float(i))) for i in paramerrlist]
    genstring="*\n  "+version+"  "+str(now.year)+"  "+str(now.timetuple().tm_yday)+"  "+str(
        now.hour)+"  "+str(now.minute)+"  "+str(now.second)+'\n*\n'
    paramvalmod=list(chunks(paramvallist, 5))
    paramerrmod=list(chunks(paramerrlist, 5))
    modelflagmod=list(chunks(model_flags, 5))
    modelflagstring=str("{:10.4f}".format(float(model_phi)))
    for i in range(len(modelflagmod)):
        modelflagstring+="  "+" ".join(modelflagmod[i])
    modelflagstring+="\n*\n"
    paramstring=""
    for i in range(len(paramvalmod)):
        paramstring+="".join(paramvalmod[i])+"\n"+"".join(paramerrmod[i])+"\n*\n"
    finalstring=genstring+modelflagstring+paramstring
    return finalstring


def conditions(fit):
    """Creates the conditions lines of err file, including the condition number of the covariance, and independent variable fitting.
    """

    diagonal = np.diagonal(fit.covar)
    cond_num = np.linalg.cond(fit.covar)
    inv_cov = np.linalg.inv(fit.covar)
    inv_diagonal = np.diagonal(inv_cov)
    inv_diagonal_weight = [1/x for x in inv_diagonal]
    pconditions = [np.sqrt(a/b) for a,b in zip(diagonal, inv_diagonal_weight)]
    conditionstring='\n*\n   '+'{:.2e}'.format(Decimal(cond_num))+'\n*\n'+''.join(['{:7.1f}'.format(i) for i in pconditions])+'\n*'
    return conditionstring


def newmodelmaker(model_phi, model_flags, paramvallist, version):
    """Take in phi, list of parameter flags, and list of parameter values, and return string for outputting of new_model section as specified in 'error' documentation
    """

    now = datetime.today()
    paramvallist=[float(mpmath.degrees(-i)) for i in paramvallist]
    paramvallist=[str("{:15.10f}".format(float(i))) for i in paramvallist]
    genstring="*\n  "+version+"  "+str(now.year)+"  "+str(now.timetuple().tm_yday)+"  "+str(now.hour)+"  "+str(now.minute)+"  "+str(now.second)+'\n*\n'
    paramvalmod=list(chunks(paramvallist, 5))
    modelflagmod=list(chunks(model_flags, 5))
    modelflagstring=str("{:10.4f}".format(float(model_phi)))
    for i in range(len(modelflagmod)):
        modelflagstring+="  "+" ".join(modelflagmod[i])
    modelflagstring+="\n*\n"
    paramstring=""
    for i in range(len(paramvalmod)):
        paramstring+="".join(paramvalmod[i])+"\n*\n"
    finalstring=genstring+modelflagstring+paramstring
    return finalstring


def fitstats(df, fit, az_fec, el_fec, fec_steps):
    """Take in dataframe, fir, the az and el formal error constant, and the number of steps needed to achieve those formal error constants
    """

    el_fec=el_fec*180/math.pi
    az_fec=az_fec*180/math.pi

    halflength=len(fit.residual)//2
    steps = fit.nfev
    rt_chi = np.sqrt(fit.redchi)
    az_nrms = fitnrms(df["az_off"], df["az_sigma"])
    el_nrms = fitnrms(df["el_off"], df["el_sigma"])
    free = fit.nfree
    fit_stats=[steps, rt_chi, az_nrms, el_nrms, free, az_fec, el_fec, fec_steps]
    for i in range(len(fit_stats)):
        if i==0 or i==4 or i ==7:
            fit_stats[i]=str("{:6d}".format(int(fit_stats[i])))
        elif i==5 or i==6:
            fit_stats[i]=str("{:11.5f}".format(float(fit_stats[i])))
        else:
            fit_stats[i]=str("{:8.3f}".format(float(fit_stats[i])))
    return fit_stats


def fitnrms(data, weights):
    """Take in list of data and weights and return value of nrms as specified in 'error' documentation
    """

    return (np.sqrt(np.sum([d**2/w**2 for d,w in zip(data,weights)])/len(data)))


def statsnumformatter(lst):
    """Tool to turn lst of numbers into desired format of number for outputs
    """

    outlst=[]
    for i in range(len(lst)):
        if i==5 or i==6:
            outlst.append(str("{:7d}".format(int(lst[i]))))
        else:
            outlst.append(str("{:11.5f}".format(float(lst[i]))))
    return outlst


def matrixprinter(cormatrix):
    """Takes in the correlation matrix from lmfit and returns a string of the lower triangular form of the correlation matrix as desired for output to error file as specified in 'error' documentation
    """

    finalstr="*\n"
    cormatrix=cormatrix.astype('str')
    for i in range(cormatrix.shape[0]):
        finalstr+=''.join(cormatrix[i,:][:(i+1)])+'\n*\n'
    return finalstr


def errorprinter(name, all_info, df_obs, df_obs_stats, df_unc, df_unc_stats, df_cor, df_cor_stats, old_model, fit_data, fit_stats, newmodel, cormatrix, conditionstring, flagstring, logfile):
    """Takes in all parts of error file for writing and writes error file in correct format to filename 'name'"""

    hexval= '{:x}'.format(int(flagstring, 2))

    df_obs=df_obs[df_obs["indicator"]!="*bad"]
    with open("/usr2/log/"+name, 'w') as f:
        f.write('$antenna\n')
        f.write(all_info+'   '+str(hexval)+'   v2   '+os.path.basename(logfile))
        f.write('\n$observed\n')
        f.write(df_obs.to_string(header=False,index=False, float_format="{:10.5f}".format, columns=['indicator','az','el','az_off','el_off', 'off_vector']))
        f.write('\n$observed_stats\n')
        f.write('   '+''.join(df_obs_stats))
        f.write('\n$old_model')
        f.write(old_model)
        f.write('$uncorrected\n')
        f.write(df_unc.to_string(header=False, index=False, float_format="{:10.5f}".format, columns=['indicator','az','el','az_off','el_off','off_vector']))
        f.write('\n$uncorrected_stats\n')
        f.write('   '+''.join(df_unc_stats))
        f.write('\n$fit_data\n')
        f.write(fit_data)
        f.write('\n$fit_stats\n')
        f.write('   '+'  '.join(fit_stats))
        f.write('\n$conditions')
        f.write(conditionstring)
        f.write('\n$correlations\n')
        f.write(cormatrix)
        f.write('$corrected\n')
        f.write(df_cor.to_string(header=False, index=False, float_format="{:10.5f}".format, columns=['indicator','az','el','az_off','el_off','off_vector', 'az_post_sigma', 'el_post_sigma', 'az_prior_sigma', 'el_prior_sigma']))
        f.write('\n$corrected_stats\n')
        f.write('   '+''.join(df_cor_stats))
        f.write('\n$new_model\n')
        f.write(newmodel)
    return 0


def reprocessdf(dfin, modelctr):
    generalcounter = len(dfin.index)
    df_rad = dfin[dfin['indicator']!='*bad']
    df_statframe = copy.deepcopy(df_rad)
    df_statframe['indicator']=pd.to_numeric(df_statframe['indicator'])
    df_statframe = df_statframe[df_statframe["indicator"]!=0]
    df_statframe = df_statframe.reset_index(drop=True)
    goodcounter = len(df_statframe.index)
    df_stats = dfstater(df_statframe, goodcounter, generalcounter)

    model_all, model_phi, model_flags, model_params, version = modelreader(modelctr)
    df_unc_rad, df_unc_stats = corrector(df_rad, model_phi, model_params)
    return df_rad, df_stats, df_unc_rad, df_unc_stats


def general(infile, modelctr):
    """Takes in filename, and does initial processing of file to create a working dataframe, 'df_rad', and the required dataframes for outputting to certain parts of the error file 'df_deg'. Also reads in old model.
    Processing depends on whether a log file or an xtr file, as must write a xtr file if that is the first time opening a log.
    """

    vnumber=0 #set version to zero so no error is spit out
    filename = os.path.basename(infile)

    if ".log" in infile:
        xtrname = 'xtr'+re.search(r'point\.*(.*).log', infile).group(1)
        df, all_info = extracter(infile)
        df_rad=radiafy(df)
        df_rad, df_stats = handler(df_rad)
        df_deg = unradiafy(df_rad)
        flagstring='0011'
        model_all, model_phi, model_flags, model_params, version = modelreader(modelctr)
        xtracprinter(xtrname, df_deg, df_stats,all_info, flagstring, model_all, filename)
    else:
        df_init, df_stats, all_info, flagstring, old_modelstr, vnumber = reader1(infile)
        xtrname=infile
        df_rad = radiafy(df_init)
        df_rad, df_stats = handler(df_rad)
        df_deg = unradiafy(df_rad)
    if vnumber==2:
        model_all, model_phi, model_flags, model_params, version = modelreader(old_modelstr)
    else:
        model_all, model_phi, model_flags, model_params, version = modelreader(modelctr)
    df_unc_rad, df_unc_stats = corrector(df_rad, model_phi, model_params)
    df_deg=unradiafy(df_rad)

    version = str(int(version)+1)
    version = version.rjust(5, '0')

    return df_unc_rad, df_rad, df_deg, model_phi, model_flags, model_params, all_info, df_stats, df_unc_stats, model_all, flagstring, xtrname, version, filename


def general2(df_unc_rad, df_rad, model_phi, model_flags, oldmodel_params, all_info, df_stats, df_unc_stats, model_all, flagstring, version, infile):
    """Takes in all of the things from general, and does the fitting, corrects for that fitting, and then prepares all the outputs and writes the error file.
    """

    df_unc_deg = unradiafy(df_unc_rad)
    df_deg = unradiafy(df_rad)
    az_fec, el_fec, fec_steps = 0,0,0
    paramvallist, paramerrlist, fit, cormatrix, df_cor_rad, df_cor_stats, az_fec, el_fec, fec_steps= finalfitter(df_unc_rad, model_phi, model_flags, func, flagstring, oldmodel_params)
    #paramvallist, paramerrlist, fit, cormatrix, real_residuals=modelcreator(df_unc_rad, model_phi, model_flags, func)
    df_cor_deg = unradiafy(df_cor_rad)


    conditionstring = conditions(fit)
    fit_data=fitdata(model_phi, model_flags, paramvallist, paramerrlist, fit, version)
    fit_stats = fitstats(df_cor_rad, fit, az_fec, el_fec, fec_steps)
    newmodel = newmodelmaker(model_phi, model_flags, paramvallist, version)
    cor_matrix = matrixprinter(cormatrix)
    #allwriter("xtrtester", "errtester", all_info, df_deg, df_stats, df_unc_deg, df_unc_stats, df_cor_deg, df_cor_stats, model_all, fit_data, fit_stats, newmodel, cor_matrix, conditionstring, flagstring, infile)

    return df_cor_deg, df_unc_deg, model_flags, df_cor_stats, (az_fec*180/math.pi), (el_fec*180/math.pi), np.sqrt(fit.redchi), fit.nfree, conditionstring, fit_data, fit_stats, newmodel,cor_matrix


def allwriter(xtrname, errname, all_info, df_deg, df_stats, df_unc_deg, df_unc_stats, df_cor_deg, df_cor_stats, model_all, fit_data, fit_stats, newmodel, cor_matrix, conditionstring, flagstring, logfile):
    """Function to be called to write new version of both xtr and err files
    """

    errorprinter(errname, all_info, df_deg, df_stats, df_unc_deg, df_unc_stats, df_cor_deg, df_cor_stats, model_all, fit_data, fit_stats, newmodel, cor_matrix, conditionstring, flagstring, logfile)
    xtracprinter(xtrname, df_deg, df_stats,all_info, flagstring, model_all, logfile)
    return 0





if __name__ == '__main__':
    #az_range_deg = np.linspace(1, 355, 70)
    #az_range = [(float(mpmath.radians(i))) for i in az_range_deg]
    #el_range_deg = np.linspace(1, 88, 70)
    #el_range = [(float(mpmath.radians(i))) for i in el_range_deg]
    #phi_radc = float(mpmath.radians(90))
    #phirad = np.full_like(az_range, phi_radc)
    #phi_cos = np.array([float(mpmath.cos(i)) for i in phirad])
    #phi_sin = np.array([float(mpmath.sin(i)) for i in phirad])
    #az = np.array([float(i) for i in az_range])
    #el = np.array([float(i) for i in el_range])
    #azsin = [float(mpmath.sin(i)) for i in az]
    #az2sin = [float(mpmath.sin(2*i)) for i in az]
    #azcos = [float(mpmath.cos(i)) for i in az]
    #az2cos = [float(mpmath.cos(2*i)) for i in az]
    #elsin = [float(mpmath.sin(i)) for i in el]
    #el8sin = [float(mpmath.sin(8*i)) for i in el]
    #elcos = [float(mpmath.cos(i)) for i in el]
    #el8cos = [float(mpmath.cos(8*i)) for i in el]
    #elsec = [float(mpmath.sec(i)) for i in el]
    #eltan = [float(mpmath.tan(i)) for i in el]
    #p=[1,0,3,4,5,6,7,8,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    #p=[float(mpmath.radians(i/1000)) for i in p]
    #az_off, el_off = func22(az_range, el_range, az, el, azsin, az2sin, azcos, az2cos, elsin, el8sin, elcos, el8cos, elsec, eltan, phi_cos, phi_sin, p)
    #az_off_deg = [(float(mpmath.degrees(i))) for i in az_off]
    #el_off_deg = [(float(mpmath.degrees(i))) for i in el_off]
    #print(az_off)
    #print(az_off_deg)
    #negazoff = np.array([float(-i) for i in az_off])
    #negeloff = np.array([float(-i) for i in el_off])
    #modelfinaldata = np.concatenate((negazoff, negeloff))
    #model_flags=[1,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    #params = Parameters()
    #for i in range(0, len(model_flags)):
    #    if float(model_flags[i]) != 0:
    #        params.add('p'+str(i+1), value = 0)
    #    else:
    #        params.add('p'+str(i+1), value = 0, vary=False)
    #gmodel = Model(func, independent_vars=['az_offset', 'el_offset','az','el', 'azsin','az2sin','azcos', 'az2cos',
    #                                       'elsin','el8sin', 'elcos', 'el8cos', 'elsec', 'eltan', 'phi_cos', 'phi_sin'])
    #fit = gmodel.fit(modelfinaldata, params,az_offset=az_range, el_offset=el_range, az=az, el=el,
    #                 azsin=azsin, az2sin=az2sin, azcos=azcos, az2cos=az2cos, elsin=elsin, el8sin=el8sin,
    #                 elcos=elcos, el8cos=el8cos, elsec=elsec, eltan=eltan, phi_cos=phi_cos, phi_sin=phi_sin, scale_covar=False)
    #print(fit.fit_report())
    #simxtrac(az_range_deg, el_range_deg, az_off_deg, el_off_deg)
    #general("point.19.165.log", "mdlpo.ctl")
    simxtrac()
