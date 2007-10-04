      subroutine proc_s2_comments(icode,kroll)
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

! passed
      integer icode
      logical kroll
! functions
      integer trimlen

      integer nch

      cbuf="rec_mode"
      nch=9
      if (krec_append) then
        cbuf(9:9)=crec(irec)
        nch=10
      endif
      cbuf(nch:nch+8)="="//cs2mode(istn,icode)
      nch=trimlen(cbuf)+1
      cbuf(nch:nch+1)=",$"
      nch=nch+2
C     If roll is NOT blank and NOT NONE then use it.
      if (kroll) then
        cbuf(nch:nch+4)=","//cbarrel(istn,icode)
      endif
      call lowercase_and_write(lu_outfile,cbuf)

      cbuf="user_info"
      nch=9
      if (krec_append) then
        cbuf(10:10)=crec(irec)
        nch=10
      endif

      write(lu_outfile,'(a,a)') cbuf(1:nch),'=1,label,station'
      write(lu_outfile,'(a,a)') cbuf(1:nch),'=2,label,source'
      write(lu_outfile,'(a,a)') cbuf(1:nch),'=3,label,experiment'
      write(lu_outfile,'(a,a,a)') cbuf(1:nch),'=3,field,',cexper
      write(lu_outfile,'(a,a,a)') cbuf(1:nch),'=1,field,,auto '
      write(lu_outfile,'(a,a,a)') cbuf(1:nch),'=2,field,,auto '
      call snap_data_valid('=off')

      return
      end

