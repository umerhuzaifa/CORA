function V = vertices_(Z,alg,varargin)
% vertices_ - returns potential vertices of a zonotope
%    WARNING: Do not use this function for high-order zonotopes as the
%    computational complexity grows exponentially!
%
% Syntax:
%    V = vertices_(Z)
%    V = vertices_(Z,alg)
%
% Inputs:
%    Z - zonotope object
%    alg - algorithm used
%           - 'convHull' (default)
%           - 'iterate'
%           - 'polytope'
%
% Outputs:
%    V - matrix
%
% Example:
%    Z = zonotope([1;-1],[1 3 -2 1 0; 0 2 1 -2 1]);
%    V = vertices(Z)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: interval,  polytope

% Author:       Matthias Althoff, Niklas Kochdumper
% Written:      14-September-2006 
% Last update:  30-January-2008
%               23-June-2009
%               24-June-2010
%               11-July-2012
%               30-July-2016
%               28-October-2019 (NK, added new algorithm)
% Last revision:27-March-2023 (MW, rename vertices_)

%------------- BEGIN CODE --------------

    % different cases for different dimensions
    n = dim(Z);
    
    if n == 1

        % compute the two vertices for one-dimensional case
        c = center(Z);
        temp = sum(abs(generators(Z)),2);
        V = [c - temp,c + temp];

    elseif n == 2

        % use function "polygon" for two dimensional zonotopes -> faster
        V = polygon(Z);

    else
        
        % apply the selected algorithm
        if strcmp(alg,'iterate')
            V = verticesIterate(Z);
        elseif strcmp(alg,'polytope')
            V = verticesPolytope(Z);
        else
            V = verticesConvHull(Z);
        end
    end

    % remove duplicates
    V = unique(V','rows','stable')';
    
end



% Auxiliary Functions -----------------------------------------------------

function V = verticesPolytope(Z)

    P = mptPolytope(Z);
    V = vertices(P);

end

function V = verticesConvHull(Z)

    % first vertex is the center of the zonotope
    V = center(Z);
    n = dim(Z);
    nrGens = size(generators(Z),2);

    % generate further potential vertices in the loop
    for iVertex = 1:nrGens

        translation = Z.Z(:,iVertex+1)*ones(1,length(V(1,:)));
        V = [V+translation,V-translation];

        % remove inner points
        if iVertex > n
            try
                K = convhulln(V');
                indices = unique(K);
                V = V(:,indices);
            catch
                disp('Convex hull failed')
                V = V;
            end
        else
            V = V;
        end
    end
end

function V = verticesIterate(Z)

    % delete aligned and all-zero generators
    Z = deleteAligned(Z);
    Z = deleteZeros(Z);

    % extract object data
    G = generators(Z);
    c = center(Z);
    n = size(G,1);
    
    % catch the case where the zonotope is not full-dimensional
    if size(G,2) < n
        V = verticesIterateSVG(Z);
        return;
    end

    % compute vertices of the parallelotope
    vert = vertices_(interval(-ones(n,1),ones(n,1)));  
    V = c + G(:,1:n)*vert;
    
    % compute halfspaces of the parallelotope
    [poly,~,isDeg] = mptPolytope(zonotope([c,G(:,1:n)]));
    if isDeg
        V = verticesIterateSVG(Z);
        return;
    else
        A = poly.P.A;
    end
    
    % loop over all remaining generators 
    for i = n+1:size(G,2)
       
        % extract current generator
        g = G(:,i);
        
        % compute potential vertices
        V = [V+g,V-g];
        
        % compute new halfspaces
        if n == 2
            temp = ndimCross(g);
            temp = temp/norm(temp);
            Anew = [temp';-temp'];
        else
            comb = combinator(i-1,n-2,'c');
            Anew = zeros(2*size(comb,1),n);
            counter = 1;

            for j = 1:size(comb,1)
                temp = ndimCross([G(:,comb(j,:)),g]);
                temp = temp/norm(temp);
                Anew(counter,:) = temp';
                Anew(counter+1,:) = -temp';
                counter = counter + 2;
            end
        end
        
        A = [A;Anew];
        
        % compute halfspace offsets
        b = max(A*V,[],2);
        
        % remove redundant vertices
        temp = max(A*V-b,[],1); 
        nV = numVertices(i,n);
        [~,ind] = sort(temp,'descend');
        V = V(:,ind(1:nV));
        
    end

end

function [res,suc] = verticesIterateSVG(Z)
% compute vertices for the case that zonotope is not full-dimensional

    suc = true;
    res = [];

    % extract object data
    G = generators(Z);
    c = center(Z);
    n = dim(Z);

    % singular value decomposition
    [S,V,~] = svd(G);
    
    if size(V,2) < size(G,1)
       V = [V,zeros(n,n-size(V,2))]; 
    end

    % state space transformation
    Z_ = S'*[c,G];

    % remove dimensions with all zeros
    ind = find(diag(V) <= 1e-12);
    ind_ = setdiff(1:size(V,1),ind);

    if ~isempty(ind)
        % compute vertices in transformed space
        V = vertices(zonotope(Z_(ind_,:)));

        % transform back to original space
        res = S*[V;zeros(length(ind),size(V,2))];
    else
        suc = false;
    end 
end

function res = numVertices(m,n)
% compute number of zonotope vertices

    res = 0;
    for i = 0:n-1
        res = res + nchoosek(m-1,i); 
    end
    res = 2*res;
end

%------------- END OF CODE --------------