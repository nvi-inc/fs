#LogPlotter/PlotManager.py
#Keeps track of plots used by MainGUI

class PlotManager:
    active_plots = 0
    
    def __init__(self):
        self._yyplot = False
        self.axis = False

    def addPlot(self):
        PlotManager.active_plots += 1
        #return the number of plots:
        return PlotManager.active_plots

    def removePlot(self):
        PlotManager.active_plots -= 1
        #return the number of plots:
        return PlotManager.active_plots

    def setYYplot(self,TF):
        self._yyplot = TF

    def getYYplot(self):
        return self._yyplot

    def setAxisCreated(self, value):
        self.axis = value

    def getAxisCreated(self):
        return self.axis
