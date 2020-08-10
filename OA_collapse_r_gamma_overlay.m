% This code creates Figure 4 and Figure B1
% plot simulation results with varying (r, gamma)
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'

Fig_num = 4; % choose which Figure to replicate (4 or 'B1')
figName_save = 'Fig4_OA_r_gamma_overlay_ss3.png';
% figName_save = 'FigB1_OA_r_gamma_overlay_ss5.png';

%% set model parameters
% logistic growth (pure compensation)
K = 1 ;         % carrying capacity
F = @(r,x) (r.*x.*(1-x./K)); % growth function

% unit cost of effort
c_low = 0.1;
if isequal(Fig_num,4) % case when steady-state stock "collapsed"
    c_high = 0.3;
    fprintf('Program running to generate Figure 4 \n')
elseif isequal(Fig_num,'B1') % case when steady-state stock "not collapsed"
    c_high = 0.5;
    fprintf('Program running to generate Figure B1 \n')
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

%% simulation (low steady-state stock)
c = c_low;
x_ss_low = min(K, c/(p*q)); % low steady-state stock
fprintf('Steady-state stock (low) = %.2f\n',x_ss_low)

E_ss = F(R,x_ss_low)./(q.*x_ss_low); % equilibrium effort (depends on R)
H_ss = q.*E_ss.*x_ss_low; % equilibrium harvest

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

H_ss = reshape(H_ss,m,n);
Hmax = reshape(Hmax,m,n);
Hmin = reshape(Hmin,m,n);

% tag1 = 1 if steady-state harvest <= 10% of max Catch
% tag1 = 1 when 10%-rule label fishery as "collapsed"
tag1 = 1*(H_ss <= 0.1*Hmax);
tagCorrect_low = tag1;

%% simulation (high steady-state stock)
c = c_high;
x_ss_hi = min(K, c/(p*q)); % high steady-state stock
fprintf('Steady-state stock (high) = %.2f\n',x_ss_hi)

E_ss = F(R,x_ss_hi)./(q.*x_ss_hi); % equilibrium effort (depends on R)
H_ss = q.*E_ss.*x_ss_hi; % equilibrium harvest

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

R = reshape(R,m,n); G = reshape(G,m,n);
H_ss = reshape(H_ss,m,n);
Hmax = reshape(Hmax,m,n);
Hmin = reshape(Hmin,m,n);

% tag3 = 1 if the path of harvest and steady-state ...
% ... never fall below 10% max Catch
% tag3 = 1 when 10%-rule label fishery as "never collapsed"
tag3 = 1.*(Hmin > 0.1*Hmax);
tagCorrect_high = tag3;

%% plot overlaying regions when 10%-rule is correct 
color_low = [0 0.4510  0.7412];
color_hi = [0.4706  0.6706 0.1882];
sz = 12; % size of point

figure('Position', [20 20 696 400])
hold on
h_low = scatter(R(tagCorrect_low==1),G(tagCorrect_low==1),sz,...
    color_low,'square','filled');
h_hi = scatter(R(tagCorrect_high==1),G(tagCorrect_high==1),sz,...
    color_hi,'square','filled');
h_hi.MarkerFaceAlpha = 0.15;

xlabel('intrinsic growth rate, r','FontSize',12)
ylabel('speed of adjustment, \gamma','FontSize',12)
xlim([0.1 1]); ylim([0.1 5]);

str_low = sprintf('Correct prediction when x_{ss} = %.1f',x_ss_low);
str_hi = sprintf('Correct prediction when x_{ss} = %.1f',x_ss_hi);
text(0.11,4.5,str_low,'FontSize',12,'FontWeight','Bold','Color','w')
text(0.5,0.6,str_hi,'FontSize',12,'FontWeight','Bold')
hold off

%% save figure =============================================
saveas(gcf,figName_save)