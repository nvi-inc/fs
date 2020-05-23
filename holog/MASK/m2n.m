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

function n=m2n(m,Tblock,Tr,Ts)
%convert factor m in Tsys to equivalent to factor n increase in SEFD for 
% partially blocking object
%input:
% m      = factor of increase in Tsys (scalar or vector)
% Tblock = temperature of blocking object
% Tr     = receiver temperature
% Ts     = contribution of sky to Tsys
%
% unblocked Tsys
T0=Tr+Ts;
% blocking fraction
a=T0*(m-1)/(Tblock-Ts);
% factor increase in SEFD
n=m./(1-a);
