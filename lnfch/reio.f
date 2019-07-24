       real*4 function reio (mode,idevice,ibuf,length)

C
C Replacement for REIO exec call on A900.  For mode = 1, reads in a 
C character string and passes it back as a Hollerith string.  For
C mode = 2, writes string to idevice. The function value returned is
C a real*4 with an integer representing the number of characters read in
C saved in the lower 2 bytes.  Devices: stdin = 5, stdout = 6.
C
C      -P. Ryan    12.5.88
C

       character*256 cr
C        - cr   : character string
       character     tc
C        - tc   : character for I/O
       integer     i,ibuf(*),trimlen,icrl,ir(2), ios,ifc
       real*4        rex

       equivalence(ir(1),rex)

C  check whether the length is in words or characters
C  + for words, - for characters

       if (length .lt. 0) then ! characters
         icrl = -length
       else
         icrl = length*2 ! words
       end if

C  read or write?    1=read, 2=write

       if (mode .eq. 1) then
         ios = -1
         do while (ios .ne. 0)
           read(idevice,'(A)',iostat=ios) cr
           if (ios .ne. 0) then
             print*, 'error: re-enter data',ios
           end if
         end do
         i = trimlen(cr)
         call char2hol(cr,ibuf,1,i)
       else ! mode == 2
         ifc = 1
         call hol2char (ibuf,ifc,icrl,cr)
         do i=1,icrl
           tc = cr(i:i)
           write(idevice,10) tc
10         format (A,$)
         end do
         write(idevice,20) ! write out newline character
20       format (A)
       end if
       ir(2) = i
       reio  = rex
       end

