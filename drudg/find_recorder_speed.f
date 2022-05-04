*
* Copyright (c) 2020-2021 NVI, Inc.
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
      subroutine find_recorder_speed(icode,spd_rec,kskd)
      implicit none 
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/broadband.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
! passed
      integer icode                     ! current mode
      logical kskd                      ! do we have a sked file? need to get speed for Mark5A or Mark5P

! 2021-12-15 JMG. Got rid of some obsolete code. Get speed from idata_mbs if present. 
!            Handle case of recorder="NONE" 
! 2013Sep19  JMGipson made sample rate station dependent
! 2015Mar30  JMG. Added support for Mark6.
! 2020Jun08  JMG Added reference to broadband.ftni 
!

! returned
      double precision spd_rec   ! speed of recorder.
! local     
      integer ntracks_rec_mk5
      integer nchans_obs                !Number recorded
      integer ifan_fact                 !ifan_factor
      integer ipass
     
    
      if(idata_mbps(istn) .ne. 0) then 
! this was set externally. Use it. 
! Generally means came from a sked file with $BROADBAND section
        spd_rec=idata_mbps(istn)/8    
      else if(Km5disk .or. km6disk .or. cstrec_cap .eq. "NONE") then
        if(kskd) then        
          ifan_fact=1
          ipass=1
          call find_num_chans_rec(ipass,istn,icode,
     >            ifan_fact,nchans_obs,ntracks_rec_mk5)   
          spd_rec=ntracks_rec_mk5*samprate(istn,icode)/8   
        endif 
      endif

      return
      end
