function res = isequal(loc1,loc2,varargin)
% isequal - checks if two locations are equal by comparing the invariants,
%    transitions, flow equations, and names
%
% Syntax:  
%    res = isequal(loc1,loc2)
%    res = isequal(loc1,loc2,tol)
%
% Inputs:
%    trans1 - location object
%    trans2 - location object
%    tol - tolerance (optional)
%
% Outputs:
%    res - true/false
%
% Example:
%    % invariant
%    polyOpt = struct('A',[-1,0],'b',0);
%    inv = mptPolytope(polyOpt);
%    
%    % transition
%    c = [-1;0]; d = 0; C = [0,1]; D = 0;
%    guard = conHyperplane(c,d,C,D);
%
%    % reset function
%    reset = struct('A',[1,0;0,-0.75],'c',[0;0]);
%
%    % transition
%    trans{1} = transition(guard,reset,2);
%
%    % flow equation
%    dynamics = linearSys([0,1;0,0],[0;0],[0;-9.81]);
%
%    % define locations
%    loc1 = location('S1',inv,trans,dynamics);
%    loc2 = location('S2',inv,trans,dynamics);
%
%    % comparison
%    res = isequal(loc1,loc1);
%    res = isequal(loc1,loc2);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author:       Mark Wetzlinger
% Written:      26-November-2022
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

% too many input arguments
if nargin > 3
    throw(CORAerror('CORA:tooManyInputArgs',3));
end

% default values
tol = setDefaultValues({eps},varargin);

% check input arguments
inputArgsCheck({{loc1,'att','location'};
                {loc2,'att','location'};
                {tol,'att','numeric',{'scalar','nonnegative','nonnan'}}});

% assume true
res = true;

% compare names
% if ~strcmp(loc1.name,loc2.name)
%     res = false; return
% end

% compare invariants: 
% note: we use 'eq' instead of 'isequal' as long as the mptPolytope class
% exists, once the switch to the polytope class is done, use 'isequal';
% also, the invariant then should not be [], but a polytope that spans the
% entire space (e.g., 0*x <= 0), so no need for case differentiation
if ~(isnumeric(loc1.invariant) && isempty(loc1.invariant) ...
        && isnumeric(loc2.invariant) && isempty(loc2.invariant))
    if xor(isnumeric(loc1.invariant),isnumeric(loc2.invariant)) ...
            || ( isnumeric(loc1.invariant) ...
                && ~all(isempty(loc1.invariant),isempty(loc2.invariant)) ) ...
            || ~eq(loc1.invariant,loc2.invariant,tol)
        res = false; return
    end
end

% compare flow equations
if ~isequal(loc1.contDynamics,loc2.contDynamics,tol)
    res = false; return
end

% compare transitions

% same number of outgoing transitions
if length(loc1.transition) ~= length(loc2.transition)
    res = false; return
end

% try to find match between transitions
idxInLoc2 = false(length(loc1.transition));

for i=1:length(loc1.transition)
    % assume no matching transition was found
    found = false;

    % loop over all transitions of second location
    for j=1:length(loc2.transition)
        % skip transitions that have already been matched
        if ~idxInLoc2(j)
            % check for equality
            if isequal(loc1.transition{i},loc2.transition{j},tol)
                % matching transition found
                found = true; idxInLoc2(j) = true;
                break
            end
        end
    end
    
    if ~found
        % i-th transition in loc1 has no match in loc2
        res = false; return
    end
end

%------------- END OF CODE --------------
