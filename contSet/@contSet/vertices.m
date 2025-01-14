function res = vertices(S,varargin)
% vertices - computes the vertices of a set
%
% Syntax:
%    res = vertices(S)
%    res = vertices(S,method)
%
% Inputs:
%    S - contSet object
%    method - method for computation of vertices
%
% Outputs:
%    res - array of vertices
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: -

% Author:       Mark Wetzlinger
% Written:      18-August-2022
% Last update:  23-November-2022 (MW, add classname as input argument)
% Last revision:27-March-2023 (MW, restructure relation to subclass)

%------------- BEGIN CODE --------------

% check number of input arguments
if nargin < 1
    throw(CORAerror('CORA:notEnoughInputArgs',1));
elseif nargin > 2
    throw(CORAerror('CORA:tooManyInputArgs',2));
end

% parse input arguments
method = setDefaultValues({'convHull'},varargin); 

% check input arguments
inputArgsCheck({{S,'att','contSet'};
                {method,'str',{'convHull','iterate','polytope'}}});

% call subclass method
try
    res = vertices_(S,method);
catch ME
    % empty set case
    if isempty(S)
        res = []; return
    end
    rethrow(ME);
end

%------------- END OF CODE --------------
