      logical function kbit(iarray,ibit)
      implicit none
      integer iarray(1),ibit
c 
c  kbit is true if the ibit-th bit of iarray is set, false otherwise
c  the first max_int_bits are in the first int of the array,
c  the second max_int_bits are in the second int of the array
c  within an int the bits are numbered such that if i (range 1 to
c  and including max_int_bits) is the only bit the set in the int,
c  the int equals 2**(i-1)
c  kbit is designed to complement sbit which sets or resets 
c  bits identified in the same way. 
c
c     include '../include/params.i'
C NRV 951015 set variable INT_BITS instead
      integer INT_BITS
c 
      integer ib,iw
      logical bjtest

c 
      INT_BITS=32
      iw = ((ibit-1)/INT_BITS)+1
      ib = ibit - (iw-1)*INT_BITS
c 
      kbit = bjtest(iarray(iw),ib-1) 
c 
      return
      end 
