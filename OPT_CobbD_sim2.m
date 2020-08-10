function [x_star,h_star,hmax] = OPT_CobbD_sim2(delta,c,p,q,r,K,x0,Emax)
% compute equilibrium of optimal-managed fishery with Cobb-Douglas function
% Cobb-Douglas function: H = q*E*(x^0.5)
% delta = discount rate
% c = unit cost of effort
% p = price
% q = catchability
% r = intrinsic growth rate
% K = carrying capacity
% x0 = initial stock
% Emax = maximum effort

harv = @(E,x) (q.*E.*(x.^0.5)); % production function (Cobb-Douglas)
hmax = harv(Emax,x0);  % max historical catch

F = @(x) (r*x.*(1-x./K)); % logistic growth function
dF = @(x) (r.*(1-2.*x./K)); % dF/dx

T = 100; dt = 0.01; t = 0:dt:T; % time horizon
% solve equilibrium
syms x;
eq0 =  (c/(2*q*x^1.5))*F(x) == (delta-dF(x))*(p-(c/(q*x^0.5)));
sol_x = vpasolve(eq0,x);
x_star = double(sol_x(sol_x >= 0)); % steady-state stock
h_star = F(x_star);     % steady-state harvest

end