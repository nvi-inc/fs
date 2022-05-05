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
class Coordinate:

    def __init__(self, plotDim, minXY=[0,0], maxXY = [0,0], offset=10, xmargin=0, ymargin=0):
        self.xoffset = int(offset)
        self.yoffset = int(offset)
        self.pixelsX = float(plotDim[0])
        self.pixelsY = float(plotDim[1])
        self.maxX = float(maxXY[0])
        self.maxY = float(maxXY[1])
        self.minX = float(minXY[0])
        self.minY = float(minXY[1])
        
        self.x_margin = int(xmargin)
        self.y_margin = int(ymargin)

    def getCanvasXY(self, cartesianXY, **kw):
        if kw.has_key('force_scale'):
            force = kw.get('force_scale')
        else:
            force = 0
        pixels_in_plot_x = self.pixelsX - 2*self.xoffset-2*self.x_margin
        pixels_in_plot_y = self.pixelsY - 2*self.yoffset-2*self.y_margin
        cartesianXY[0] = float(cartesianXY[0])
        cartesianXY[1] = float(cartesianXY[1])
        canvasX=0
        canvasY=0
        deltaY = self.maxY-self.minY
        deltaX = self.maxX-self.minX
        
        if deltaY == 0:
            #delt1aY = cartesianXY[1]/100.0
            deltaY = 0.001
        if deltaX == 0:
            #deltaX = cartesianXY[0]/100.0
            deltaX = 0.001
            
        canvasX = (float((cartesianXY[0]-self.minX)/deltaX*pixels_in_plot_x) + self.x_margin + self.xoffset)
        canvasY = (float(self.pixelsY-(cartesianXY[1]-self.minY)/deltaY*pixels_in_plot_y) - self.yoffset - self.y_margin)
        
        
        #if x or y outside of plot, put it on the border:
        canvasX = max(self.x_margin, canvasX)
        canvasX = min(self.x_margin+pixels_in_plot_x+2*self.xoffset, canvasX)
        canvasY = max(self.y_margin, canvasY)
        canvasY = min(self.y_margin+pixels_in_plot_y+2*self.yoffset, canvasY)
        
        return (canvasX, canvasY)
    
    def getCartesianX(self, canvX):
        pixels_in_plot_x = self.pixelsX - 2*self.xoffset-2*self.x_margin
        deltaX = self.maxX-self.minX
        cartX = float(deltaX)/pixels_in_plot_x*(canvX-self.x_margin-self.xoffset)+self.minX
        return cartX
    
    def getCartesianY(self, canvY):
        pixels_in_plot_y = self.pixelsY - 2*self.yoffset-2*self.y_margin
        deltaY = self.maxY-self.minY
        cartY = (float(deltaY)/pixels_in_plot_y*((self.pixelsY-canvY)-self.y_margin-self.yoffset)+self.minY)
        return cartY