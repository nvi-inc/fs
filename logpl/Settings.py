#LogPlotter/Settings.py
#########################################
#Settings handler for LogPlotter
#Saves various settings in a file using pickle
#Retreives saved information, which is displayed
#by MainGUI.py
#Also, possibility to write default config file
#and later on, possibility to read old logpl
#config files
#will make separate config for usbxy since they are so different. 
#style: [description]=[command, splitsign, parameter, string, group name]
#############################################

import sys

class Settings:
    def __init__(self):
        self.settings_dict = {}
        self.settings_dict['data']=[]

    def writeSF(self, filename):
        _file = open(filename, 'w')
        header = '* ' + filename + """ - Control file for logpl2
* This file may be edited in any text editor or in logpl's internal editor. 
*
* 1. Command, the pattern logpl will grep the log file for. 
* 2. Parameter, the number of separated data field for the command,
*               a negative value means to take the value just after the
*               field with "String"
* 3. Description, the menu label logpl will use for the command. The description 
*                 must be unique for every data. For pair commands, the first 
*                 description must begin with a $-sign, and the second must end 
*                 with a $-sign. 
* 4. String, a level-2 grep. This parameter is optional and may be left out,
*            for negative "Parameter" values, it is the string before the
*            data field
* 5. Dividing Character, the character that separates the parameters. 
*                        If left out, it defaults to a comma. 
* 6. Group Name, Specify a group name to put the data in a cascaded menu
*                in the plot menu. If several data share a group name, 
*                they appear in the same cascade menu. 
*
* This file is space-separated, and fields may only contain spaces
* if they are inside double quotes. To have a double quote in a field, type 4 double quotes.
* Note that single quotes are parsed as normal ASCII.  
* Only field 1,2 and 3 are required by logpl. An empty field may simply be left out
* but if there are fields to the right of it, specify it empty by using two double quotes (""). 
* Also note, the interpretation of this control file is CASE SENSITIVE!
*
* 1:Command\t2:Parameter\t3:Description\t\t4:String\t5:Dividing Character\t6:Group Name
* -----------------------------------------------------------------------------------------------------
* \n"""
        _file.write(header)
        linelist = []
        for description in self.settings_dict.keys():
            _list = self.settings_dict.get(description)
            #check for blank signs. If so, add quotes.
            for i in range(len(_list)):
                _list[i] = self.fixLine(_list[i])
            description = self.fixLine(description)
            command = _list[0]
            split_sign = _list[1]
            parameter = _list[2]
            string = _list[3]
            group_name = _list[4]
            row = _list[5]
            space1 = max(20 - len(command),1)*' '
            space2 = max(15-len(parameter),1)*' '
            space3 = max(22 - len(description), 1)*' '
            space4 = max(24 - len(string), 1)*' '
            space5 = max(17- len(split_sign),1)*' '
            linelist.append([row, command + space1 + parameter + space2 + description + space3 + string + space4 + split_sign + space5 + group_name + '\n'])
        linelist.sort()
        for i in range(len(linelist)):
            _file.write(linelist[i][1])
        _file.close()
    
    def fixLine(self, entry):
        if type(entry)==int:
            return entry 
        if entry.count('"')>0:
            entry = entry.replace('"', '""""')
        if entry == '' or not entry:
            entry = '""'
        if entry.count(' ')>0:
            entry = '"' + entry + '"'
        return entry
            
    def setSettings(self, key, value):
        #check value is list:
        if type(value)==type([]):
            self.settings_dict[key]=value
        else:
            raise TypeError
        
        
    def clearSettings(self):
        self.settings_dict.clear()
    
    
    def readSF(self, _filename='logpl.ctl'):
        try:
            control_file = open(_filename, 'r')
            self.settings_dict.clear()
            row = -1
            for line in control_file.readlines():
                param_list = []
                #if not comment...
                if not (line[0]=='*' or line[0]=='#'):
                    row +=1
                    line_list = list(line.strip().expandtabs())
                    #cycle through line_list, look for quote marks:
                    quote = 0
                    quote_mark = 0
                    i = 0
                    while i<(len(line_list)):
                        try:
                            char1 = line_list[i]
                            char2 = line_list[i+1]
                            char3 = line_list[i+2]
                            char4 = line_list[i+3]
                        except IndexError:
                            char1 = char2 = char3 = char4 = ''
                        try:
                            if char1 == char2 == char3 == char4 == '"':
                                if quote == 1:
                                    i+=4
                                else:
                                    quote_mark = 1
                            else:
                                quote_mark = 0
                        except IndexError:
                            pass
                        try:
                            if line_list[i] == '"' and quote == 0 and quote_mark == 0:
                                quote = 1
                                q_pos = i
                            elif line_list[i] == '"' and quote == 1: #end quote,
                                #build string:
                                s = ''
                                for j in range(q_pos,i+1):
                                    s += line_list[j]
                                s = s.replace('""""', '"')
                                param_list.append(s.strip('"'))
                                quote = 0
                                i += 2
                            elif quote == 0 and line_list[i]!= " ":
                                s = line_list[i]
                                a = ""
                                while a != " ":
                                    i += 1
                                    s += a
                                    s = s.replace('""""', '"')
                                    if i>(len(line_list)-1):
                                        break
                                    a = line_list[i]
                                    
                                param_list.append(s)
                        except IndexError:
                            pass

                        i += 1
                    #settings dict is of format: [description] = [command, splitsign, parameter, string, group name]
                    #param_list is of format: [command, parameter, description, string, splitsign(new), group name(new)]
                    if param_list:
                        command = param_list[0]
                        if command != '"':
                            #primary information (must exist), error raised if nonexistant:
                            description = param_list[2]
                            if description.count('!')>0:
                                print 'Illegal character ! used in description. \n Exiting...'
                                sys.exit()
                            parameter = param_list[1]
                            try:
                                int(parameter)
                            except:
                                print 'Parameter in control file is not integer! \n Exiting...'
                                sys.exit()
                            try:
                                group_name = param_list[5]
                            except IndexError:
                                group_name = ''
                            try:
                                split_sign = param_list[4]
                                if split_sign == '':
                                    split_sign = ','
                            except IndexError:
                                split_sign = ','
                            try:
                                string = param_list[3]
                            except IndexError:
                                string = ''
                            self.settings_dict[description] = [command, split_sign, parameter, string, group_name, row]                       
            control_file.close()
        except IOError, e:
            raise IOError #just send back...
        else:
            return self.settings_dict

if __name__=='__main__':
    sf = Settings()
    #sf.setSettings('Pcal Amp', ['abc', ' ', 2, '', ''])
    filename = 'testing.ctl'
    sf.readSF('logpl.ctl')
    sf.writeSF(filename)
    #print sf.settings_dict
