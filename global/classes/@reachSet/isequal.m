function res = isequal(R1,R2,varargin)
% isequal - checks if two reachSet objects are equal
%
% Syntax:  
%    res = isequal(R1,R2)
%    res = isequal(R1,R2,tol)
%
% Inputs:
%    R1 - reachSet object
%    R2 - reachSet object
%    tol - (optional) tolerance for set comparison
%
% Outputs:
%    res - true/false
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: reachSet

% Author:       Mark Wetzlinger
% Written:      10-November-2022
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

% set default values
tol = setDefaultValues({1e-12},varargin);

% check input arguments (only first two)
inputArgsCheck({{R1,'att','reachSet'};
                {R2,'att','reachSet'}; ...
                {tol,'att','numeric',{'scalar','nonnegative'}}});

% init result
res = true;

% check if same number of branches
if length(R1) ~= length(R2)
    res = false; return
end

% loop over all branches: check if same parent/location
for i=1:length(R1)
    if R1(i).parent ~= R2(i).parent
        res = false; return
    end
    if R1(i).loc ~= R2(i).loc
        res = false; return
    end
end

% check if each branch has same number of sets
for i=1:length(R1)
    % time-point solution
    R1empty = isempty(R1(i).timePoint.set);
    R2empty = isempty(R2(i).timePoint.set);
    if R1empty ~= R2empty || ( ~R1empty && ~R2empty ...
            && length(R1(i).timePoint.set) ~= length(R2(i).timePoint.set) )
        res = false; return
    end

    % time-interval solution
    R1empty = isempty(R1(i).timeInterval.set);
    R2empty = isempty(R2(i).timeInterval.set);
    if R1empty ~= R2empty || ( ~R1empty && ~R2empty ...
            && length(R1(i).timeInterval.set) ~= length(R2(i).timeInterval.set) )
        res = false; return
    end
end

% check if sets are the same
for i=1:length(R1)
    % time-point solution
    R1empty = isempty(R1(i).timePoint.set);
    if ~R1empty
        for j=1:length(R1(i).timePoint.set)
            if ~isequal(R1(i).timePoint.set{j},R2(i).timePoint.set{j},tol)
                res = false; return
            end
        end
    end

    % time-interval solution
    R1empty = isempty(R1(i).timeInterval.set);
    if ~R1empty
        for j=1:length(R1(i).timeInterval.set)
            if ~isequal(R1(i).timeInterval.set{j},R2(i).timeInterval.set{j},tol)
                res = false; return
            end
        end
    end
end

%------------- END OF CODE --------------
