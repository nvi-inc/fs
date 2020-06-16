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
	SUBROUTINE wrhead(lu,ierr,cs,isig,idoub,ldoub,ido,imode,icod)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C   wrhead writes the header lines period, bbfilter, level,
C   baseband, ifchan, and sideband for a VLBA schedule pointing
C   file.
C
      include '../skdrincl/skparm.ftni'
C
C   COMMON BLOCKS USED
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900802 CREATED
C     gag   901025 got rid of trailing blanks
C     gag   910513  Added parameter to common variable nchanv.
C     nrv   930412 implicit none
C     nrv   930708 Added imode in calling list, rewrote to simplify and
C                  use built-in features of ib2as. Add inner loop to get
C                  all channels for Mode A written out.
C 960703 nrv Use ix index when writing sideband.
! 2008Aug19 JMG.  A little cleanup and modernization.
C
C  INPUT:
      integer lu,iblen,icod
      character*(*) cs   ! what line to write
      integer isig    ! value to write out for each channel
      integer ido     ! mode passed from calling routine
      integer idoub(max_chan,max_stn,max_frq)  ! two dimension array
      integer*2 ldoub(max_chan,max_stn,max_frq)  ! two dimension array
      integer imode   ! 1=write out one entry per BBC
C                           2=need double the entries
C
C  ido is either:
C      1 - for an integer
C      2 - for a character M following an integer
C      3 - to use idoub, an integer
C      4 - to use ldoub, a character
C
C  OUTPUT:
C
C     CALLED BY: VLBAH
C
C  LOCAL VARIABLES
      integer ierr,ix,iy,nch,im
      integer ichan,ileft,iout
      integer ichcm_ch,ichmv,ib2as,ichmv_ch ! function
C
        ileft = o'100002'
	iblen = ibuf_len*2
        iout=0

C  insert string into array
C  loop on the number of channels read from schedule file
! Changed 2014May21
         iy=0
         do ix=2,5
!        do ix=1,nchan(istn,icod) ! is=recorded channel index
          if(mod(iout,8) .eq. 0) then                 !initialize front of string
             cbuf=cs
             nch=len(cs)+1
          endif

          ichan=invcx(ix,istn,icod) ! ichan=total#channel index
! End change
          do im=1,imode
            nch = ichmv_ch(ibuf,nch,'(')
            iy=iy+1
!            if (imode.eq.1) then !only one entry, use ix
! Changed 2014May21
!              iy=ix-1
!            else !two entries, use iy
!              iy = (ix-1)*2 + im
!            endif
            nch = nch + ib2as(iy,ibuf,nch,ileft)

            nch = ichmv_ch(ibuf,nch,',')

	  if ((ido.eq.1).or.(ido.eq.2)) then ! single value
            nch = nch + ib2as(isig,ibuf,nch,ileft)
          endif

	  if (ido.eq.2) then ! append M
            nch = ichmv_ch(ibuf,nch,'M')
	  else if (ido.eq.3) then ! use integer array
            nch = nch + ib2as(idoub(ichan,istn,icod),ibuf,nch,ileft)
	  else if (ido.eq.4) then ! use character array
            if (ichcm_ch(ldoub(ichan,istn,icod),1,'U').eq.0.or.
     .          ichcm_ch(ldoub(ichan,istn,icod),1,'L').eq.0) then !U/L
C             For the usb, take the LO sb as given
              if (im.eq.1) nch = ichmv(ibuf,nch,
     .            ldoub(ichan,istn,icod),1,1)
C             For the lsb, take the other one
              if (im.eq.2) then
                if (ichcm_ch(ldoub(ichan,istn,icod),1,'U').eq.0) then
                  nch = ichmv_ch(ibuf,nch,'L')
                else
                  nch = ichmv_ch(ibuf,nch,'U')
                endif
              endif
            else
              nch = ichmv(ibuf,nch,ldoub(ichan,istn,icod),1,1)
            endif
	  end if

          nch = ichmv_ch(ibuf,nch,')')
          iout = iout + 1
C  write out buffer if reached 8 channels written into it
          if(mod(iout,4).eq.0) then
!	  if (mod(iout,8).eq.0) then
            write(lu,'(a)') cbuf(1:nch)
            return
	  else
            nch = ichmv_ch(ibuf,nch,',')
	  end if
          enddo !im=1,imode
	end do !ix=1,nchanv

C  write out buffer if there is something to write
	if (nchan(istn,icod).ne.8) then
          write(lu,'(a)') cbuf(1:nch-2)     !skip terminal ","
	end if
C
	RETURN
	END
