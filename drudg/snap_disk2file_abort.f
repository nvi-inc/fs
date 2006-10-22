      subroutine snap_disk2file_abort(lufile)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'

! passed
      integer lufile
      integer trimlen
      integer nch

      nch =max(trimlen(lautoftp_string),1)

      if(kautoftp) then
        write(lufile,'(a)')
     >      "disk2file=abort,autoftp,"//lautoftp_string(1:nch)
      else
        write(lufile,'(a)') "disk2file=abort,,"
      endif

      return
      end
