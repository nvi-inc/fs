* logpl.ctl - Control file for logpl2
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
* 1:Command	2:Parameter	3:Description		4:String	5:Dividing Character	6:Group Name
* -----------------------------------------------------------------------------------------------------
* 
rx/                 9              rx-9-20k              (20K)                   ,                Rx
wx/                 1              Temperature           ""                      ,                Weather
cable/              1              Cable-length          ""                      ,                ""
tsys/               -1             tsys-i1               i1                      ,                Tsys
tsys/               -1             tsys-i2               i2                      ,                Tsys
rx/                 9              rx-9-lo               (LO)                    ,                Rx
wx/                 2              Pressure              ""                      ,                Weather
rx/                 9              rx-9-front            (FRONT)                 ,                Rx
rx/                 9              rx-9-pres             (PRES)                  ,                Rx
wx/                 3              Humidity              ""                      ,                Weather
pcalports=          1              "$Pcal Amp 1"         1                       ,                ""
decode4/            5              "Pcal Amp 1$"         "pcal usbx"             " "              "Pcal Amp"
pcalports=          1              "$Pcal Phase 1"       1                       ,                ""
decode4/            6              "Pcal Phase 1$"       "pcal usbx"             " "              "Pcal Phase"
pcalports=          1              "$Pcal Phase 4"       4                       ,                ""
decode4/            6              "Pcal Phase 4$"       "pcal usbx"             " "              "Pcal Phase"
pcalports=          1              "$Pcal Amp 4"         4                       ,                ""
decode4/            5              "Pcal Amp 4$"         "pcal usbx"             " "              "Pcal Amp"
pcalports=          2              "$Pcal Amp 5"         5                       ,                "Pcal Amp"
decode4/            5              "Pcal Amp 5$"         "pcal usby"             ""               "Pcal Amp"
