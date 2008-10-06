#Python program that receives cartesian XY coordinates and returns graphic point coordinates. Y-axis is #flipped. 
#if cartesian coord is outside of plot, return None

class Coordinate:

    #constructor with arguments: plotDim = list of canvas dimensions
    #                 deltaXY = list of max(x)-min(x) and max(y)-min(y)
    #                 minXY = lits of min(x) and min(y)
    
    def __init__(self, plotDim, deltaXY, minXY, offset, info_box):
        #note that 20 is subtracted, and later on 10 is added in order to get
        #10 pixels of empty space at every border
        self.pixelsX = float(plotDim[0])-20.0
        self.pixelsY = float(plotDim[1])-20.0
        self.deltaX = float(deltaXY[0])
        self.deltaY = float(deltaXY[1])
        self.minX = float(minXY[0])
        self.minY = float(minXY[1])
        self.offset = int(offset)
        self.info_box = int(info_box)



    def getCanvasXY(self, cartesianXY):
        cartesianXY[0] = float(cartesianXY[0])
        cartesianXY[1] = float(cartesianXY[1])
        canvasX=0
        canvasY=0
        try:
            canvasX = int(float((cartesianXY[0]-self.minX)/self.deltaX*self.pixelsX) + self.info_box + self.offset)
        except ZeroDivisionError:
            self.deltaX = cartesianXY[0]/100.0
            canvasX = int(float((cartesianXY[0]-self.minX)/self.deltaX*self.pixelsX) + self.info_box + self.offset)
        try:
            canvasY = int(float(self.pixelsY-(cartesianXY[1]-self.minY)/self.deltaY*self.pixelsY)+self.offset)
        except ZeroDivisionError:
            self.deltaY = cartesianXY[1]/100.0
            canvasY = int(float(self.pixelsY-(cartesianXY[1]-self.minY)/self.deltaY*self.pixelsY)+self.offset)
       
        if (canvasX<(self.info_box+self.offset) or canvasX>(self.info_box+self.pixelsX+self.offset)):# or canvasY<0 or canvasY>self.pixelsY):
            return None
        else:
            return (canvasX, canvasY)
    
    def getCanvasY(self, cartY):
        cartY = float(cartY)
        cavansY=0
        try:
            canvasY = int(float(self.pixelsY-(cartY-self.minY)/self.deltaY*self.pixelsY)+self.offset)
        except ZeroDivisionError:
            self.deltaY = cartY/100.0
            canvasY = int(float(self.pixelsY-(cartY-self.minY)/self.deltaY*self.pixelsY)+self.offset)
        return canvasY

    def getCartesianXY(self, CanvasXY):
                CanvasXY[0] = CanvasXY[0]-self.info_box
                CanvasXY[0]-=self.offset
                CanvasXY[1]-=self.offset
                #receives CanvasXY, returns CartesiaXY
                cartesianY=self.deltaY*(1-CanvasXY[1]/self.pixelsY)+self.minY
                cartesianX=(CanvasXY[0])*self.deltaX/self.pixelsX+self.minX
                return [cartesianX, cartesianY]
                

        
