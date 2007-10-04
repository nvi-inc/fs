      subroutine read_snap6(cbuf,crack,creca,crecb,ierr)

C Read the sixth comment line of a SNAP file. 
C Example:
C " Rack=VLBAG     Recorder A=VLBA      Recorder B=none     

C 991103 nrv Created to scan for equipment. 

C Called by: LSTSUM

C Input
      character*(*) cbuf
C Output
      character*8 crack,creca,crecb
      integer ierr

C Local
      integer ic1,ich,ilen
!  functions
      integer trimlen

C Convert to hollerith, find length.
      ilen=trimlen(cbuf)
      crack = ' '
      creca = ' '
      crecb = ' '

C Find up to three '=' and take the name following.

      ierr=-1
      ich = index(cbuf,'=')
      if (ich.eq.0) return
      ic1 = ich + index(cbuf(ich:),' ') 
      if (ic1.eq.0) return
      crack = cbuf(ich+1:ic1)
      ich = ic1 + index(cbuf(ic1:),'=') - 1
      if (ich.eq.0) return
      ic1 = ich + index(cbuf(ich:),' ')
      if (ic1.eq.0) return
      creca = cbuf(ich+1:ic1)
      ich = ic1 + index(cbuf(ic1:),'=') - 1
      if (ich.eq.0) return
      ic1 = ich + index(cbuf(ich:),' ')
      if (ic1.eq.0) return
      crecb = cbuf(ich+1:ic1)

      ierr=0

      return
      end
