% This code creates Figure 7 and Figure B4
% plot simulation results for a range of cost parameters under ...
% ..the optimal management model with Cobb-Douglas production function
% Figure 7 uses Cobb-Douglas function: H = q*(E^0.5)*x
% Figure B1 uses Cobb-Douglas function: H = q*E*(x^0.5)
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'

Fig_num = 7; % choose which Figure to replicate (7 or 'B4')
figName_save = 'Fig7_OPT_CobbD_cost_change.png';
% figName_save = 'FigB4_OPT_CobbD_cost_change.png';

%% set model parameters
% logistic growth (pure compensation)
r = 0.5;        % intrinsic growth rate
K = 1 ;         % carrying capacity
F = @(x) (r*x.*(1-x./K)); % growth function
dF = @(x) (r.*(1-2.*x./K)); % dF/dx

% other parameters
delta = 0.05;   % discount rate
p = 1;          % price 
q = 1;          % catchability
Emax = 1;       % max effort

% unit cost of effort range = [0.01 1]
cRange = linspace(0.01,1,100);

%% simulation
x0 = K;         % set initial stock
H_star = zeros(size(cRange)); % equilibrium harvest
X_star = zeros(size(cRange)); % equilibrium stock
Hmax = zeros(size(cRange)); % historical max catch

for i = 1:length(cRange)
    c = cRange(i); % unit cost of effort
    
    % solve equilibrium harvest and stock, and historical max catch
    if isequal(Fig_num,7)
        [x_star,h_star,hmax] = OPT_CobbD_sim1(delta,c,p,q,r,K,x0);  
    elseif isequal(Fig_num,'B4')
        [x_star,h_star,hmax] = OPT_CobbD_sim2(delta,c,p,q,r,K,x0,Emax);  
    else
        fprintf('\n Fig_num out of range. Check user input.\n')
        return
    end
    
    X_star(i) = x_star;
    H_star(i) = h_star;    
    Hmax(i) = hmax;
    
   if (mod(i,10) == 0 || i== length(cRange))
       fprintf(' step i = %d/%d ..completed\n',i,length(cRange))
   end
end

Hrate = 100*H_star./Hmax; % equilibrium catch as a percentage of historical max
Xrate = 100*X_star./K;    % equilibrium stock as a percentage of K 

%% generate Figure
figure('Position',[0 0 700 600]);
subplot(2,1,1) % panel (a)
plot(cRange,Hrate,'LineWidth',2,'DisplayName','Equilibrium catch')
line([cRange(1) cRange(end)],[10 10],'LineWidth',1.5,'DisplayName','10% threshold',...
    'Color','r','LineStyle',':')
 if isequal(Fig_num,7)
     title('(a) Ratio of equilibrium catch to historic max increases with cost','FontSize',12)
 else
     title('(a) Ratio of equilibrium catch to historic max decreases with cost','FontSize',12)
 end
xlabel('unit cost of effort, c','FontSize',12)
ylabel('% of max catch','FontSize',12)
legend('show','Location','best','FontSize',12,'EdgeColor','none')
xlim([0.01 1])


subplot(2,1,2) % panel (b)
plot(cRange,Xrate,'k-.','LineWidth',2,'DisplayName','Equilibrium stock')
title('(b) Equilibrium stock increases with cost','FontSize',12)
xlabel('unit cost of effort, c','FontSize',12)
ylabel('% of carrying capacity','FontSize',12)
legend('show','Location','southeast','FontSize',12,'EdgeColor','none')
xlim([0.01 1]); ylim([0 100])

%% save figure =============================================
saveas(gcf,figName_save)