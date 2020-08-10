function [x_star,E_star,h_star] = OPT_Schaefer_sim(delta,c,p,q,r,K,Emax,Emin)
% compute steady-state of optimal-managed fishery with Schaefer function
% delta = discount rate
% c = unit cost of effort
% p = price
% q = catchability
% r = intrinsic growth rate
% K = carrying capacity

F = @(x) (r*x.*(1-x./K)); %logistic growth function

A = c./(p.*q.*K)+1-(delta./r); 
B = 8*delta.*c./(r.*p.*q.*K);

x_star = 0.25.*K.*(A+sqrt(A.^2+B)); % stock
E_star = max(Emin,min(Emax,F(x_star)./(q*x_star))); % effort
h_star = q.*E_star.*x_star; % harvest

end