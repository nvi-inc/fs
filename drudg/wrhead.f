	SUBROUTINE wrhead(lu,ierr,cs,iw,isig,idoub,ldoub,ido,imode,icod)
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
C
C  INPUT:
      integer lu,iblen,icod
	character*12 cs   ! what line to write
	integer iw      ! number of characters in cs
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
      integer idum,ierr,ix,iy,nch,im
      integer ileft,iout
      integer ichcm_ch,ichmv,ib2as,ichmv_ch ! function
C
        ileft = o'100000'
	iblen = ibuf_len*2
        iout=0

C  insert string into array

	call ifill(ibuf,1,iblen,32)
	call char2hol(cs,ibuf,1,iw)
	nch = iw + 1

C  loop on the number of channels read from schedule file

        do ix=1,nvcs(istn,icod)
          do im=1,imode
            nch = ichmv_ch(ibuf,nch,'(')
            if (imode.eq.1) then !only one entry, use ix
              nch = nch + ib2as(ix,ibuf,nch,ileft+2)
            else !two entries, use iy
              iy = (ix-1)*2 + im
              nch = nch + ib2as(iy,ibuf,nch,ileft+2)
            endif
            nch = ichmv_ch(ibuf,nch,',')

	  if ((ido.eq.1).or.(ido.eq.2)) then
            nch = nch + ib2as(isig,ibuf,nch,ileft+2)
          endif

	  if (ido.eq.2) then ! append "M"
            nch = ichmv_ch(ibuf,nch,'M')
	  else if (ido.eq.3) then ! use integer array
            nch = nch + ib2as(idoub(ix,istn,icod),ibuf,nch,ileft+2)
	  else if (ido.eq.4) then ! use character array
            if (ichcm_ch(ldoub(ix,istn,icod),1,'U').eq.0) then !U/L
              if (im.eq.1) nch = ichmv_ch(ibuf,nch,'U')
              if (im.eq.2) nch = ichmv_ch(ibuf,nch,'L')
            else
	      nch = ichmv(ibuf,nch,ldoub(ix,istn,icod),1,1)
            endif
	  end if

          nch = ichmv_ch(ibuf,nch,')')
          iout = iout + 1

C  write out buffer if reached 8 channels written into it

	  if (mod(iout,8).eq.0) then
	    call writf_asc(lu,ierr,ibuf,(nch+1)/2)
	    call ifill(ibuf,1,iblen,32)
	    call char2hol(cs,ibuf,1,iw)
	    nch = iw + 1
	  else
            nch = ichmv_ch(ibuf,nch,',')
	  end if
          enddo !im=1,imode
	end do !ix=1,nchanv

C  write out buffer if there is something to write

	if (nvcs(istn,icod).ne.8) then
          nch = ichmv_ch(ibuf,nch-1,' ')
	  call writf_asc(lu,ierr,ibuf,(nch+1)/2)
	end if
C
	RETURN
	END
