function han = plot(probZ,varargin)
% plot - plots a projection of a probabilistic zonotope
%
% Syntax:  
%    han = plot(probZ)
%    han = plot(probZ,dims)
%    han = plot(probZ,dims,type)
%
% Inputs:
%    probZ - probZonotope object
%    dims - (optional) dimensions for projection
%    type - (optional) plot settings (LineSpec and Name-Value pairs)
%           additional Name-Value pairs:
%               <'m',m> - m-sigma value (default: probZ.gamma)
%
% Outputs:
%    han - handle to the graphics object
%
% Example:
%    Z1 = [10 1 -2; 0 1 1];
%    Z2 = [0.6 1.2; 0.6 -1.2];
%    probZ = probZonotope(Z1,Z2);
%    plot(probZ,[1,2],'FaceColor','red');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author:       Matthias Althoff
% Written:      03-August-2007
% Last update:  17-July-2020
%               25-May-2022 (TL: 1D Plotting)
% Last revision: ---

%------------- BEGIN CODE --------------

% default values
dims = setDefaultValues({[1,2]},varargin);
m = probZ.gamma;

% check input arguments
inputArgsCheck({{probZ,'att','probZonotope'};
                {dims,'att','numeric',{'nonempty','integer','positive','vector'}}});

% parse plot options
NVpairs = readPlotOptions(varargin(2:end),'surf');
[NVpairs,m] = readNameValuePair(NVpairs,'m','isscalar',m);
% readout 'FaceColor' to decide plot/fill call where necessary
[~,facecolor] = readNameValuePair(NVpairs,'FaceColor');

% one-dimensional case
if length(dims) == 1
    probZ = project(probZ, dims);
    probZ = [1;0] * probZ;
    dims = [1,2];
end

%compute enclosing probability
eP = enclosingProbability(probZ,m,dims);

%plot and output the handle
if isempty(facecolor) || strcmp(facecolor,'none')
    han = mesh(eP.X,eP.Y,eP.P,NVpairs{:});
else
    han = surf(eP.X,eP.Y,eP.P,NVpairs{:});
end

if nargout == 0
    clear han;
end

%------------- END OF CODE --------------