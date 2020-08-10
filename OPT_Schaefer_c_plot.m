% This code creates Figure 6
% plot simulation results for a range of cost parameters under ...
% ..the optimal management model with Schaefer production function
clear; close all;
% clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'
figName_save = 'Fig6_OPT_Schaefer_cost_change.png';

%% set model parameters
% logistic growth (pure compensation)
r = 0.5;        % intrinsic growth rate
K = 1 ;         % carrying capacity
F = @(x) (r*x.*(1-x./K)); % growth function

% other parameters
delta = 0.05;   % discount rate
p = 1;          % price 
q = 1;          % catchability
Emax = 1;       % maximum effort
Emin = 0;       % minimum effort

% unit cost of effort range = [0.01 1]
c = 0.01:0.01:1;

%% simulation
% steady-state
[x_star,E_star,H_star] = OPT_Schaefer_sim(delta,c,p,q,r,K,Emax,Emin);

Hmax = q*Emax*K; % max catch
Hrate = 100*H_star./Hmax; % equilibrium catch as a percentage of historical max
Xrate = 100*x_star./K; % equilibrium stock as a percentage of K

%% generate Figure
figure('Position',[0 0 700 600]);
subplot(2,1,1) % panel (a)
plot(c,Hrate,'LineWidth',2,'DisplayName','Equilibrium catch')
line([c(1) c(end)],[10 10],'LineWidth',1.5,'DisplayName','10% threshold',...
    'Color','r','LineStyle',':')
title('(a) Ratio of equilibrium catch to historic max decreases with cost','FontSize',12)
xlabel('unit cost of effort, c','FontSize',12)
ylabel('% of max catch','FontSize',12)
legend('show','Location','northeast','FontSize',12,'EdgeColor','none')
xlim([0.01 1]); ylim([0 20])


subplot(2,1,2) % panel (b)
plot(c,Xrate,'k-.','LineWidth',2,'DisplayName','Equilibrium stock')
title('(b) Equilibrium stock increases with cost','FontSize',12)
xlabel('unit cost of effort, c','FontSize',12)
ylabel('% of carrying capacity','FontSize',12)
legend('show','Location','southeast','FontSize',12,'EdgeColor','none')
xlim([0.01 1]); ylim([0 100])

%% save figure =============================================
saveas(gcf,figName_save)