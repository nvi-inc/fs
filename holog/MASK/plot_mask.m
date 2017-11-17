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