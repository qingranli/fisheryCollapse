% This code creates Figure B5.
% Reed model simulation with Z ~ log-normal(mu,sigma)
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'
figName_save = 'FigB5_Reed_paths.png';

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
vz = 0.08;      % variance(Z)

%% Compute optimal escape S_star 
syms s;
eq0 = dR(s)*(p-Cost(c,R(s)))/(p-Cost(c,s)) == 1+delta;
sol_S = vpasolve(eq0,s);
S_star = double(sol_S(sol_S >= 0));
H_star = max(0,R(S_star)-S_star);
fprintf('Reed model:\n optimal escape S* = %.2f, harvest H* = %.2f \n',S_star, H_star);

%% simulation (30 iterations)
% Z ~ lognormal, i.e. log(Z) ~ Normal(mu,sigma)
mu = log(mz^2/sqrt(vz + mz^2)); 
sigma =sqrt(log(vz/(mz^2)+1));
% define log-normal distribution
pd_Z = makedist('Lognormal',mu,sigma);

% Simulate path of S, H, R 
maxIter = 30; % number of simulation rounds
T = 100; % T years in each simulation

Spath = zeros(maxIter,T+1); % escape
Rpath = zeros(maxIter,T+1); % recruitment 
Hpath = zeros(maxIter,T+1); % optimal harvest

rng('default')  % For reproducibility
for m = 1:maxIter
    [St,Rt,Ht] = Reed_logN_sim(pd_Z,T,theta,S_star);    
    Spath(m,:) = St; % escape
    Rpath(m,:) = Rt; % recruitment
    Hpath(m,:) = Ht; % optimal harvest 
end % end for m

%% Plot simulation results
figure('Position',[10 10 800 900])
subplot(3,1,1)
hold on
for m = 1:maxIter
   h = plot(0:T,Spath(m,:),'k');
   h.Color(4) = 0.2;     
end
xlabel('time'); ylabel('Escape S(t)','FontSize',12);
xlim([1 T]); ylim([0 1])

subplot(3,1,2)
hold on
for m = 1:maxIter
   h = plot(0:T,Hpath(m,:),'b');
   h.Color(4) = 0.2;     
end
xlabel('time'); ylabel('Harvest H(t)','FontSize',12);
xlim([1 T]); ylim([0 0.5])


subplot(3,1,3)
hold on
for m = 1:maxIter
   h = plot(0:T,Rpath(m,:),'r');
   h.Color(4) = 0.2;     
end
xlabel('time'); ylabel('Recruitment R(t)','FontSize',12)
xlim([1 T]); ylim([0 1])
hold off

%% save figure =============================================
saveas(gcf,figName_save)