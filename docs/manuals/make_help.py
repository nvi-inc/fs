
import fileinput
import re

filepath='snapcmd.adoc'

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
    m=re.match(r'^=== *(\S+) *- *(.*)$',line)
    if not m:
        line=fp.readline()
        continue
    name=m.group(1)
    descrip=m.group(2)
    m=re.match('^(.+) *\(([^)]+)\)',descrip)
    equip=''
    if m:
        descrip=m.group(1).rstrip()
        equip=m.group(2)
    f=open(name + '.adoc','w+')
    f.write('= ' + name + '(___)'  + '\n')
    f.write('FS Development Team, Copyright NVI, Inc. 2021\n')
    f.write('version\n')
    f.write(':doctype: manpage' + '\n')
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
        m=re.match(r'^=== *(\S+) *- *(.*)$',line)
        if not m:
            if re.match(r'^====',line):
                f.write(line.replace("==","",1) + '\n')
            elif re.match(r'^\.\.\.\.',line):
                pass
            elif re.match(r'^\[subs="\+quotes"\]',line):
                pass
            else:
                line=re.sub(r'`([_*])',r'\1',line)
                line=re.sub(r'([_*])`',r'\1',line)
                f.write(line.replace("`","*") + '\n')
#                f.write(line + '\n')
            line=fp.readline()
            continue
        else:
            break
