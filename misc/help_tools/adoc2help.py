import sys
import fileinput
import re

filepath='snapcmd.adoc'

if(len(sys.argv)) > 1:
    filepath=sys.argv[1]

fp=open(filepath)
line=fp.readline()
while line:
    line = line.rstrip()
    if line != "== SNAP Command Descriptions":
       line=fp.readline()
       continue
    break

line=fp.readline()
while line:
    line = line.rstrip()
    m=re.search(r'^=== *(\S+) *- *(.*)$',line)
    if not m:
        line=fp.readline()
        continue
    name=m.group(1)
    descrip=m.group(2)
    m=re.search('^(.+) *\(([^)]+)\)',descrip)
    equip=''
    parameters=0
    if m:
        descrip=m.group(1).rstrip()
        equip=m.group(2)
    f=open(name + '.adoc','w+')
    f.write('= ' + name + '(___)'  + '\n')
    f.write('FS Contributors, Copyright NVI, Inc., 2021\n')
    f.write('version\n')
#    f.write(':doctype: manpage' + '\n')
    f.write(':manmanual: SNAP COMMANDS\n')
    f.write(':mansource: FS Documentation\n')
    f.write(':man-linkstyle: pass:[blue R < >]' + '\n')
    f.write('\n')
    f.write('== Name\n')
    f.write('\n')
    if equip:
        f.write(name + ' - ' + descrip + ' ' + equip + '\n')
    else:
        f.write(name + ' - ' + descrip + '\n')
#
    line=fp.readline()
    while line:
        line = line.rstrip()
        m=re.search(r'^=== *(\S+) *- *(.*)$',line)
        if not m:
            if re.search(r'^==== ',line):
                if re.search(r'Comments',line):
                    parameters = 0
                elif re.search(r'Settable Parameters',line):
                    parameters = 1
                f.write(line.replace("==","",1) + '\n')
            elif re.search(r'^\.\.\.\.',line):
                pass
            elif re.search(r'^\|===',line) and parameters:
#               remove tables in parameters
                pass

            else:
                if parameters:
#                   remove tables in parameters
                    line=re.sub(r'^a\|',r'*',line)
                    line=re.sub(r'\|',r'--',line)

#               remove curly quotes
                line=re.sub(r'(["\'])`',r'\1',line)
                line=re.sub(r'`(["\'])',r'\1',line)

#               fix unconstrained italics at end of monospace token
#               like ``lo__X__``
#               there is an extra back tick since the next block will remove it
                line=re.sub(r'__(.*)__``',r'```_\1_',line)


#               remove monospace around bold/underline
                line=re.sub(r'`([_*])',r'\1',line)
                line=re.sub(r'([_*])`',r'\1',line)
#               change monospace to bold
                f.write(line.replace("`","*") + '\n')
#                f.write(line + '\n')
            line=fp.readline()
            continue
        else:
            break
