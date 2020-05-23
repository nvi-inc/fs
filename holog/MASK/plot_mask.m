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

function plot_mask(mask,new,elmax,azmin,azmax)
% plot mask
%input:
% mask -  vector of [az,el,...,final], odd positions are azs, even are els
%         if final value is an az,
%           then el are step heights between the adjacent az values
%         if final value is an el,
%           then az,el pairs define endpoints of connected line segments
% new  - 1 (default) or 0 for new plot or re-use existing plot
%        0 is useful to add more masks to the same plot
% for new==1:
% elev -  el axis upper limit
%         max el value (default) or user specified level
% azmin - az axis lower limit
%         min az value (default) or user specified level
% azmax - az axis upper limit
%         max az value (default) or user specified level
if(nargin < 1)
    error('Too few arguments');
    return;
else
    len=length(mask);
    if(nargin < 5)
        azmax=mask(len+mod(len,2)-1);
        if(nargin < 4)
            azmin=mask(1);
            if(nargin < 3)
                elmax=max(mask(2:2:len-mod(len,2)));
                if(nargin < 2)
                    new=1;
                end
            end
        end
    end
end
if(new==1)
    clf
    hold on
    axis([azmin,azmax,0,elmax]);
    box on
end
if(1==mod(len,2))
    x=[];
    y=[];
    for i = [1:2:len-1]
        x=[x,mask(i),mask(i+2)];
        y=[y,mask(i+1),mask(i+1)];
    end
else
    x=mask(1:2:len-1);
    y=mask(2:2:len);
end
plot(x,y);
