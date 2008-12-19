#GndatReader reads the gndat output in threaded mode
from NumericTools import NumericTools
import threading

class GndatReader(threading.Thread):
    def __init__(self, filename):
        self.filename = filename
        self.progress = 0
        self.database = {}
        threading.Thread.__init__(self)
        
    def run(self):
        filename = self.filename
        file = open(filename, 'r')
        BAD_VALUE = -6000000
        self.number_of_bad_values = 0
        #sections:
        _antenna = 0
        _dpfu = 0
        _gain = 0 
        _label = 0
        _data = 0
        _readlo = 0
        numTools = NumericTools()
        
        self.database.clear()
        labels = []
        self.no_plot_list = []
        
        data = file.readlines()
        tot_length = len(data)
        percentage = step = max(tot_length/100,1)
        self.rxg_list = {}
        
        for i,line in enumerate(data):
            if i == percentage:
                percentage += step
                self.progress = int(float(i+1)/tot_length*100+1)

            if line[0] != '*':
                if line[:-1] == '$ANTENNA':
                    _antenna = 1
                    _dpfu = 0
                    _gain = 0 
                    _label = 0
                    _data = 0
                    _readlo = 0
                elif line[:-1] == '$DPFU':
                    _antenna = 0
                    _dpfu = 1
                    _gain = 0 
                    _label = 0
                    _data = 0
                    _readlo = 0
                elif line[:-1] == '$GAIN':
                    _antenna = 0
                    _dpfu = 0
                    _gain = 1 
                    _label = 0
                    _data = 0
                    _readlo = 0
                elif line[:-1] == '$LABELS':
                    _antenna = 0
                    _dpfu = 0
                    _gain = 0 
                    _label = 1
                    _data = 0
                    _readlo = 0
                elif line[:-1] == '$DATA':
                    _antenna = 0
                    _dpfu = 0
                    _gain = 0 
                    _label = 0
                    _data = 1
                    _readlo = 0
                elif line[:-1] == '$LO':
                    _readlo = 1
                elif line[0] == '$':
                    _antenna = 0
                    _dpfu = 0
                    _gain = 0 
                    _label = 0
                    _data = 0
                    _readlo = 0  
                else: #header data
                    if _label == 1: 
                        labels.append(line[:-1])
                    elif _readlo == 1:
                        _list = line.split(' ')
                        filename = _list[0]
                        mode = _list[1]
                        LO_lower = float(_list[2])
                        try:
                            LO_upper = float(_list[3])
                        except IndexError: #not always a second entry when LO is fixed
                            LO_upper = LO_lower
                        self.rxg_list[filename] = [mode, LO_lower, LO_upper]
                    elif _data == 1:
                        data = line.strip().split(' ')
                        data_copy = data[:]
                        for k in range(len(data_copy)):
                            try:
                                data_copy[k] = float(data_copy[k])
                            except ValueError:
                                pass
                        if BAD_VALUE in data_copy:
                            self.number_of_bad_values+=1
                            continue
                        for i, d in enumerate(data):
                            key = labels[i]
                            if key == 'Time':
                                key = 'Timestamp'
                                try:
                                    self.database[key].append(d)
                                except KeyError:
                                    self.database[key] = [d]
                                d = numTools.date2num(d)
                                if not key in self.no_plot_list:
                                    self.no_plot_list.append(key)
                                key = 'Time'
                                try:
                                    self.database[key].append(d)
                                except KeyError:
                                    self.database[key] = [d]
                                continue
                            try:
                                d = float(d)
                            except ValueError: #the data is not to be plotted, i.e frequency, polarization etc.
                                if not key in self.no_plot_list:
                                    self.no_plot_list.append(key)
                            try:
                                self.database[key].append(d)
                            except KeyError:
                                self.database[key] = [d]
            
        file.close()
    
    def getData(self):
        return [self.database, self.no_plot_list, self.rxg_list, self.number_of_bad_values]