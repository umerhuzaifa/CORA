classdef (InferiorClasses = {?mp}) interval < contSet
% interval - object constructor for real-valued intervals 
%
% Description:
%    This class represents interval objects defined as
%    {x | a_i <= x <= b_i, \forall i = 1,...,n}.
%
% Syntax:
%    obj = interval()
%    obj = interval(I)
%    obj = interval(a)
%    obj = interval(a,b)
%
% Inputs:
%    I - interval object
%    a - lower limit
%    b - upper limit
%
% Outputs:
%    obj - generated interval object
%
% Example:
%    a = [1;-1];
%    b = [2;3];
%    I = interval(a,b);
%    plot(I,[1,2],'r');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: interval, polytope

% Author:       Matthias Althoff, Niklas Kochdumper
% Written:      19-June-2015
% Last update:  18-November-2015
%               26-January-2016
%               15-July-2017 (NK)
%               01-May-2020 (MW, delete redundant if-else)
%               20-March-2021 (MW, error messages)
%               14-December-2022 (TL, property check in inputArgsCheck)
%               29-March-2023 (TL: optimized constructor)
% Last revision:---

%------------- BEGIN CODE --------------

properties (SetAccess = private, GetAccess = public)
    inf;
    sup;
end

methods
    %class constructor
    function obj = interval(varargin)

        % parse input
        switch nargin
            case 0
                lb = [];
                ub = [];
            case 1
                lb = varargin{1};
                if isa(lb,'interval')
                    % copy constructor
                    obj = lb;
                    return;
                end
                ub = lb;
            case 2
                lb = varargin{1};
                ub = varargin{2};
            otherwise
                throw(CORAerror('CORA:tooManyInputArgs',2));
        end

        % check input
        if CHECKS_ENABLED
            inputArgsCheck({ ...
                {lb, 'att', 'numeric'}; ...
                {ub, 'att', 'numeric'}; ...
            })

            if ~all(size(lb) == size(ub))
                throw(CORAerror('CORA:wrongInputInConstructor',...
                    'Limits are of different dimension.'));
            elseif length(size(lb)) > 2
                throw(CORAerror('CORA:wrongInputInConstructor',...
                    'Only 1d and 2d intervals are supported.'));
            elseif ~all(lb <= ub, "all")
                 throw(CORAerror('CORA:wrongInputInConstructor',...
                     'Lower limit larger than upper limit.'));
            end
        end
        
        % assign properties;
        obj.inf = lb;
        obj.sup = ub;
    end
    
    function ind = end(obj,k,n)
    % overloads the end operator for referencing elements, e.g. I(end,2),
        ind = size(obj,k);
    end
    
    % methods in seperate files
    res = abs(I) % absolute value function
    I = acos(I) % inverse cosine function
    I = acosh(I) % inverse hyperbolic cosine function
    I = asin(I) % inverse sine function
    I = asinh(I) % inverse hyperbolic sine function
    I = atan(I) % inverse tangent function
    I = atanh(I) % inverse hyperbolic tangent function
    C = capsule(I) % conversion to capsule object
    c = center(I) % center of interval
    cPZ = conPolyZono(I) % conversion to conPolyZono object
    res = convHull(I,varargin) % convex hull
    cZ = conZonotope(I) % conversion to conZonotope object
    res = cos(I) % cosine function
    I = cosh(I) % hyperbolic cosine function
    I = ctranspose(I) % overloaded ' operator
    res = diag(I) % overloaded diag-function
    n = dim(I) % dimension of interval
    E = ellipsoid(I) % conversion to ellipsoid object
    I = enlarge(I,factor) % enlargement by factor
    res = eq(I1,I2) % equality check
    I = exp(I) % overloaded exp-function
    p = gridPoints(I,segments) % generate grid points
    I = horzcat(varargin) % overloaded horizontal concatenation
    res = infimum(I) % read lower limit
    res = isempty(I) % empty object check
    res = isequal(I1,I2,varargin) % equal objects check
    res = isFullDim(I) % full dimensionality check
    res = isscalar(I) % one-dimensionality check
    res = issparse(I) % issparse
    res = le(I1,I2) % subseteq check
    l = length(I) % largest dimension of interval
    I = log(I) % logarithm function
    res = lt(I1,I2) % subset check
    I = minkDiff(I,S,varargin) % Minkowski difference
    res = minus(minuend,subtrahend) % overloaded - operator (binary)
    res = mpower(base,exponent) % overloaded ^ operator
    P = mptPolytope(I) % conversion to mptPolytope object
    res = mrdivide(numerator,denominator) % overloaded / operator
    res = mtimes(factor1,factor2) % overloaded * operator
    res = ne(I1,I2) % overloaded ~= operator
    res = or(I,S) % union
    dzNew = partition(I, splits) % partition into subintervals
    han = plot(I,varargin) % plot
    res = plus(summand1,summand2) % overloaded + operator
    pZ = polyZonotope(I) % conversion to polyZonotope object
    res = power(base,exponent) % overloaded .^ operator
    res = prod(I,varargin) % overloaded prod-function
    I = project(I,dims) % projection onto subspace
    I = quadMap(varargin) % quadratic map
    r = rad(I) % radius (half of diameter)
    r = radius(I) % radius of enclosing hyperball
    res = rdivide(numerator,denominator) % overloaded ./ operator
    I = reshape(I,varargin) % overloaded reshape-function
    res = sin(I) % sine function
    I = sinh(I) % hyperbolic sine function
    varargout = size(I,varargin) % overloaded size-function
    res = split(I,n) % split along one dimension
    I = sqrt(I) % square root
    I = subsasgn(I,S,val) % value assignment
    newObj = subsref(I,S) % read from object
    res = sum(I,varargin) % overloaded sum-function
    res = supremum(I) % read upper limit
    res = tan(I) % tangent function
    I = tanh(I) % hyperbolic tangent function
    res = times(factor1,factor2) % overloaded .* function
    I = transpose(I) % overloaded .' function
    I = uminus(I) % overloaded unary - operator
    I = uplus(I) % overloaded unary + operator
    I = vertcat(varargin) % vertical concantenation
    zB = zonoBundle(I) % conversion to zonoBundle object
    Z = zonotope(I) % conversion to zonotope object
    
    % display functions
    display(I)
end

% methods (Access = {?contSet, ?contDynamics})
%     res = isIntersecting_(S1,S2,type,varargin)
% 
% end

methods (Static = true)
    I = generateRandom(varargin) % generates random interval
    I = enclosePoints(points) % enclosure of point cloud
end


end

%------------- END OF CODE -------