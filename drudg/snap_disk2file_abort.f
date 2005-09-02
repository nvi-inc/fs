      subroutine snap_disk2file_abort(lufile,ldisk2file_node,
     >  ldisk2file_userid,ldisk2file_pass)

! passed
      integer lufile
      character*128 ldisk2file_node,ldisk2file_userid
      character*128 ldisk2file_pass
      character*600 ldum
      integer nch1,nch2,nch3
      nch1=len(ldisk2file_node)
      nch2=len(ldisk2file_userid)
      nch3=len(ldisk2file_pass)

      write(ldum,'(a)') "disk2file=abort,"//
     >  ldisk2file_node//","//ldisk2file_userid//","//ldisk2file_pass
      call squeezewrite(lufile,ldum)
      return
      end
