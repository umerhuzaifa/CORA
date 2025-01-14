function [R,res] = reach(obj,params,varargin)
% reach - computes the reachable set for linear systems
%
% Syntax:  
%    R = reach(obj,params)
%    R = reach(obj,params,options)
%    [R,res] = reach(obj,params,spec)
%    [R,res] = reach(obj,params,options,spec)
%
% Inputs:
%    obj - continuous system object
%    params - model parameters
%    options - options for the computation of reachable sets
%    spec - object of class specification 
%
% Outputs:
%    R - object of class reachSet storing the reachable set
%    res - true/false whether specifications are satisfied
%
% Example: 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author:        Mark Wetzlinger
% Written:       26-June-2019
% Last update:   08-Oct-2019
%                23-April-2020 (added params)
% Last revision: ---


%------------- BEGIN CODE --------------

    % parse input arguments
    spec = [];
    if nargin == 2
        options.linAlg = 'adaptive'; 
    elseif nargin == 3
        if isa(varargin{1},'specification')
            spec = varargin{1};
            options.linAlg = 'adaptive';
        else
            options = varargin{1};
        end
    else
        options = varargin{1};
        spec = varargin{2};
    end
    

    % options preprocessing
    options = validateOptions(obj,mfilename,params,options);
    
    specLogic = [];
    if ~isempty(spec)
        [spec,specLogic] = splitLogic(spec);
        if ~isempty(spec)
    	    options.specification = spec;
        end
    end

    % decide which reach function to execute by options.linAlg
    if strcmp(options.linAlg,'adaptive')
        [timeInt,timePoint,res] = reach_adaptive(obj, options);
    else
        % all below, const. time step sizes
        if strcmp(options.linAlg,'standard')
            [timeInt,timePoint,res] = reach_standard(obj, options);
        elseif strcmp(options.linAlg,'wrapping-free')
            [timeInt,timePoint,res] = reach_wrappingfree(obj, options);
        elseif strcmp(options.linAlg,'fromStart')
            [timeInt,timePoint,res] = reach_fromStart(obj, options);
        elseif strcmp(options.linAlg,'decomp')
            [timeInt,timePoint,res] = reach_decomp(obj, options);
        elseif strcmp(options.linAlg,'krylov')
            [timeInt,timePoint,res] = reach_krylov(obj, options);
        end
        % error vector (initial set: no error; error not computed -> NaN)
        timePoint.error = [0; NaN(length(timePoint.set)-1,1)];
        timeInt.error = NaN(length(timeInt.set),1);
    end

    % create object of class reachSet
    R = reachSet.initReachSet(timePoint,timeInt);

    % check temporal logic specifications
    if res && ~isempty(specLogic)
        res = check(specLogic,R);
    end
end

%------------- END OF CODE --------------