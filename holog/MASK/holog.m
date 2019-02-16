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