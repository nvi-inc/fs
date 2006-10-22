      subroutine read_snap1(cbuf,cexper,iyear,cstn,cid1,cid2,ierr)

C Read the first comment line of a SNAP file in free-field format.
C Format:
C" VT2       1996 SHANG     S  
C           read(cbuf,9001) cexper,iyear,cstn,cid !header line
C9001        format(2x,a8,2x,i4,1x,a8,2x,a2)

C 970312 nrv Created to remove formatted reads.
! 2006Sep26. Rewritten to be simpler

C Called by: LSTSUM, CLIST, LABEL

C Input
      character*(*) cbuf
C Output
      character*8 cexper,cstn
      integer iyear
      character*2 cid2
      character*1 cid1
      integer ierr
! local

      ierr=0 
      cbuf(1:1)=" "   !get rid of first character.
      read(cbuf,*) cexper,iyear,cstn,cid1,cid2
      write(*,*) cexper,iyear,cstn,cid1,cid2
      return
      end
