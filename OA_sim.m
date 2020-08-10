function [Hmax,imax,Hmin,Hpath,Xpath,Epath] = OA_sim(r,K,c,p,q,Emin,E0,gamma)
% open access model (with logistic growth) ==========
% r = intrinsic growth rate in logistic growth model
% K = carrying capacity
% c = unit cost of effort
% p = price
% q = catchability
% Emin = minimum effort, E0 = initial effort
F = @(r,x) (r*x.*(1-x./K)); % growth function

% trajectory to equilibrium (when rent ~= 0)
dt = 0.1; t= 0:dt:1000; % set continuous time horizon
Xpath = zeros(1,length(t)); Xpath(1) = K; % stock
Epath = zeros(1,length(t)); Epath(1) = E0; % effort

for i = 2:length(t)
    rent = (p*q*Xpath(i-1)-c)*Epath(i-1);
    Epath(i) = max(Emin,Epath(i-1)+gamma*rent*dt);    
    Xpath(i) = Xpath(i-1)+(F(r,Xpath(i-1))-q*Epath(i)*Xpath(i-1))*dt; 
end
% rent = (p*q*Xpath(end)-c)*Epath(end);

Hpath = q*Epath.*Xpath; % harvest
[Hmax, imax] = max(Hpath); % max historic harvest
Hmin = min(Hpath(imax:end)); % min harvest (after observing max)

end