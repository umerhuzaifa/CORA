clear all
close all
clc

set1 = zonotope(cartProd(interval(-2,2), interval(-2,2)));
set2 = zonotope(cartProd(interval(-2,2), interval(-2,1)));

set3 = ellipsoid(set1)
set_mTimes = cartProd(set1, set2)

% distance(set1, set3)


figure
subplot(121)
plot(set1)
hold on
% plot(set2)
% plot(set_mTimes)
subplot(122)
plot(set3)

% specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spec1 = specification(interval(-2,2),'safeRegion')