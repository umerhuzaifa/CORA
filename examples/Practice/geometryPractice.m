clear all
close all
clc

% constrained geometric shapes

guard_bounceBall = conHyperplane([1,0],0,[0,1],0);
ex_halfspace=halfspace([1,1],1);

vars = sym('x',[2,1]);
f = 1/vars(1)^2 - vars(2);
op='<=';
ex_levelset = levelSet(f, vars, op);
% plotting the shapes

% plot(guard_bounceBall)
hold on 
% plot(ex_halfspace)
plot(ex_levelset,[1,2],'Color',colorblind('r'));
grid on 
set(gcf, 'Color', 'white')