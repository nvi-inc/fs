!***********************************************************************
      subroutine SplitNTokens2(ldum,ltokens,MaxToken,NumGot,istart_vec)
! identical to SplitNtokens
      implicit none
      charactER*(*) ldum
      integer MaxToken,NumGot
      character*(*) ltokens(MaxToken)
      integer istart_vec(*)
! function
      integer ifirst_non_blank

      logical ktoken     !got token
      logical knospace   !no more space
      logical keol       !eol.
      integer istart,inext,itoken

      istart=1
      do itoken=1,MaxToken
        call ExtractNextToken(ldum,istart,inext,ltokens(itoken),ktoken,
     >   knospace, keol)
         istart_vec(itoken)=istart
         if(.not.ktoken) then
            NumGot=itoken-1
            return
         endif
        istart=inext
      end do
      NumGot=MaxToken

      return
      end

