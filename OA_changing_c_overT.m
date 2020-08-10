% This code creates Figure B2 and B3
% plot simulation results for cost changing over time.
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'
Fig_num = 'B2'; % choose which Figure to replicate ('B2' or 'B3')
figName_save = 'FigB2_OA_cost_down.png';
% figName_save = 'FigB3_OA_cost_up.png';

%% set model parameters
% logistic growth (pure compensation)
r = 0.5;        % intrinsic growth rate
K = 1 ;         % carrying capacity
F = @(x) (r*x.*(1-x./K)); % growth function

% other parameters
gamma = 1.5;    % speed of adjustment
p = 1 ;         % price
q = 1;          % catchability
Emin = 0;       % minimum effort
E0 = 0.1;       % initial effort

% unit cost of effort: c(t)
dt = 0.1; 
t0 = 0:dt:40;       % initial period
t1 = 40.1:dt:80;      % transition period
t2 = 80.1:dt:100;     % final period
t = [t0 t1 t2];
cost0 = 0.3+0*t0;        % initial period cost

if isequal(Fig_num,'B2') % cost decreases 0.1 in transition period
    cost2 = 0.1+0*t2;
    cost1 = interp1([40 80],[0.3 0.1],t1);
    cost = [cost0 cost1 cost2];
elseif isequal(Fig_num,'B3') % cost increases to 0.95 in transition period
    cost2 = 0.95+0*t2;
    cost1 = interp1([40 80],[0.3 0.95],t1);
    cost = [cost0 cost1 cost2];
else
    fprintf('\n Fig_num out of range. Check user input.\n')
    return
end

%% simulation
Xpath = zeros(1,length(t)); Xpath(1) = K; % stock
Epath = zeros(1,length(t)); Epath(1) = E0; % effort
for i = 2:length(t)
    c = cost(i-1);
    rent = (p*q*Xpath(i-1)-c)*Epath(i-1);
    Epath(i) = max(Emin,Epath(i-1)+gamma*rent*dt);    
    Xpath(i) = Xpath(i-1)+(F(Xpath(i-1))-q*Epath(i)*Xpath(i-1))*dt; 
end

Hpath = q*Epath.*Xpath; % harvest
[Hmax, imax] = max(Hpath); % max historic harvest
Hmin = min(Hpath(imax:end)); % min harvest (after observing max)

Hrate = 100*Hpath./Hmax; % harvest as a percentage to Hmax
clps = (Hrate <= 10); % indicate harvest < 10% Hmax
Xrate = 100*Xpath./K; % stock as a percentage of K

%% generate figure
% set title of plot
if isequal(Fig_num,'B2') % cost decreases in transition period
    tlt_a = '(a) Catch comparing to historical max - cost decrease';
    tlt_b = '(b) Stock comparing to carrying capacity - cost decrease';
else % cost increases in transition period
    tlt_a = '(a) Catch comparing to historical max - cost increase';
    tlt_b = '(b) Stock comparing to carrying capacity - cost increase';
end


figure('Position',[0 0 900 600]);
subplot(2,1,1) % panel (a)
hold on
plot(t,Hrate,'k','LineWidth',2)
h10 = line([0,100],[10,10],'Color','k','LineWidth',1.5,'LineStyle',':');
line([40,40],[0 100],'Color',0.5*[1 1 1],'LineWidth',1)
line([80,80],[0 100],'Color',0.5*[1 1 1],'LineWidth',1)
title(tlt_a)
xlabel('Time'); ylabel('% of max catch');
xlim([0 100]); ylim([0 100]);
lgd = legend(h10,'10% threshold (catch)','Location','northeast');
lgd.EdgeColor = 'none';
hold off

subplot(2,1,2) % panel (b)
hold on
Xrate1m = Xrate; Xrate1m(clps~=0)=nan;
h1m = plot(t,Xrate1m,'b','LineWidth',2.5,...
    'DisplayName','when catch above 10% of maxCatch');
Xrate1n = Xrate; Xrate1n(clps==0)=nan; Xrate1n(1:imax)=nan;
h1n = plot(t,Xrate1n,'r-.','LineWidth',2,...
    'DisplayName','when catch below 10% of maxCatch');
h10 = line([0,100],[10,10],'Color','k','LineWidth',1.5,'LineStyle',':',...
    'DisplayName','10% threshold (stock)');
line([40,40],[0 100],'Color',0.5*[1 1 1],'LineWidth',1)
line([80,80],[0 100],'Color',0.5*[1 1 1],'LineWidth',1)
title(tlt_b)
xlabel('Time'); ylabel('% of carrying capacity');
xlim([0 100]); ylim([0 100]);
lgd = legend([h1m,h1n,h10],'Location','best');
lgd.EdgeColor = 'none';
hold off

%% manually add text to panel (a)
% gtext(sprintf('Initial period\n - correct negatives'))
% gtext('Transition period')
% gtext(sprintf('Final period\n - false negatives/positives'))
%% save figure =============================================
saveas(gcf,figName_save)