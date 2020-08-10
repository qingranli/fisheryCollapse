% This code creates Figure 8.
% Reed model simulation with Z ~ log-normal(mu,sigma)
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'
figName_save = 'Fig8_Reed_density2.png';

%% set model parameters
% logistic growth (pure compensation)
r = 0.5;        % intrinsic growth rate
K = 1 ;         % carrying capacity

% Beverton-Holt stock-recruitment
theta = 1.65; b = (theta-1)/K;
R = @(s) (theta*s./(1+b*s)); % recruitment
dR = @(s) (theta./((1+b*s).^2)); % derivative

% other parameters
delta = 0.05;   % discount rate
p = 1;         % price (comp market)
q = 1;          % catchability
Emax = 1;       % maximum effort
Emin = 0;       % minimum effort

c = 0.1;        % unit cost of effort
Cost = @(c,x) (c./(q*x)); % marginal cost of harvest

mz = 1;         % mean(Z)
vz_low = 0.04;  % variance(Z) low value
vz_high = 0.08; % variance(Z) high value

%% Compute optimal escape S_star 
syms s;
eq0 = dR(s)*(p-Cost(c,R(s)))/(p-Cost(c,s)) == 1+delta;
sol_S = vpasolve(eq0,s);
S_star = double(sol_S(sol_S >= 0));
H_star = max(0,R(S_star)-S_star);
fprintf('Reed model:\n optimal escape S* = %.2f, harvest H* = %.2f \n',S_star, H_star);

%% simulation with var(z) low
vz = vz_low;
fprintf('Simulation with var(Z) = %.2f\n',vz)
% Z ~ lognormal, i.e. log(Z) ~ Normal(mu,sigma)
mu = log(mz^2/sqrt(vz + mz^2)); 
sigma =sqrt(log(vz/(mz^2)+1));
% define log-normal distribution
pd_Z = makedist('Lognormal',mu,sigma);

% Simulate path of S, H, R 
maxIter = 5000; % number of simulation rounds
T = 100; % T years in each simulation

Spath = zeros(maxIter,T+1); % escape
Rpath = zeros(maxIter,T+1); % recruitment 
Hpath = zeros(maxIter,T+1); % optimal harvest

share_lowH = zeros(maxIter,1); % share of catch falling below 10% maxCatch

rng('default')  % For reproducibility
for m = 1:maxIter
    [St,Rt,Ht] = Reed_logN_sim(pd_Z,T,theta,S_star);    
    Spath(m,:) = St; % escape
    Rpath(m,:) = Rt; % recruitment
    Hpath(m,:) = Ht; % optimal harvest 
    
    % share of time when H(t)<0.1Hmax
    harv = Ht(2:end);
    [Hmax, imax] = max(harv);
    share_lowH(m) = sum(harv(imax:end) < 0.1*Hmax)/T; 
    
    if (mod(m,500) == 0 || m == maxIter)
        fprintf(' iteration i = %d/%d .. completed \n',m, maxIter)
    end
end % end for m

share_lowH_low = share_lowH; % keep result
[f_low,share_low] = ksdensity(share_lowH_low); % Kernel smoothing density estimate 

%% simulation with var(z) high
vz = vz_high;
fprintf('Simulation with var(Z) = %.2f\n',vz)
% Z ~ lognormal, i.e. log(Z) ~ Normal(mu,sigma)
mu = log(mz^2/sqrt(vz + mz^2)); 
sigma =sqrt(log(vz/(mz^2)+1));
% define log-normal distribution
pd_Z = makedist('Lognormal',mu,sigma);

% Simulate path of S, H, R 
maxIter = 5000; % number of simulation rounds
T = 100; % T years in each simulation

Spath = zeros(maxIter,T+1); % escape
Rpath = zeros(maxIter,T+1); % recruitment 
Hpath = zeros(maxIter,T+1); % optimal harvest

share_lowH = zeros(maxIter,1); % share of catch falling below 10% maxCatch

rng('default')  % For reproducibility
for m = 1:maxIter
    [St,Rt,Ht] = Reed_logN_sim(pd_Z,T,theta,S_star);    
    Spath(m,:) = St; % escape
    Rpath(m,:) = Rt; % recruitment
    Hpath(m,:) = Ht; % optimal harvest 
    
    % share of time when H(t)<0.1Hmax
    harv = Ht(2:end);
    [Hmax, imax] = max(harv);
    share_lowH(m) = sum(harv(imax:end) < 0.1*Hmax)/T; 
    
    if (mod(m,500) == 0 || m == maxIter)
        fprintf(' iteration i = %d/%d .. completed \n',m, maxIter)
    end
end % end for m

share_lowH_high = share_lowH; % keep result
[f_high,share_high] = ksdensity(share_lowH_high); % Kernel smoothing density estimate 

%% generate figure
figure('Position',[50 50 700 500])
hold on
plot(share_low,f_low,'LineWidth',2.5,'DisplayName','var(Z) = 0.04')
plot(share_high,f_high,'-.','LineWidth',2.5,'DisplayName','var(Z) = 0.08')
xlabel('Share of catch falling below 10% historical max','FontSize',12)
ylabel('probability density','FontSize',12)
xlim([0 1])
lgd = legend('show','Location','best','FontSize',12);
title(lgd,'Z ~ log-normal, mean(Z)=1','FontSize',11)
hold off

%% save figure =============================================
saveas(gcf,figName_save)