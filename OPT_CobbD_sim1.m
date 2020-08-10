function [x_star,h_star,hmax] = OPT_CobbD_sim1(delta,c,p,q,r,K,x0)
% compute equilibrium of optimal-managed fishery with Cobb-Douglas function
% Cobb-Douglas function: H = q*(E^0.5)*x
% delta = discount rate
% c = unit cost of effort
% p = price
% q = catchability
% r = intrinsic growth rate
% K = carrying capacity
% x0 = initial stock
xT = 0.3*K; % set stock level for end of simulation

F = @(x) (r*x.*(1-x./K)); % logistic growth function
dF = @(x) (r.*(1-2.*x./K)); % dF/dx

T = 100; dt = 0.01; t = 0:dt:T; % time horizon

% solve the system of ODEs to get the saddle path
h0 = 0;
bvpode = @(t,Y) [F(Y(1))-Y(2); % xdot
    -1/Y(1)*(Y(2)^2-(r+delta)*Y(1)*Y(2)...
    - p*(q^2)*(Y(1)^3)/(2*c)*(dF(Y(1))-delta))]; % hdot
bvpbc = @(Xa,Xb) [Xa(1)-x0; Xb(1)-xT];

solinit = bvpinit(linspace(0,T,1000),[x0 h0]);
sol = bvp4c(bvpode, bvpbc, solinit);
Opt_path = deval(sol,t);

Xpath = Opt_path(1,:); % optimal stock path
Hpath = Opt_path(2,:); % optimal harvest path

h_star = Hpath(floor(0.8*length(t))); % steady-state harvest
x_star = Xpath(floor(0.8*length(t)));  % steady-state stock
hmax = max(Hpath); % max catch

end