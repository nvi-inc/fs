% Copyright (c) 2020 NVI, Inc.
%
% This file is part of VLBI Field System
% (see http://github.com/nvi-inc/fs).
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.

function grid=holog(file,detector,columns)
% read in holog grid from row ordered file made by holog_rdbe script
% input:
% file     = with space delimited data, one detector per column
%            for a given column length/columns must be an odd integer,
%            this 'columns' is not the columns in the file, it is number
%            of columns in each row data embedded in the column of the
%            file, data must be in 'holog' program sampling order, i.e.,
%            directions of rows alternate
% detector = column to extract, index origin 1
% columns  = number of columns along the first axis for 'holog', odd
% output:
% grid     = result matix, rows are different elevations
%                          columns are different azimuths
grid=dlmread(file);
grid=grid(:,detector);
len=length(grid);
rows=fix(len/columns);
if(rows*columns~=len)
    error(' columns %d does not divide data length %d evenly\n',columns,len);
    return;
end
%shape it into a rectangular grid
grid=reshape(grid,[columns,rows])';
%reverse the even rows
grid([2:2:rows-1],:)=grid([2:2:rows-1],[columns:-1:1]);
