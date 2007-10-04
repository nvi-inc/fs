      subroutine proc_pcalf(icode,lwhich8)
! Issue pcalf

      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
! passed
      integer icode
      character*1 lwhich8

! functions
      integer iaddpc

! History
! 2007Jul19 JMGipson. Separated from procs.f

! local
      character*12 cnamep
      integer ichan
      integer nch
      integer ic        !channel #
      integer ib        !bbc#
      logical kinclude
      integer isb,isbx  !sideband

      cnamep="pcalf"//ccode(icode)
      call proc_write_define(lu_outfile,luscn,cnamep)
C PCALFORM=
      write(lu_outfile,'(a)') 'pcalform='
C PCALFORM commands
      DO ichan=1,nchan(istn,icode) !loop on channels
        cbuf="pcalform="
        nch=10

        ic=invcx(ichan,istn,icode) ! channel number
C       Use BBC number, not channel number
        ib=ibbcx(ic,istn,icode) ! BBC number
        if (cnetsb(ic,istn,icode).eq.'U') isb=1
        if (cnetsb(ic,istn,icode).eq.'L') isb=2
        kinclude=.true.
        if (k8bbc) then
          if (km3be) then
            ib=ichan
          else if (km3ac) then
            if (lwhich8 .eq. "F") then
              ib=ichan
              if (ib.gt.8) kinclude=.false.
C             Write out a max of 8 channels for 8-BBC stations
            else if (lwhich8.eq. "L") then
              ib=ichan-6
              if (ib.le.0) kinclude=.false.
            endif
          endif
        endif
        if (kinclude) then
          isbx=isb
          if(abs(freqrf(ic,istn,icode)).lt.
     >           freqlo(ic,istn,icode)) then ! reverse sidebands
            isbx=3-isb                      !2-->1,  1-->2
          endif ! reverse sidebands
        endif
        nch = iaddpc(ibuf,nch,ib,isbx,ipctone(1,ic,istn,icode),
     .       npctone(ic,istn,icode))
            call lowercase_and_write(lu_outfile,cbuf)
      enddo ! loop on channels
      write(lu_outfile,"('enddef')")
      return
      end


