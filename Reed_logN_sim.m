function [St,Rt,Ht] = Reed_logN_sim(pd_Z,T,theta,S_star)
% simulate Reed model given the following:
% pd_Z = distribution of Z (defined by the 'makedist' function)
% T = number of time periods for a simulated trajectory
% a,b = parameter of the Beverton-Holt recruitment function
% S_star = optimal escape level

R = @(s) (theta*s./(1+(theta-1)*s)); % Beverton-Holt recruitment

% get boundary quantiles for Z_trim
z_low = icdf(pd_Z,0.05); % 5-percent quantile
z_high = icdf(pd_Z,0.95);% 95-percent quantile

% stochastic component Z(t)
Z_sample = random(pd_Z,2*T,1); % 2*T random draws
Z_trim = Z_sample((Z_sample >= z_low) & (Z_sample <= z_high));
Z_use = Z_trim(1:T);

% simulate trajectory of escape, recruitment, optiaml harvest
St = zeros(1,T+1); St(1) = S_star; % initial stock = S*
Rt = zeros(1,T+1); Rt(1) = S_star; % inital recruitment = S*
Ht = zeros(1,T+1);  % initial harvest = 0

for t = 2:(T+1)
    % recruitment
    Rt(t) = Z_use(t-1)*R(St(t-1));
    % optimal harvest
    Ht(t) = max(0, Rt(t)-S_star);
    % escape
    St(t) = Rt(t)-Ht(t);
end

end