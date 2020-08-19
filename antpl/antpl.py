#!/usr/bin/env python3
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

import sys
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import re
import getopt
from io import StringIO
from scipy import stats
import pandas as pd
from datetime import datetime, timedelta
import itertools
import gzip
import warnings

#Suppress warnings so user doesn't have to deal with inconsequential stuff
warnings.filterwarnings('ignore')

#set cwd to /usr2/log/
os.chdir("/usr2/log/")

#Set backend so that it guarantees it will work
mpl.use('QT5Agg',warn=False, force=True)

def uniter(axistext):
    '''Takes in name of axis and returns user friendly display of axis and
    units. If it doesn't know the inputted axis, then it return name all caps.
    '''

    axisname = axistext.lower()
    if axisname == 'time':
        return 'Time (hours after start)'
    elif axisname == 'az':
        return 'Azimuth (degrees)'
    elif axisname == 'el':
        return 'Elevation (degrees)'
    elif axisname == 'comp':
        return 'Compression'
    elif axisname == 'tsys':
        return 'TSYS (K)'
    elif axisname == 'sefd':
        return 'SEFD (Jy)'
    elif axisname == 'tcalj':
        return 'Tcalj (Jy)'
    elif axisname == 'tcalr':
        return 'Tcalr'
    else:
        return axistest.upper()


def date2spec(i):
    '''Takes in a datetime object, and then outputs it in string.
    String has form YEARyDAYdHOURhMINm
    '''

    return(str(i.year)+'y'+str(i.timetuple().tm_yday)+'d'+i.strftime('%H')+'h'
           +i.strftime('%M')+'m')



def outlier_remover(df_in, datacol, zval):
    '''Takes in a datadf, column, and value and throws out all rows in datadf
    which have a z-score beyond that value in that column
    '''

    df_out=pd.DataFrame(
        columns=['time','source','az','el','de','i','p',
                 'center','comp','tsys','sefd','tcalj','tcalr'])
    list_data= df_in[datacol].values
    list_zscore=np.abs(stats.zscore(list_data))
    row_counter=0
    row_removal=[]

    #create list of rows with z-score too high or too low
    for i in list_zscore:
        if i < zval:
            row_removal.append(row_counter)
        row_counter+=1
    for k in range(0,len(row_removal)):
        df_out.loc[k]=df_in.loc[row_removal[k]]
    df_out=df_out.reset_index(drop=True)
    return df_out


def discover(file_in, source_list, if_list, pol_list, det_list):
    '''Read in file (and unzip), create a df with data, then run discoveraux
    for each source in source_list.
    '''

    #turn file into dataframe
    df_lines = 'time,source,az,el,de,i,p,center,comp,tsys,sefd,tcalj,tcalr'
    if file_in.endswith('.gz'):
        with gzip.open(file_in, 'r') as f:
            file_content = f.read()
            file_content = file_content.decode('latin-1')
            filefinal = StringIO(file_content)
            for line in filefinal:
                if 'VAL' in line:
                    line=re.sub('\s+', ',', line.strip()) #Necessary cleanup
                    df_lines+='\n'
                    df_lines+=line
    else:
        with open(file_in, 'r', encoding='latin-1') as f:
            for line in f:
                if 'VAL' in line:
                        line=re.sub('\s+', ',', line.strip())
                        df_lines+='\n'
                        df_lines+=line
    df = pd.read_csv(StringIO(df_lines))
    all_sources=df['source'].drop_duplicates().values.tolist()
    final_sources=[]

    #Run discoveraux for each of the desired sources
    for i in source_list:
        for j in all_sources:
            if i in j:
                final_sources.append(j)
    for source in final_sources:
        discoveraux(file_in, source, if_list, pol_list, det_list, df)
    return 0


def discoveraux(file_in, source, if_list, pol_list, det_list, df):
    '''Reduce df down to anything that is of correct source and in intersection
    of if_list, pol_list, and det_list. Then creates a list of
    risetimes for that data and prints out each rise-set cycle info to std out.
    '''

    endtime = datetime.strptime(df.iloc[-1,0][:20], '%Y.%j.%H:%M:%S.%f')
    df_drops = list(range(0,len(df.index)))
    df_nondrops=[]
    #Throw out all rows which don't fit the criteria of if, pol, det, source
    for index, row in df.iterrows():
        for ifval, pol, det in itertools.product(if_list, pol_list, det_list):
            if ifval in str(row['i']) and pol in str(row['p']) \
               and det in str(row['de']) and source in str(row['source']):
                df_nondrops.append(index)
    for ele in sorted(df_nondrops, reverse = True):
        df_drops.remove(ele)
    df=df.drop(df_drops)
    df.reset_index(inplace=True, drop=True)

    all_dets_list = df['de'].drop_duplicates().tolist()
    all_dets_string = ':'.join(map(str, all_dets_list))
    risetime_list = []
    pre_risetime_list = []
    rise_flag=0

    #Create list of risetimes, and a list of times just before risetimes to
    #use as settimes. If points separated by > 12hrs then on own rise-set cycle
    for index, row in df.iterrows():
        if row['source'] == source and row['az'] <= 180:
            if rise_flag == 0:
                row_time = datetime.strptime(row['time'][:20],
                                             '%Y.%j.%H:%M:%S.%f')
                risetime_list.append(row_time-timedelta(hours=.5))
                rise_flag = 1
            else:
                if index > 0:
                    row_time = datetime.strptime(row['time'][:20],
                                                 '%Y.%j.%H:%M:%S.%f')
                    row_time_num = mpl.dates.date2num(row_time)
                    prev_row = index-1
                    prev_row_time_num = mpl.dates.date2num(
                        datetime.strptime(df.at[prev_row,'time'][:20],
                                          '%Y.%j.%H:%M:%S.%f'))
                    if (row_time_num - prev_row_time_num) > .5:
                        risetime_list.append(row_time-timedelta(hours=.5))
        if row['source'] == source and row['az']>180:
            if rise_flag == 1:
                rise_flag = 0
            else:
                if index > 0:
                    row_time = datetime.strptime(row['time'][:20],
                                                 '%Y.%j.%H:%M:%S.%f')
                    row_time_num = mpl.dates.date2num(row_time)
                    prev_row = index-1
                    prev_row_time_num= mpl.dates.date2num(
                        datetime.strptime(df.at[prev_row,'time'][:20],
                                          '%Y.%j.%H:%M:%S.%f'))
                    if (row_time_num - prev_row_time_num) > .5:
                        risetime_list.append(row_time - timedelta(hours=.5))

    #Match up two lists, so that entire rise-set cycle is in time restriction
    for i in range(0, len(risetime_list)-1):
        pre_risetime_list.append(risetime_list[i+1])
    pre_risetime_list.append(endtime)

    #print results to std out
    for i in range(0, len(risetime_list)):
        sys.stdout.write('-s  '+source+'\t -z  '+date2spec(risetime_list[i])+
                         ':'+date2spec(pre_risetime_list[i])+' \t -d  '+
                         all_dets_string+' \t'+file_in+'\n')
    return 0


def filehandler(file_in, source, det_list, stat_flag, yax, dates, stat_val,
                risesetflag, listpolarizations, listIFvals, avg_flag):
    '''Take in file (unzip if necessary), turn it into a dataframe,
    then apply filters to it to only get the desired data out of the dataframe,
    then rewrites time and detector columns to set cycle and rising/setting,
    then can apply outlier handling or averaging
    '''

    #convert dates to datetime objects
    try:
        date1=datetime.strptime(dates[0],'%Yy%jd%Hh%Mm')
    except:
        try:
            date1=datetime.strptime(dates[0],'%Yy%jd%Hh')
        except:
            try:
                date1=datetime.strptime(dates[0],'%Yy%jd')
            except:
                try:
                    date1=datetime.strptime(dates[0],'%Yy')
                except Exception as err:
                    print('There was an error in the format of your dates. '+
                          '\nShould be in form YEARyDAYdHOURhMINm, or any '+
                          'truncated subsets: 2012y20d23h56m, 2019y80d07h, '+
                          '2000y28d, 2007y\n\Look at "'+prog+' -h" for help')
                    sys.exit()
    try:
        date2=datetime.strptime(dates[1],'%Yy%jd%Hh%Mm')
    except:
        try:
            date2=datetime.strptime(dates[1],'%Yy%jd%Hh')
        except:
            try:
                date2=datetime.strptime(dates[1],'%Yy%jd')
            except:
                try:
                    date2=datetime.strptime(dates[1],'%Yy')
                except Exception as err:
                    print('There was an error in the format of your dates.'+
                          '\nShould be in form YEARyDAYdHOURhMINm, or any'+
                          ' truncated subsets: 2012y20d23h56m, 2019y80d07h, '+
                          '2000y28d, 2007y\n\ Look at "'+prog+' -h" for help')
                    sys.exit()


    #Turn file into Dataframe
    lines = 'time,source,az,el,de,i,p,center,comp,tsys,sefd,tcalj,tcalr'
    stationflag=0
    if file_in.endswith('.gz'):
        f = gzip.open(file_in, 'r')
        file_content = f.read()
        file_content = file_content.decode('latin-1')
        filefinal = StringIO(file_content)
        for line in filefinal:
                if 'location,' in line and stationflag==0:
                    station=re.search(r'\;location,[a-zA-Z1-9]+',
                                      str(line)).group()[10:]
                    stationflag=1
                if 'VAL' in line:
                    lines+='\n'
                    line=re.sub('\s+', ',', line.strip())
                    lines+=line
    else:
        with open(file_in, 'r', encoding='latin-1') as f:
            for line in f:
                if 'location,' in line and stationflag==0:
                    station=re.search(r'\;location,[a-zA-Z1-9]+',
                                      str(line)).group()[10:]
                    stationflag=1
                if 'VAL' in line:
                    lines+='\n'
                    line=re.sub('\s+', ',', line.strip())
                    lines+=line
    df=pd.read_csv(StringIO(lines))
    if df.empty:
        print('Error:\nNo data matches what your flags dictate!\nCheck'+
              'to make sure -s,-d,-i, and -p are all correct, and not'+
              ' mutually exclusive. \nLook at "-h" for help')
        sys.exit()

    #remove rows which don't meet criteria of being in intersection of if,
    #pol, det, and source
    df_drops=list(range(0,len(df.index)))
    df_nondrops=[]
    for index, row in df.iterrows():
        for IFval, pol, det in itertools.product(
                listIFvals, listpolarizations, det_list):
            if IFval in str(row['i']) and pol in str(row['p']) \
               and det in str(row['de']) and source in str(row['source']):
                for j in yax:
                    if '$$' not in str(row[j]):
                        df_nondrops.append(index)

    #only drop each row once, and must drop in reverse order to keep indexing
    for ele in sorted(np.unique(np.array(df_nondrops)), reverse = True): 
        df_drops.remove(ele)

    df=df.drop(df_drops)
    if df.empty:
        print('Error:\nNo data matches what your flags dictate!\n'+
        'Check to make sure -s,-d,-i, and -p are all correct, and not '+
        'mutually exclusive. \nLook at "-h" for help')
        sys.exit()
    df.reset_index(drop=True, inplace=True)

    source= df.at[1,'source']
    all_dets=df['de'].drop_duplicates().tolist()

    #If date1 has been specified call that the starting time, otherwise call
    #the beginning of the file the starttime
    if date1==datetime.strptime('0001y1d1h','%Yy%jd%Hh'):
        starttime=datetime.strptime(df.at[1,'time'][:20], '%Y.%j.%H:%M:%S.%f')
    else:
        starttime=date1
    date2fromcycle = mpl.dates.date2num(date2) - mpl.dates.date2num(starttime)

    #Fixing times, and cycles in the data
    df_drops=[]
    rise_flag=0
    rise_counter=0
    avg_counter=1
    for index, row in df.iterrows():
        #Convert all rows with data for graphing to floats
        for j in yax:
            df.at[index,j] = float(df.at[index, j])

        row_date = datetime.strptime(row['time'][:20], '%Y.%j.%H:%M:%S.%f')
        final_row_date= mpl.dates.date2num(row_date)- \
            mpl.dates.date2num(starttime)
        df.at[index,'time']= final_row_date*24

        #Add rising or setting to the detector name
        #Adjust rise_counter to count which rise/set cycle we are on,
        #And if there is a 12 hour gap then a new rise/set cycle begins
        if row['az']<=180:
            df.at[index, 'de']=df.at[index,'de']+' rising '
            if rise_flag==0:
                rise_flag=1
                rise_counter+=1
            else:
                if index>0:
                    prev_row=index-1
                    prev_row_date=df.at[prev_row,'time']
                    if (df.at[index,'time'] - prev_row_date) > 12:
                        rise_counter+=1
        if row['az']>180:
            df.at[index, 'de']=df.at[index,'de']+' setting'
            if rise_flag == 1:
                rise_flag = 0
            else:
                if index > 0:
                    prev_row = index-1
                    prev_row_date = df.at[prev_row,'time']
                    if (df.at[index,'time'] - prev_row_date) > 12:
                        rise_counter+=1

        #Add the number of the rise/set cycle to the name of the detector
        df.at[index, 'de']='cycle'+str(rise_counter)+' '+df.at[index,'de']

        #Filter data so in-between date1 and date2
        if df.at[index,'time']<0 or df.at[index,'time']>(date2fromcycle*24+.4):
            df_drops.append(index)

        #Do averaging of data for all points which are at the same time
        #Do this by increasing avg counter each time two rows have same time,
        #Then divide by that total number and reset it once the time changes
        #Also join detector names (but just the 15d0 part)
        if avg_flag and index>0:
            if index > 1 and round(df.at[(index-2),'time'],
                                   4) != round(df.at[(index-1),'time'],4):
                df.at[(index-2),'center']=df.at[(index-2),'center']/avg_counter
                df.at[(index-2),'comp'] = df.at[(index-2),'comp']/avg_counter
                df.at[(index-2),'tsys'] = df.at[(index-2),'tsys']/avg_counter
                df.at[(index-2),'sefd'] = df.at[(index-2),'sefd']/avg_counter
                df.at[(index-2),'tcalj'] = df.at[(index-2),'tcalj']/avg_counter
                df.at[(index-2),'tcalr'] = df.at[(index-2),'tcalr']/avg_counter
                avg_counter=1

            if round(df.at[index,'time'],4)==round(df.at[(index-1),'time'],4):
                prev_row=index-1
                df_drops.append(prev_row)
                df.at[index,'de']=','.join(
                    all_dets)+' '+df.at[index,'de'][:7]+df.at[index,'de'][-7:]
                df.at[index,'center']=float(df.at[index,'center'])+float(
                    df.at[prev_row,'center'])
                df.at[index,'comp']=float(df.at[index,'comp'])+float(
                    df.at[prev_row,'comp'])
                df.at[index,'tsys']=float(df.at[index,'tsys'])+float(
                    df.at[prev_row,'tsys'])
                df.at[index,'sefd']=float(df.at[index,'sefd'])+float(
                    df.at[prev_row,'sefd'])
                df.at[index,'tcalj']=float(df.at[index,'tcalj'])+float(
                    df.at[prev_row,'tcalj'])
                df.at[index,'tcalr']=float(df.at[index,'tcalr'])+float(
                    df.at[prev_row,'tcalr'])
                avg_counter+=1

    df=df.drop(df_drops)
    df=df.reset_index(drop=True)

    #Remove outliers if flag is present
    if stat_flag:
        for j in yax:
            df=outlier_remover(df, j, stat_val)
    df=df.sort_values(['de', 'time'])
    return df,station,source, starttime, file_in, all_dets

def grapher(df, xax_list, yax_list, lowerlim_list, upperlim_list, save_flag,
            station, source, risetime, print_flag, det_list, savedets_flag,
            file_in, rs_combine, all_dets):
    '''Prints out grid of graphs with all combinations of
    y-axix and x-axis graphs
    '''

    #Specify order of colors to graph so rising/setting gets warm/cool colors
    colors=['r', 'b', 'orange', 'green' , 'peru', 'magenta',
            'salmon', 'teal', 'gold', 'lime']
    mpl.rcParams['axes.prop_cycle'] = mpl.cycler(color=colors)

    #For each pair of x-axis and y-axis create a new graph in the right spot
    fig = plt.figure(figsize=(20, 10), dpi=80, facecolor='white')
    plot_number = 1
    for i in range(0, len(yax_list)):
        for k in range(0, len(xax_list)):
            ax = plt.subplot(len(yax_list), len(xax_list), plot_number)
            ax.minorticks_on()
            ax.tick_params(axis='x', which='minor', direction='out')
            plot_number+=1

            #If combining rising and setting use same colors for both, and only
            #label 1 of them (remove rising/setting from label name altogether)
            if rs_combine:
                used_labels=[]
                colorlabel=-1
                for name, group in df.groupby('de'):
                    #General note, name[:-7] gives detector name
                    #without rising/setting, but still with cycle #
                    if name[:-7] not in used_labels:
                        colorlabel+=1
                        group.plot(xax_list[k],y=yax_list[i], label=name[:-7],
                                   ax=ax, marker='o', legend =False,
                                   color=colors[colorlabel])
                        used_labels.append(name[:-7])
                    else:
                        group.plot(xax_list[k],y=yax_list[i], label='',
                                   ax=ax, marker='o', legend =False,
                                   color=colors[colorlabel])

            #If not combining rising/setting then graph each detector seperate
            else:
                for name, group in df.groupby('de'):
                    group.plot(xax_list[k],y=yax_list[i], label=name,
                               ax=ax, marker='o', legend =False)

            #General Graph formatting for each subplot
            ax.grid(linestyle='--')
            plt.xlabel(uniter(xax_list[k]))
            plt.ylabel(uniter(yax_list[i]))
            if not upperlim_list[i] == -1:
                plt.ylim(top=int(upperlim_list[i]))
            if not lowerlim_list[i] == -1:
                plt.ylim(bottom=int(lowerlim_list[i]))


    ax.legend() #Only include legend on last subplot

    #Overall figure formatting, including title and printing
    fig.suptitle(str(station)+'   '+str(source)+'   '+date2spec(risetime)+
                 '   '+file_in, y=.98, fontsize=20)
    fig.tight_layout(rect=[0, 0.03, 1, 0.95])
    if save_flag:
        if savedets_flag:
            plt.savefig(str(station).lower()+'_'+str(source)+'_'+
                        date2spec(risetime)+'_'+','.join(yax)+'_'+
                        ','.join(xax)+'_'+','.join(all_dets)+'.pdf')
        else:
            plt.savefig(str(station).lower()+'_'+str(source)+'_'+
                        date2spec(risetime)+'_'+','.join(yax)+'_'+
                        ','.join(xax)+'.pdf')
    if print_flag:
        plt.show()

    return 0


def azeltimegrapher(df, xax_list ,yax_list, lowerlim_list, upperlim_list,
                    save_flag, station, source, risetime, print_flag, det_list,
                    savedets_flag, legend_loc, file_in, rs_combine, all_dets):
    '''Prints out separate graphs for each y-axis,
    each with specific azeltime layout for x-axis.
    '''

    #Specify order of colors to graph so rising/setting gets warm/cool colors
    colors = ['r', 'b', 'orange', 'green' , 'peru',
              'magenta', 'salmon', 'teal', 'gold', 'lime']
    mpl.rcParams['axes.prop_cycle'] = mpl.cycler(color=colors)
    #Create separate plot for each y-axis provided
    for i in range(0, len(yax_list)):
        yax = yax_list[i]
        fig = plt.figure(figsize=(20, 10), dpi=80, facecolor='white')
        #Create special azeltime layout for the plotting
        ax1 = fig.add_subplot(2, 2, (1,2))
        ax2 = fig.add_subplot(223)
        ax3 = fig.add_subplot(224)

        #If combining rising/setting then only change colors if the detector
        #name (without rising/setting) hasn't been used before. This way same
        #detector name (With rising/setting taken off) will get the same color
        #If not combining rising/setting then just graph each detector
        #(including r/s and cycle#) as own line and color. Group.plot lines
        #specify which x-axis goes subplot and actually does the graphing
        if rs_combine:
            used_labels = []
            colorlabel = -1
            for name, group in df.groupby('de'):
                #General note, name[:-7] gives detector name without
                #rising/setting, but still with cycle #
                if name[:-7] not in used_labels: 
                    colorlabel+=1
                    group.plot(x='time',y=yax, label=name[:-7], ax=ax1,
                               marker='o', legend =False,
                               color=colors[colorlabel])
                    group.plot(x='az',y=yax, label=name[:-7], ax=ax2,
                               marker='o', legend =False,
                               color=colors[colorlabel])
                    group.plot(x='el',y=yax, label=name[:-7], ax=ax3,
                               marker='o', legend =False,
                               color=colors[colorlabel])
                    used_labels.append(name[:-7])
                else:
                    group.plot(x='time',y=yax, label='', ax=ax1, marker='o',
                               legend =False, color=colors[colorlabel] )
                    group.plot(x='az',y=yax, label='', ax=ax2, marker='o',
                               legend =False, color=colors[colorlabel] )
                    group.plot(x='el',y=yax, label='', ax=ax3, marker='o',
                               legend =False, color=colors[colorlabel] )
        else:
            for name, group in df.groupby('de'):
                group.plot(x='time',y=yax, label=name, ax=ax1,
                           marker='o', legend =False)
                group.plot(x='az',y=yax, label=name, ax=ax2,
                           marker='o', legend =False)
                group.plot(x='el',y=yax, label=name, ax=ax3,
                           marker='o', legend =False)

        #Must sequentially specify each format for all three subplots
        if not int(upperlim_list[i]) == -1:
            ax1.set_ylim(top=upperlim_list[i])
            ax2.set_ylim(top=upperlim_list[i])
            ax3.set_ylim(top=upperlim_list[i])
        if not int(lowerlim_list[i]) == -1:
            ax1.set_ylim(bottom=lowerlim_list[i])
            ax2.set_ylim(bottom=lowerlim_list[i])
            ax3.set_ylim(bottom=lowerlim_list[i])
        ax1.grid(linestyle='--')
        ax2.grid(linestyle='--')
        ax3.grid(linestyle='--')
        ax1.set_ylabel(uniter(yax))
        ax2.set_ylabel(uniter(yax))
        ax3.set_ylabel(uniter(yax))
        ax1.set_xlabel(uniter('time'))
        ax2.set_xlabel(uniter('az'))
        ax3.set_xlabel(uniter('el'))
        ax1.minorticks_on()
        ax1.tick_params(axis='x', which='minor', direction='out')
        ax2.minorticks_on()
        ax2.tick_params(axis='x', which='minor', direction='out')
        ax3.minorticks_on()
        ax3.tick_params(axis='x', which='minor', direction='out')

        #Determine which subplot gets the legend, defaults to time plot (ax1)
        if legend_loc=='t':
            ax1.legend()
        if legend_loc=='a':
            ax2.legend()
        if legend_loc=='e':
            ax3.legend()

        #General formatting, including saving and printing
        fig.suptitle(str(station)+'   '+str(source)+'   Start='+
                     date2spec(risetime)+'   '+file_in, y=.98, fontsize=20)
        fig.tight_layout(rect=[0, 0.03, 1, 0.95])
        if save_flag:
            if savedets_flag:
                plt.savefig(station.lower()+'_'+source+'_'+
                            date2spec(risetime)+'_'+yax+'_'+'azeltime'+'_'+
                            ','.join(all_dets)+'.pdf')
            else:
                plt.savefig(station.lower()+'_'+source+'_'+
                            date2spec(risetime)+'_'+yax+'_'+'azeltime'+'.pdf')
        if print_flag:
            plt.show()
    return 0


def total(file_in, source, xax_list ,yax_list, det_list, pol_list,if_list,
          dates, stat_flag, stat_val, rs_combine, avg_flag,lower_list,
          upper_list, multi_flag, legend_loc, savedets_flag,
          save_flag, print_flag):
    """The intermediate function which decides which functions need to be
    used depending on user input, either azeltime or regular
    """

    df,station,source, risetime, file_in, all_dets = \
        filehandler(file_in, source, det_list, stat_flag, yax_list, dates,
                    stat_val, rs_combine, pol_list, if_list, avg_flag)

    #If multi_flag then print out separate windows for each subplot
    if multi_flag:
        for k in xax_list:
            for i in yax_list:
                if k=='azeltime':
                    azeltimegrapher(df, [k], [i], lower_list, upper_list,
                                    save_flag, station, source,risetime,
                                    print_flag, det_list, savedets_flag,
                                    file_in, rs_combine, all_dets)
                else:
                    grapher(df, [k] ,[i], lower_list, upper_list, save_flag,
                            station, source,risetime, print_flag, det_list,
                            savedets_flag, file_in, rs_combine, all_dets)
    elif xax_list==['azeltime']:
        azeltimegrapher(df, xax_list,yax_list, lower_list, upper_list,
                        save_flag, station, source, risetime, print_flag,
                        det_list, savedets_flag, legend_loc, file_in,
                        rs_combine, all_dets)
    else:
        grapher(df, xax_list ,yax_list, lower_list, upper_list, save_flag,
                station, source, risetime, print_flag, det_list, savedets_flag,
                file_in, rs_combine, all_dets)
    return 0





def printhelp():
    """The Help section of the program
    """

    print('\n    Usage: antpl.py ab:c:d:e:fghi:l:mps:t:u:x:y:z: \n')
    print('    Example usage: antpl.py -s taur -y sefd -d 15d0:15d1 -e 2'+
          '-p -a 2019y70d22h:2019y71d5h point.19.071.log ')
    print('    Last arg(s) always log file(s) (Will sequentially print if '+
          'multiple log files) \n')
    print('    Flags:')
    print('    -s:   (source)       source name to be plotted. Will '
          'take any substring of a full source name')
    print('    -d:   (detectors)    list of detectors, seperated by '+
          'colons, no spaces')
    print('    -x:   (x-axis)       x-axis data (Default azeltime)')
    print('    -y:   (y-axis)       y-axis data (Defailt SEFD)')
    print('    -t:   (top)          y-axis max value (Default autofit)')
    print('    -b:   (bottom)       y-axis min (Default autofit)')
    print('    -l:   (legend)       Which plot the legend should be on '+
          '(Only for azeltime graph). "t" for time, "a" for az, '+
          'e" for el (Default "e")')
    print('    -u:   (polarization) polarization of detectors desired')
    print('    -i:   (IF)           IF value of detectors desired')
    print('    -a    (aggregate)    combines rising and setting data '+
          'for each detector into a single line')
    print('    -m    (mean)         Average data point by point '+
          '(Can only be done with TWO detectors)')
    print('    -e:   (stats)        (good test value is 2) This removes '+
          'outliers using z-test with input as cuttoff for z-score')
    print('    -z:   (dates)        specify date range, split by colon'+
          'ex:2019y70d22h10m:2019y71d5h15m (Default to entire set)')
    print('    -p    (print)        show plots')
    print('    -f    (file)         saves to file with name '+
          '"station_source_risetime_yaxis_xaxis.pdf"')
    print('    -g                   Adds detectors to name of saved file')
    print('    -n    (NOT-combined) sequentially show fullscreen plots of '+
          'each pair of yaxis and xaxis variables')
    print('    -c    (control)      executes lines of stdin (C-d to end '+
          'input to stdin), holding over options from main input')
    print('    -h    (help)         print help')
    print('\n    X,Y options:')
    print('    time, source, az, el, de, i, p, center, comp, tsys, '+
          'sefd, tcalj, tcalr (case insensitive)')
    print('\n    Special options:')
    print('    X: azeltime     3 graphs on same screen in specific '
          'layout (for each y variable)')
    print('\n    Discovery Mode:')
    print('    Will enter mode if no -p and no -f, will filer log file by '+
          'given sources ex: antpl.py -s taurusa point.19.071.log')
    print('    Gives list of lines seperated by rising and setting cycle. '+
          'They have tags appropriate and format appropriate for '+
          'copy/pasting into control file or cmd line')
    print('\n    Common Errors:')
    print('    Unicode Erorr:   Try running the same command again.')
    print('                     This should only happen once per log \n\n')
    sys.exit()
    return 0

allins = sys.argv
prog = allins[0]

if len(allins) == 1:
    printhelp()

#regex to test if -c is attached to anything else
for i in allins:
    if re.search(r'(-[^ ]+c|-c[^ ]+)', i):
        print('\n-c must be seperated from all other flags.\n')
        exit()
try:
    argv = sys.argv[1:]
except:
    printhelp()
    sys.exit()
try:
    options, remainder = getopt.getopt(argv, 'ab:cd:e:fghi:l:mnps:t:u:x:y:z:')
except getopt.GetoptError as err:
    print('\nNot all of the flags you used are valid.\nLook at "'
          +prog+' -h" for help\n')
    sys.exit()

#Defaults:
#lower and upper bounds initially set to -1 as that will cause autofitting
inputlower_list = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
inputupper_list = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
inputsave_flag = False #If the figure should be saved
inputstat_flag=False #If outliers should be thrown out
inputdets_list=[''] #Which detectors should be graphed ('' gets all of them)
inputx_list= ['azeltime'] #Default graphing should be azeltime
inputy_list= ['sefd'] #Default y-axis should be sefd
inputdates=['0001y1d1h','9999y1d1h'] #Default dates include all time ever
inputprint_flag=False #Should the plot be shown on the screen
inputcontrol_flag=False #Should the file take in std in input
inputcontrol_text='' #The text from std in which is used if inputcontrol_flag
inputmulti_flag=False #If each individual plot should get its own screen
inputstat_val=1000 #The cutoff for outlier removal
inputrs_combine=False #If rising/setting should be combined
inputsource = [''] #Source to be graphed
inputpol_list = [''] #Which polarizations should be graphed
inputif_list = [''] #Which IF values hould be graphed
inputsavedets_flag=False #If the detector names should be saved in the filename
inputlegend_loc='t' #Which plot (only in azeltime) should the legend be in
inputavg_flag=False #Should all the detectors be averaged
try:
    for opts, args in options:
        if opts == '-d':
            inputdets_list = [item.lower() for item in args.split(':')]
        elif opts == '-z':
            inputdates = args.split(':')
            inputdates.append('9999y1d1h')
        elif opts == '-x':
            inputx_list = [item.lower() for item in args.split(':')]
        elif opts == '-a':
            inputrs_combine=True
        elif opts == '-y':
            inputy_list = [item.lower() for item in args.split(':')]
        elif opts == '-b':
            inputlower_list1 = args.split(':')
            inputlower_list = inputlower_list1+inputlower_list
        elif opts == '-t':
            inputupper_list1 = args.split(':')
            inputupper_list = inputtop1+inputtop
        elif opts == '-f':
            inputsave_flag = True
        elif opts == '-n':
            inputmulti_flag = True
        elif opts == '-m':
            inputavg_flag = True
        elif opts == '-e':
            inputstat_flag = True
            inputstat_val = args
        elif opts == '-h':
            printhelp()
        elif opts == '-p':
            inputprint_flag = True
        elif opts == '-c':
            inputcontrol_flag = True
            for line in sys.stdin:
                inputcontrol_text = inputcontrol_text+line+'\n'
        elif opts == '-i':
            inputif_list = args.split(':')
        elif opts == '-u':
            inputpol_list = args.split(':')
        elif opts == '-s':
            inputsource= args.split(':')
        elif opts == '-g':
            inputsavedets_flag = True
        elif opts == '-l':
            inputlegend_loc = args
except Exception as err:
    print('\nThere was an error parsing your arguments. Likely a flag was '+
          'typed incorrectly, or arguments were given when they aren\'t '+
          'needed. \nLook at "'+prog+' -h" for help\n')
    sys.exit()


inputlog = remainder
if inputy_list==['all']:
    inputy_list=['sefd','tsys', 'tcalj']

#Tests to make sure inputs are valid
if inputlegend_loc not in ['a','e','t']:
    print('\nError: -l must have "a","e", or "t" as the argument '+
          '(default is "e"). \nLook at "'+prog+' -h" for help\n')
    sys.exit()

for i in inputx_list:
    if i not in ['time','source','az','el','de','i','p','center','comp',
                 'tsys','sefd','tcalj','tcalr', 'azeltime']:
        print('\nThat is not a valid choice for x-axis variable. \nLook at "'+
              prog+' -h" for help\n')
        sys.exit()

for i in inputy_list:
    if i not in ['time','source','az','el','de','i','p','center','comp',
                 'tsys','sefd','tcalj','tcalr']:
        print('\nThat is not a valid choice for y-axis variable. \nLook at "'+
              prog+' -h" for help\n')
        sys.exit()

for i in range(0, len(inputif_list)):
    try:
        inputif_list[i] = float(inputif_list[i])
    except:
        if not inputif_list[i] == '':
            print('\nThat is not a valid choice for -i variable, it should be'+
                  ' a number. \nLook at "'+prog+' -h" for help\n')
            sys.exit()

try:
    inputstat_val = float(inputstat_val)
except:
    print('\nThat is not a valid choice for -e variable, it should be a '+
          'number. \nLook at "'+prog+' -h" for help\n')
    sys.exit()

for i in range(0, len(inputupper_list)):
    try:
        inputupper_list[i] = float(inputupper_list[i])
    except:
        print('\nThat is not a valid choice for -t variable, each value '+
              'should be a number. \nLook at "'+prog+' -h" for help\n')
        sys.exit()

for i in range(0, len(inputlower_list)):
    try:
        inputlower_list[i] = float(inputlower_list[i])
    except:
        print('\nThat is not a valid choice for -b variable, each value '+
              'should be a number. \nLook at "'+prog+' -h" for help\n')
        sys.exit()




#Program to prompt for std input and then take those as parameters and
#run a cycle of the program for each line of std. input
if inputcontrol_flag:
    #First remove -c and log file from the line for later execution
    for i in range(0, len(allins)):
        if allins[i] == '-c':
            removelist = [i]
        if 'point' in allins[i]:
            removelist.append(i)
    removelist.sort(reverse = True)
    for i in removelist:
        del allins[i]
    allins = ' '.join(map(str, allins[1:]))
    #Put all the flags and log files together, then execute the stdin by line
    try:
        linesplit= filter(None, inputcontrol_text.splitlines())
        for line in linesplit:
            word_list = line.split()
            logfile = word_list[-1]
            del word_list[-1]
            controlprog_flags =  ' '.join(map(str, word_list))
            if '-p' not in controlprog_flags and '-f' not in controlprog_flags\
               and '-p' not in allins and '-f' not in allins:
                print('\nSorry. You can\'t enter discovery mode from control '+
                      'mode.\nUse -p or -f to display or save the graph')
                sys.exit()
            os.system('python3 '+prog+' '+controlprog_flags+
                      ' '+allins+' '+logfile)
        sys.exit()
    except Exception as err:
            print('\nThere was an error in your control file format. '+
                  '\n Look at "'+prog+' -h" for help\n')
            sys.exit()

#What is actually run, either enter discover mode or total (which plots stuff)
try:
    for i in inputlog:
        if not os.path.isfile(i):
            print('\nSorry. '+str(i)+' doesn\'t seem to exist in directory.'+
                '\nMake sure the file exists and is correctly named.\n')
            sys.exit()
        if not inputsave_flag and not inputprint_flag:
            discover(i, inputsource, inputif_list,
                     inputpol_list, inputdets_list)
        else:
            for s in inputsource:
                if s == '':
                    print('Possible that a source is not defined (-s). '+
                        'If not that, then make sure all arguments and flags '+
                        'are valid. \n Look at "'+prog+' -h" for help')
                    sys.exit()
                if ' -' in s:
                    print('At least one of the flags isn\'t valid.\nLook at "'+
                        prog+' -h" for help')
                    sys.exit()
                total(i, s, inputx_list, inputy_list, inputdets_list,
                    inputpol_list, inputif_list, inputdates, inputstat_flag,
                    inputstat_val, inputrs_combine, inputavg_flag,
                    inputlower_list, inputupper_list, inputmulti_flag,
                    inputlegend_loc, inputsavedets_flag, inputsave_flag,
                    inputprint_flag)
except Exception as err:
    print('\nArguments were not formatted correctly. \nLook at "'+
          prog+' -h" for help\n')
