!***********************************************************************
      subroutine SplitNTokens(ldum,ltokens,NumWant,NumGot)
      implicit none
      charactER*(*) ldum
      integer NumWant,NumGot
      character*(*) ltokens(NumWant)

      logical ktoken     !got token
      logical knospace   !no more space
      logical keol       !eol.
      integer istart,inext,itoken

      istart=1
      do itoken=1,NumWant
        call ExtractNextToken(ldum,istart,inext,ltokens(itoken),ktoken,
     >   knospace, keol)
         if(.not.ktoken) then
            NumGot=itoken-1
            return
         endif
        istart=inext
      end do
      NumGot=NumWant

      return
      end

