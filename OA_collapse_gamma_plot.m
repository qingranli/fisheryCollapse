% This code creates Figure 1
% plot simulation results for two cases (low vs. high gamma)
clear; close all;
% clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'
figName_save = 'Fig1_OA_gamma_high_vs_low.png';

%% set model parameters
% logistic growth (pure compensation)
r = 0.5;        % intrinsic growth rate
K = 1 ;         % carrying capacity
F = @(x) (r*x.*(1-x./K)); % growth function

% other parameters
c = 0.1;        % unit cost of effort
p = 1 ;         % price
q = 1;          % catchability
Emin = 0;       % minimum effort
E0 = 0.1;       % initial effort

% speed of adjustment
gammaL = 0.2;   % low case
gammaH = 5;     % high case

%% simulation 
% steady-state (stock, effort, harvest)
x_ss = min(K,c/(p*q));
E_ss = F(x_ss)/(q*x_ss); 
h_ss = q*E_ss*x_ss; 
fprintf('steady-state: stock = %.2f, effort = %.2f, harvest = %.2f\n',...
    x_ss, E_ss, h_ss)

% MSY (stock, effort, harvest)
E_msy = r/2/q;
x_msy = K*(1-q*E_msy/r);
h_msy = q*E_msy*x_msy;
fprintf('MSY: stock = %.2f, effort = %.2f, harvest = %.2f\n',...
    x_msy, E_msy, h_msy)

% open access model simulation (gamma high)
[Hmax1,imax1,Hmin1,Hpath1,Xpath1,Epath1] = OA_sim(r,K,c,p,q,Emin,E0,gammaH);
Hrate1 = 100*Hpath1./Hmax1; % harvest as a percentage of Hmax
clps1 = (Hrate1 <= 10); % indicate harvest < 10% Hmax
Xrate1 = 100*Xpath1./K; % stock as a percentage of K


% open access model simulation (gamma low)
[Hmax2,imax2,Hmin2,Hpath2,Xpath2,Epath2] = OA_sim(r,K,c,p,q,Emin,E0,gammaL);
Hrate2 = 100*Hpath2./Hmax2; % harvest as a percentage to Hmax
clps2 = (Hrate2 <= 10); % indicate harvest < 10% Hmax
Xrate2 = 100*Xpath2./K; % stock as a percentage of K

%% generate figure
figure('Name','OA_collapse_gamma','Position',[0 0 700 800]);
T = length(Hrate1); t = linspace(0,1000,T); % set time horizon

subplot(4,1,1) % panel (a)
hold on
plot(t,Hrate1,'k','LineWidth',2)
h10 = line([0,100],[10,10],'Color','k','LineWidth',1.5,'LineStyle',':');
title('(a) Catch comparing to historical maximum - fast adjustment')
xlabel('Time'); ylabel('% of max catch');
xlim([0 100]); ylim([0 100]);
lgd = legend(h10,'10% threshold (catch)','Location','northeast');
lgd.EdgeColor = 'none';
hold off

subplot(4,1,2) % panel (b)
hold on
Xrate1m = Xrate1; Xrate1m(clps1~=0)=nan;
plot(t,Xrate1m,'b','LineWidth',2.5,...
    'DisplayName','when catch above 10% of maxCatch');
Xrate1n = Xrate1; Xrate1n(clps1==0)=nan; Xrate1n(1:imax1)=nan;
plot(t,Xrate1n,'r-.','LineWidth',2,...
    'DisplayName','when catch below 10% of maxCatch');
line([0,100],[10,10],'Color','k','LineWidth',1.5,'LineStyle',':',...
    'DisplayName','10% threshold (stock)');
title('(b) Stock comparing to carrying capacity - fast adjustment')
xlabel('Time'); ylabel('% of carrying capacity');
xlim([0 100]); ylim([0 100]);
lgd = legend('Location','northeast');
lgd.EdgeColor = 'none';
hold off

subplot(4,1,3) % panel (c)
hold on
plot(t,Hrate2,'k','LineWidth',2)
h10 = line([0,100],[10,10],'Color','k','LineWidth',1.5,'LineStyle',':');
title('(c) Catch comparing to historical maximum - slow adjustment')
xlabel('Time'); ylabel('% of max catch');
xlim([0 100]); ylim([0 100]);
lgd = legend(h10,'10% threshold (catch)','Location','northeast');
lgd.EdgeColor = 'none';
hold off

subplot(4,1,4) % panel (d)
hold on
Xrate2m = Xrate2; Xrate2m(clps2~=0)=nan;
plot(t,Xrate2m,'b','LineWidth',2.5,...
    'DisplayName','when catch above 10% of maxCatch');
Xrate2n = Xrate2; Xrate2n(clps2==0)=nan; Xrate2n(1:imax2)=nan;
plot(t,Xrate2n,'r-.','LineWidth',2,...
    'DisplayName','when catch below 10% of maxCatch');
line([0,100],[10,10],'Color','k','LineWidth',1.5,'LineStyle',':',...
    'DisplayName','10% threshold (stock)');
title('(d) Stock comparing to carrying capacity - slow adjustment')
xlabel('Time'); ylabel('% of carrying capacity');
xlim([0 100]); ylim([0 100]);
lgd = legend('Location','northeast');
lgd.EdgeColor = 'none';
hold off

%% save figure =============================================
saveas(gcf,figName_save)