% This code creates Figure 2 and 3
% plot simulation results with varying (r, gamma)
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'

Fig_num = 3; % choose which Figure to replicate (2 or 3)
% figName_save = 'Fig2_OA_r_gamma_ss_Collapsed.png';
figName_save = 'Fig3_OA_r_gamma_ss_noCollapse.png';

%% set model parameters
% logistic growth (pure compensation)
K = 1 ;         % carrying capacity
F = @(r,x) (r.*x.*(1-x./K)); % growth function

% unit cost of effort
if Fig_num ==2 % case when steady-state stock "collapsed"
    c = 0.1;
    fprintf('Program running to generate Figure 2 \n')
elseif Fig_num == 3 % case when steady-state stock "not collapsed"
    c = 0.3;
    fprintf('Program running to generate Figure 3 \n')
else
    fprintf('\n Fig_num out of range. Check user input.\n')
    return
end

% other parameters
p = 1 ;         % price
q = 1;          % catchability
Emin = 0;       % minimum effort
E0 = 0.1;       % initial effort


% range of intrinsic growth rate: R = [0.05, 1]
% range of adjustment speed: G = [0.05, 5]
[R, G] = meshgrid(0.05:0.005:1,0.05:0.01:5);
[m, n] = size(R);
R = R(:); G = G(:); % vectorize the parameter

%% simulation
x_ss = min(K, c/(p*q)); % steady-state stock
fprintf('Steady-state stock x_ss = %.2f\n',x_ss)

E_ss = F(R,x_ss)./(q.*x_ss); % equilibrium effort (depends on R)
H_ss = q.*E_ss.*x_ss; % equilibrium harvest

Hmax = zeros(size(G)); % historic max catch (along the path)
Hmin = zeros(size(G)); % historic min catch (along the path)

for i = 1:length(R)
    r = R(i); % intrinsic growth rate
    gamma = G(i); % speed of adjustment
    % simulate path to get max and min catch
    [h_max,imax,h_min,~] = OA_sim(r,K,c,p,q,Emin,E0,gamma);
    Hmax(i) = h_max;
    Hmin(i) = h_min;
    
    if (mod(i,5000) == 0 || i == length(R))
        fprintf(' step i = %d/%d .. completed \n',i, length(R))
    end
    
end

R = reshape(R,m,n);
G = reshape(G,m,n);
H_ss = reshape(H_ss,m,n);
Hmax = reshape(Hmax,m,n);
Hmin = reshape(Hmin,m,n);

%% Create labels to indicate performance of the 10%-rule in [R,G] space
% tag1 = 1 if steady-state harvest <= 10% of max Catch
% tag1 = 1 when 10%-rule label fishery as "collapsed"
tag1 = 1*(H_ss <= 0.1*Hmax);

% tag2 = 1 if steady-state harvest is above 10% max, but ...
% ... min Catch (non-steady-state) <= 10% of max Catch
% tag2 = 1 when 10%-rule label fishery as "collapsed" inconsistantly
tag2 = (1-tag1).*(Hmin <= 0.1*Hmax);

% tag3 = 1 if the path of harvest and steady-state ...
% ... never fall below 10% max Catch
% tag3 = 1 when 10%-rule label fishery as "never collapsed"
tag3 = 1.*(Hmin > 0.1*Hmax);

%% Set color code for results in [R,G] space
% color = 0 Blue "Correct"
% color = 1 Dark Red "False Positive/Negative"
% color = 2 Orange/Yellow "Inconsistent, depends on Time"

if Fig_num ==2 % case when steady-state stock "collapsed"
    color = 0*(tag1==1)+2*(tag2==1)+1*(tag3==1);
else % case when steady-state stock "not collapsed"
    color = 1*(tag1==1)+2*(tag2==1)+0*(tag3==1);
end

%% plot contour regions
figure('Position', [20 20 700 400])
hold on
[C, h] = contourf(R,G,color);
set(h,'LineColor','none')
colormap(lines(3))

xlabel('intrinsic growth rate, r','FontSize',12)
ylabel('speed of adjustment, \gamma','FontSize',12)
xlim([0.1 1]); ylim([0.1 5]);

str = sprintf('Inconsistent,\ndepends on time');
if Fig_num == 2
    text(0.2,3,0,'Correct','FontSize',12,'FontWeight','Bold','Color','w')
    text(0.8,0.3,1,'False Negative','FontSize',12,'FontWeight','Bold')
    text(0.5,1,2,str,'FontSize',12,'FontWeight','Bold')
else
    text(0.8,1,0,'Correct','FontSize',12,'FontWeight','Bold','Color','w')
    text(0.12,4.5,1,'False Positive','FontSize',12,'FontWeight','Bold')
    text(0.4,3,2,str,'FontSize',12,'FontWeight','Bold')
end
hold off

%% save figure =============================================
saveas(gcf,figName_save)