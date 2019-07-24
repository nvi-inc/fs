      subroutine unscaler(matrix, vector, scale, dim)
C
      implicit none
      double precision matrix(1), vector(dim), scale(dim)
      integer dim
C
C  UNSCALE SOLVE FORMAT MATRIX AND B VECTOR
C
      integer i
      integer ij
      double precision local
C
C   unscaling
C
      ij=1
      do i=1,dim
        local=scale(i)
        call dvsmy(local,matrix(ij),1,matrix(ij),1,i)
        call dvmpy(matrix(ij),1,scale,1,matrix(ij),1,i)
        ij = ij + i
      enddo
      call dvmpy(vector,1,scale,1,vector,1,dim)
C
      return
      end
