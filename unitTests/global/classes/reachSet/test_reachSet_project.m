function res = test_reachSet_project
% test_reachSet_project - unit test function for project
%
% Syntax:  
%    res = test_reachSet_project()
%
% Inputs:
%    -
%
% Outputs:
%    res - true/false 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: mtimes

% Author:       Mark Wetzlinger
% Written:      10-November-2022
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

% init result
res = true;

% instantiate set, propagation matrix
Z = zonotope([1;1;4],[1 0 -2; 2 -1 1; -2 4 -1]);
projDim = [1,2];
s = [1; -1; 2];
dt = 0.02;
steps = 10;

% propagate sets
timeInt.set = [];
timeInt.time = [];
for i=1:steps
    timePoint_true.set{i,1} = project(Z + i*s,projDim);
    timePoint_true.time{i,1} = i*dt;
    timePoint.set{i,1} = Z + i*s;
    timePoint.time{i,1} = i*dt;
end
R = reachSet(timePoint,timeInt);
R_true = reachSet(timePoint_true,timeInt);

% projected reach set
R_proj = project(R,projDim);

% compare results
for i=1:steps
    if ~isequal(R_true.timePoint.set{i},R_proj.timePoint.set{i},1e-14)
        res = false; break
    end
end

%------------- END OF CODE --------------