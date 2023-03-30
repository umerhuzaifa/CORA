function [val,x] = supportFunc_(I,dir,varargin)
% supportFunc_ - Calculate the upper or lower bound of an interval along a
%    certain direction
%
% Syntax:  
%    val = supportFunc_(I,dir)
%    [val,x] = supportFunc_(I,dir,type)
%
% Inputs:
%    I - interval object
%    dir - direction for which the bounds are calculated (vector)
%    type - upper bound, lower bound, or both ('upper','lower','range')
%
% Outputs:
%    val - bound of the interval in the specified direction
%    x - support vector
%
% Example:
%    I = interval([-2;1],[3;2]);
%    dir = [1;1]/sqrt(2);
%    supportFunc(I,dir)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: zonotope/supportFunc_

% Author:       Niklas Kochdumper
% Written:      19-November-2019
% Last update:  ---
% Last revision:27-March-2023 (MW, rename supportFunc_)

%------------- BEGIN CODE --------------

% compute support function (call there contains input check)
if nargout == 1
    val = supportFunc_(zonotope(I),dir,varargin{:});
else
    [val,x] = supportFunc_(zonotope(I),dir,varargin{:});
end

%------------- END OF CODE --------------