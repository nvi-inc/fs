      subroutine fsvrs(ip)
C  display fs version number
C
C
C     INPUT VARIABLES:
      dimension ip(1)
C
C     OUTPUT VARIABLES:
C        IP(1) - CLASS #
C        IP(2) - # RECORDS IN CLASS
C        IP(3) - ERROR
C        IP(4) - who we are
C
      include '../include/fscom.i'
C
C     CALLED SUBROUTINES: CHARACTER ROUTINES
C
C   LOCAL VARIABLES
C        NCHAR  - number of characters in buffer
C        NCH    - character counter
      integer*2 ibuf(20)                    !  class buffer
      dimension ireg(2)                     !  registers from exec calls
      dimension iparm(2)                    !  parameters from gtparm
      equivalence (reg,ireg(1))
      equivalence (parm,iparm(1))
C
C 5.  INITIALIZED VARIABLES
C
C 6.  PROGRAMMER: MWH
C     LAST MODIFIED: CREATED  890531
C
C
C     1. Display current FS version.
C
      nch = ichmv_ch(ibuf,1,'fsversion/')
C                   Put / to indicate a response
      idum=sVerMajor_FS
      nch = nch + ib2as(idum,ibuf,nch,o'100000'+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerMinor_FS
      nch = nch + ib2as(idum,ibuf,nch,o'100000'+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerPatch_FS
      nch = nch + ib2as(idum,ibuf,nch,o'100000'+5)
      nch = nch-1
C
      iclass = 0
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1
      ip(3) = 0
      call char2hol('q&',ip(4),1,2)
      return
      end
