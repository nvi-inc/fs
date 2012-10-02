#from numpy import * 
#from numpy.random import *


class NumericTools:
    """NumericTools contains all numeric tools used by gnplot. 
    It uses NumPy for a major part of the computations. 
    """
    def timeStamp(self, timestr):
        new_time = timestr.replace('.','').replace(':','')
        #remove first two year digits and microseconds
        new_time = new_time[2:-2]
        return long(new_time)
    
    def revTimeStamp(self, timestamp):
        timestamp = str(int(timestamp))
        timestamp = timestamp.rjust(11, '0')
        #timeformat 07.054.05:03:21
        new_time = '%s.%s.%s:%s:%s' % (timestamp[:2], timestamp[2:5], timestamp[5:7], timestamp[7:9], timestamp[9:])
        return new_time
