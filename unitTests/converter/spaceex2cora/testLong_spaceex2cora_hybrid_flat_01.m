function res = testLong_spaceex2cora_hybrid_flat_01
% testLong_spaceex2cora_hybrid_flat_01 - test for model conversion
%    from SpaceEx to CORA for a simple hybrid system with one location
%
% Syntax:
%    res = testLong_spaceex2cora_hybrid_flat_01
%
% Inputs:
%    -
%
% Outputs:
%    res - true/false

% Author:       Mark Wetzlinger
% Written:      10-January-2023
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

% assume true
res = true;


% directory to SpaceEx model file
dir_spaceex = [CORAROOT filesep 'unitTests' filesep 'converter' ...
    filesep 'spaceex2cora' filesep 'testSystems'];

% file name of SpaceEx model file
filename = 'test_hybrid_flat_oneloc4';

% convert SpaceEx model from .xml file
spaceex2cora([dir_spaceex filesep filename '.xml']);

% instantiate system from converted SpaceEx model
sys_spaceex = feval(filename);


% instantiate equivalent CORA model
inv = mptPolytope(struct('A',[-1 0; 0 1],'b',[0; 0]));

% transitions
c = [1;0]; d = 0; C = [0 1]; D = 0;
guard = conHyperplane(c,d,C,D);
reset = struct('f',@(x,u) [-x(1); sin(x(2)) + u(1)]);
trans{1} = transition(guard,reset,1);

c = [0;-1]; d = 0; C = [1 0]; D = 0;
guard = conHyperplane(c,d,C,D);
reset = struct('A',[0,1;-1,0],'c',[-1;0]);
trans{2} = transition(guard,reset,1);

% flow equation
f = @(x,u) [-2*sin(x(1)) + u(1); log(x(1)) - x(2)];
dynamics = nonlinearSys([filename '_Loc1_FlowEq'],f);

% define location
loc{1} = location('always',inv,trans,dynamics);

% instantiate hybrid automaton
sys_cora = hybridAutomaton(loc);

% compare systems
if sys_cora ~= sys_spaceex
    res = false;
end

%------------- END OF CODE --------------