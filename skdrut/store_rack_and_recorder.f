*
* Copyright (c) 2022 NVI, Inc.
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
      subroutine store_rack_and_recorder(lu, lstatname,
     >      crack,crec, cstrack,cstrec)
      implicit none
  
! Store the rack and the recorder in the appropriate slots.
! Do some error checking. 
! History

! 2022-02-10 JMGipson. First version. 
      integer lu                 !logical unit to write_to 
      character*8 lstatname
! Input vallues 
      character*12 crec   ! recorder
      character*20 crack ! rack
! At a station. 
      character*12 cstrec   ! recorder
      character*20 cstrack ! rack

      character*100 ldum

! Functions
      logical kvalid_rack
      logical kvalid_rec
      

      if(.not.kvalid_rack(crack)) then        
           write(lu,'(a)') 
     >       "  WARNING! Store_rack_and_recorder:  For station "//     
     >        lstatname//" unrecognized rack type: "//
     >        crack//" Setting to blank!"    
            crack=' '
        endif 
        cstrack=crack         

        if(.not.kvalid_rec(crec)) then    
            write(lu,'(a)') 
     >      "  WARNING! Store_rack_and_recorder:  For station "//     
     >        lstatname//" unrecognized recorder type: "//
     >        crec//" Setting to blank!"
            crec=' '
        endif   
        cstrec=crec 
        return
        end 
      
       
