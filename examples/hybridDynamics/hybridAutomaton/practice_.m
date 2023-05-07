clear all
close all
clc


Z1 = cartProd(interval(-2, 2), interval(-2, 2));
spec1 = specification(Z1, 'safeSet', interval(0, 1));


c = [0;0];
G = 0.5 * [1 1 1; 1 -1 0];
set2 = zonotope(c,G);

check(spec1, set2, interval(0,1))

%%%%%%%%%%%%% Visualize %%%%%%%%%%%%%%%%%%%%


plot(spec1)

hold on

plot(set2)


%%
close all
clear all
clc

dbstop if error

% Define the system dynamics as a set of ODEs
% sys = @(t,x) [-x(1) + x(2)^2; -x(2) - x(1)^2];
A = [0, 1; -1,-1]; B = [0; 1];
sys = linearSys(A, B);
% Define the initial set of states as a box
params.R0 = zonotope([2;2]);%cartProd(interval(-1, 1), interval(-1, 1));

T = 5;
params.tFinal = T;
% params.R0 = zonotope([0;0;0;0;0],diag(1e-8*[1 1 1 1 1]));
params.startLoc = 1;

% Define the temporal logic formula as a string
Z1 = cartProd(interval(-2, 3), interval(-2, 3));
spec1 = specification(Z1, 'safeSet', interval(0, 1));
% phi = 'G(x(1) > -1 & x(2) > -1 & x(1) < 1 & x(2) < 1)';
% spec1 = specification(phi);
plot(spec1)
hold on


% Call the reach function to compute the reachable set
options.timeStep = T/5;
options.taylorTerms = 5;
options.zonotopeOrder = 2;
% [~, reachset] = reach(sys, params, options);

R= reach(sys, params, options);
plot(R)
% Call the verify function to check if the specification is satisfied
% [bool, ~, ~] = 
check( spec1, R)
