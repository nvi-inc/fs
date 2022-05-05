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
      program labck
C 
      integer*2 labt(4),lchk(2),labta(4),ihash,icode
      character*1 cjchar,ch
      logical disk
C 
      lu = 6
      lui = 5
C 
200   write(lu,9901)
9901  format(1x,"enter tape number (:: to quit) ")
      read(lui,9902) labt
9902  format(4a2) 
      if (ichcm_ch(labt,1,'::').eq.0) goto 999 
      call upper(labt,1,4)
      write(lu,9905)
9905  format(1x,"enter tape number again to double check (:: to quit) ")
      read(lui,9902) labta 
      if (ichcm_ch(labta,1,'::').eq.0) goto 999 
      call upper(labta,1,4)
C 
C     Generate check label.  Change any "O" to "0" in tape number first.
C     Check for exactly 8 characters in tape number.
C 
      disk=iscn_ch(labt,1,8,'-').ne.0.or.
     &     iscn_ch(labt,1,8,'+').ne.0 
      do i=1,8
         ch=cjchar(labt,i)
         if(ch.eq.' ') then
            write(lu,9904)
9904    format(1x,"tape label must be exactly 8 characters, no blanks all
     .owed.  try again.") 
            goto 200
         endif
         if (index('Oo',ch).ne.0.and..not.disk) then
            call char2hol('0',labt,i,i)
         endif
         if(cjchar(labta,i).ne.ch) then
            write(lu,9907)
 9907       format(1x,"tape numbers disagree. try again.") 
            goto 200
         endif
      enddo

      call upper(labt,1,8)
C 
      icode = ihash(labt,1,8) 
      lchk(1) = ih22a(jchar(icode,2)) 
      lchk(2) = ih22a(jchar(icode,1))
      call upper(lchk,1,4)
C 
C     Now LCHK contains the four hex characters in the correct
C     check label.
C 
      write(lu,9903) lchk 
9903  format(1x,"check label is "2a2)  
999   continue    
C
      end 
