*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine iadt(it,idt,ires)!c#870407:13:00    hp add time#

      dimension it(1),itm(5)
      data itm/100,60,60,24,366/
C
C   GET INITIAL INCREMENT
C
      iix=idt
C
C   INITIALIZE ILP
C   GET # DAYS/YEAR PLUS 1
C
      itm(5)=366
c not Y2.1K compliant
      if (mod(it(6),4).eq.0) itm(5)=367
C
C   SET UP LOOP
C
      do 20000 i=ires,5
C
C   INCREMENT THIS VALUE
C 
        it(i)=it(i)+iix 
C 
C   HAS THIS UNIT OVERFLOWED
C 
        if (it(i).lt.itm(i)) goto 60000
        if (i.ne.5) then
C 
C   GET THE CARRY TO HIGHER UNIT
C 
          iix=it(i)/itm(i)
C 
C   GET REMAINDER FOR THIS UNIT 
C 
          it(i)=mod(it(i),itm(i)) 
        else
          it(5)=1+mod(it(5),itm(5)) 
        endif
20000   continue
C 
C   INCREMENT YEAR (ASSUME NO BIGGER CHANGE)
C 
      it(6)=it(6)+1 
C 
60000 continue
C 
      return
      end 
