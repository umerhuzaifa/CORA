function res = example_nonlinearDA_reach_08_SMIBswing_adaptive()
% example_nonlinearDA_reach_08_SMIBswing_adaptive - example of nonlinear
%    differential-algebraic reachability analysis
%
% Syntax:  
%    example_nonlinearDA_reach_08_SMIBswing_adaptive()
%
% Inputs:
%    -
%
% Outputs:
%    res - true/false

% Author:       Mark Wetzlinger
% Written:      30-August-2021
% Last update:  ---
% Last revision:---


%------------- BEGIN CODE --------------

% SMIB system with 2 diff. variables and 4 alg. variables
dim_x = 2;
dim_y = 4;

[P,I,x0,y0] = aux2_modelParameters();


% Parameters --------------------------------------------------------------

% initial set
params.x0 = x0;
Bound_x = 0.8e-3*eye(2);
params.R0 = zonotope([params.x0,Bound_x]); % x0

% initial set (algebraic states)
params.y0guess = y0.';

% set of uncertain inputs
uTrans = 0;
Bound_u(1,1) = 0;                    % Uncertainty
params.U=zonotope([uTrans,Bound_u]); % Initial input state


% Reachability Settings ---------------------------------------------------

options.alg = 'lin-adaptive';
options.verbose = true;
options.tensorOrder = 2;


% System Dynamics ---------------------------------------------------------

% Normal mode
P.mode = 'normal';

dynFun = @(x,y,u) SMIBswing(x,y,u,P,I);
conFun = @(x,y,u) SMIBswing_con(x,y,u,P,I);

sys{1} = nonlinDASys('SMIBswing',dynFun,conFun);

% Fault mode
P.mode = 'fault';

dynFun = @(x,y,u) SMIBswing(x,y,u,P,I);
conFun = @(x,y,u) SMIBswing_con(x,y,u,P,I);

sys{2} = nonlinDASys('SMIBswingFault',dynFun,conFun);


% Reachability Analysis ---------------------------------------------------

tswitch = [0 0.01 0.02 0.23];
modes = {'normal','fault','normal'};
syshandles = {sys{1},sys{2},sys{1}};

% loop over all mode switches
for i = 1:length(modes)
    
    % update mode, initial and final time
    P.mode = modes{i};
    params.tStart = tswitch(i);
    params.tFinal = tswitch(i+1);
    
    % compute reachable set
    Rtemp = reach(syshandles{i}, params, options);
    
    if i == 1
        R = Rtemp;
    else
        R = add(R,Rtemp);
    end
    
    % update initial state
    params.R0 = Rtemp.timePoint.set{end};
end


% Simulation --------------------------------------------------------------

tswitch = [0 0.01 0.02 0.23];
modes = {'normal','fault','normal'};
syshandles = {sys{1},sys{2},sys{1}};

dim_x = 2;
dim_y = 4;

runs = 1;
Bound_x = 0.8e-3*eye(2);
params.R0  = zonotope([params.x0,Bound_x]);
params.u = center(params.U);

t = cell(runs,1); x = cell(runs,1);

% loop over all simulated trajectories
for r = 1:runs
    
    if r<=10
        params.x0 = randPoint(params.R0,1,'extreme');
    else
        params.x0 = randPoint(params.R0);
    end
    
    % loop over all mode switches
    for i=1:length(modes)
%         P.mode = modes{i};
%         options.mode = modes{i};
        params.tStart = tswitch(i);
        params.tFinal = tswitch(i+1);
        [t_new,x_new] = simulate(syshandles{i},params);
        t{r} = [t{r}; t_new]; x{r} = [x{r}; x_new];
        xFinal = x{r}(end,:)';
        params.x0 = xFinal(1:dim_x);
        params.y0 = xFinal(dim_x+1:dim_x+dim_y).';
    end
end

% write to simResult object
simRes = simResult(x,t);


% Visualization -----------------------------------------------------------

dim_x = [1 2];
figure; hold on; box on;

% plot reachable sets
useCORAcolors("CORA:contDynamics")
plot(R,dim_x,'DisplayName','Reachable set');

% plot initial set
plot(R(1).R0,dim_x,'DisplayName','Initial set');

% plot simulation results
plot(simRes,dim_x,'DisplayName','Simulations');

% axis labels
xlabel('$x_1$','interpreter','latex');
ylabel('$x_2$','interpreter','latex');
legend()


% examples completed
res = true;

end



% Auxiliary Functions -----------------------------------------------------

function [P,I,x0,y0] = aux2_modelParameters()
% defines the parameters for the model

    %  Example 13.2 p. 864
    P.M1        = 1/(15*pi);	% Tr???gheitskoeffizient
    P.D1        = 0.5;          % D???mpfungskoeffizient
    P.xd1       = 1/(1i*0.2);  	% d-Achsen transiente Reaktanz     
    P.omegaS    = 2*pi*50;

    % Network parameters
    P.xT        = 1*0.15;     % Reactance of the transformer at Bus 1
    P.xl1       = 1*0.5;      % Reactance of trasmission line 1
    P.xl2       = 1*0.93;     % Reactance of trasmission line 2

    % Resulting overall network reactance for normal and fault case
    %  Series and parallel computation  
    P.xs        = P.xT + 1/(1/P.xl1 + 1/P.xl2); % No fault
    P.xs3       = P.xT + P.xl1;                 % Fault in line 2
    % Fault sequence (This can be changed according to the needs)

    % Initial values for the Power Flow
    % Bus 1 is a PV-bus (connected to a generator)
    % Bus 2 is an infinite bus
    P.v1        = 1;           % Voltage at bus 1
    P.p1        = 0.9;         % Active power at bus 1
    P.v2        = 0.90081;     % Voltage at Infinite Bus := const
    P.theta2    = 0;           % Phase at Infinite Bus   := const

    % Compute initial values for the SMIB system
    options_fsolve = optimoptions('fsolve','Display','off'); % Turn off display

    % Use fsolve to get theta1 and q1
    % Phase angle and reactive power at bus 1 (Unknown for PV-bus)
    X0net       = fsolve(@(X) aux2_init_network(X,P),ones(2,1),options_fsolve);
    I.theta1    = X0net(1);
    I.Q1        = X0net(2);      

    I.P1        = 0.9;
    I.V1        = 1;

    % Use fsolve to get synchrous generator paramters
    X0gen       = fsolve(@(X) aux2_init_generator(X,P,I),ones(4,1),options_fsolve);
    % assignment of variables
    I.E1        = X0gen(3);        % q-axis transient voltage (diff. variable)
    I.Pm1       = X0gen(4);        % d-axis machine voltage (alg. varaible)

    x0 = [X0gen(1);X0gen(2)];
    y0 = [I.P1 I.Q1 I.theta1 I.V1];
end

function X0 = aux2_init_network(X,P)

    % Variables
    theta1 = X(1);
    q1     = X(2);

    % Power flow for SMIB transmission network
    X0=[P.v1*P.v2/P.xs*sin(theta1-P.theta2)-P.p1;... 
        P.v1*P.v1/P.xs-P.v1*P.v2/P.xs*cos(theta1-P.theta2)-q1;...
    ];
end

function X0 = aux2_init_generator(X,P,I)

    % Variables
    delta1  = X(1);
    omega1  = X(2);
    E1      = X(3);
    Pm1     = X(4);

    % Here insert the equations which describe the system
    X0=[  P.omegaS*(omega1);...
    (1/P.M1)*(Pm1-I.P1 - (P.D1*omega1));...
    I.P1 - (E1*I.V1*abs(P.xd1)*cos(angle(P.xd1)+delta1-I.theta1));...
    I.Q1  + (E1*I.V1*abs(P.xd1)*sin(angle(P.xd1)+delta1-I.theta1)) - (I.V1^2*abs(P.xd1)*sin(angle(P.xd1)));...
    ];
end

%------------- END OF CODE --------------
        