#based on logpl's canvasconstructor with some smaller adjustments. 
import Tkinter as tk #name incompatibility with Image and ImageDraw.... 
import os

class PrintCanvas(tk.Toplevel):
    def __init__(self, **settings):
        tk.Toplevel.__init__(self)
        self.main_height = int(settings.get('height'))
        self.main_width = int(settings.get('width'))
        self.main_canvas = tk.Canvas(self, width = self.main_width, height = self.main_height)
        self.plots = settings.get('plots')
        self.main_canvas.pack()
        self.built_height = 0
            
            

    def addCanvas(self, canvas, xadd=0):
        step = 0
        yadd = self.built_height
        #if i==0: #label
        #    xadd=130
        #else:
        #    xadd = 0
        self.built_height += int(canvas.winfo_height())
        #cycle through items
        for item in canvas.find_all():
            coords = canvas.coords(item)
            
            for i in range(len(coords)):
                if i%2 == 0: #if x-coord
                    coords[i] += xadd
                else: #if y-coord
                    coords[i] += yadd

            #get color if not text
            if not (canvas.type(item) == 'text' or canvas.type(item) == 'line'):
                outline_color = canvas.itemcget(item, 'outline')
            fill_color = canvas.itemcget(item, 'fill')
            width = canvas.itemcget(item, 'width')
            
            if canvas.type(item) == 'oval':
                self.main_canvas.create_oval(coords, outline = outline_color, fill= fill_color)
            elif canvas.type(item) == 'line':
                dash = canvas.itemcget(item, 'dash')
                self.main_canvas.create_line(coords, fill = fill_color, dash = dash, width = width)
            elif canvas.type(item) == 'rectangle':
                if 'border' in canvas.gettags(item):
                    outline_color = 'black'
                self.main_canvas.create_rectangle(coords, outline = outline_color, fill= fill_color)
            elif canvas.type(item) == 'polygon':
                self.main_canvas.create_polygon(coords, outline = outline_color, fill= fill_color)
            elif canvas.type(item) == 'text':
                text = canvas.itemcget(item, 'text')
                anchor = canvas.itemcget(item, 'anchor')
                length = canvas.bbox(item)[2]-canvas.bbox(item)[0]
                if anchor.lower().count('e') and (coords[0]-length)<0:
                    coords[0] = 1
                    anchor = 'w'
                self.main_canvas.create_text(coords, text = text, anchor = anchor, fill = fill_color)
        
               
 
    def printCanvas(self, _filename = None, file_format = None, printcmd = None, printer = None):
        #output = self.main_canvas.postscript(colormode = 'color', pageheight = '11i' , pagewidth = '8.5i', pageanchor = N, width = self.main_width+margin, height = self.main_height, pagex = self.main_width, pagey = self.main_height, x=100, y=0)
        if _filename and file_format != 'EPS':
            try:
                self.makeImage(_filename, file_format)
            except ImportError:
                #PIL not installed!
                return 1
        else:
            ymargin = 50
            xmargin = ymargin*8.5/11.0
            output = self.main_canvas.postscript(colormode = 'color', pageheight = '11i' , pagewidth = '8.5i', width = int(self.main_width)+xmargin, height = int(self.main_height)+ymargin, y=-ymargin/2) 
            if _filename:
                _file = open(_filename, 'w')
                _file.write(output)
                _file.close
            if printcmd:
                if printer:
                    printerspool = os.popen('lpr -P %s' % (printer), 'wb')
                else:
                    printerspool = os.popen('lpr', 'wb')
                printerspool.write(output)
                printerspool.close()
        return 0
    
    def makeImage(self, filename, format):
        """make image (pdf/jpeg/bmp/gif/png/tiff) of self.main_canvas, using Image & ImageDraw
        """
        import Image, ImageDraw, ImageFont #will raise ImportError if PIL not installed. 
        ymargin = 50
        xmargin = int(ymargin*8.5/11.0)
        img = Image.new('RGB', (self.main_width+ymargin, self.main_height+xmargin), 'white')
        output_image = ImageDraw.Draw(img)
        font = ImageFont.load_default()
        #iterate through canvas objects....
        for item in self.main_canvas.find(tk.ALL):
            type = self.main_canvas.type(item)
            coords = list(self.main_canvas.coords(item))
            #add xmargin to xs, ymargin to ys
            for i in range(len(coords)):
                if i%2 == 0: #x-coordinate:
                    coords[i]+= ymargin/2
                else: #y-coordinate
                    coords[i]+= xmargin/2
                    
            fill_color = self.main_canvas.itemcget(item, 'fill')
            if type!='text' or type!='line': #text or line has no fill option...
                outline_color = self.main_canvas.itemcget(item, 'fill')
            if type == 'text':
                text = self.main_canvas.itemcget(item, 'text')
                new_coords = self._anchorToCoordinate(item, coords)
                output_image.text(new_coords, text, fill_color, font = font)
            elif type == 'oval':
                output_image.ellipse(coords, fill_color, outline_color)
            elif type == 'rectangle':
                if not fill_color:
                    fill_color = None #None = transparent
                if not outline_color:
                    outline_color = 'black' #if not specified, default in Tk = black
                output_image.rectangle(coords, fill_color, outline_color)
            elif type == 'polygon':
                output_image.polygon(coords, fill_color, outline_color)
            elif type == 'line':
                output_image.line(coords, fill_color)
        img.save(filename, format)
        
    def _anchorToCoordinate(self, item, old_coords):
        """This changes the coordinate of a Tk text object with an anchor to
        fit with an always left aligned anchor coordinate for PIL
        """
        if self.main_canvas.type(item) != 'text':
            raise ValueError, 'Object must be text'
        coords = old_coords
        anchor = self.main_canvas.itemcget(item, 'anchor')
        bbox = self.main_canvas.bbox(item)
        length = bbox[2]-bbox[0]+5
        height = bbox[3]-bbox[1]
        #default anchor for PIL seems to be SW
        if anchor.lower().count('e'): #could be e,ne,se....
            newX = max(coords[0]-length,0)
            coords[0] = newX
        if not anchor.lower().count('s'): #if not south aligned, move up
            newY = max(coords[1]-height/2,0)
            coords[1] = newY
        return coords