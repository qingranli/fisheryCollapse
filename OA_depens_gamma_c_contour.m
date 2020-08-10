% This code creates Figure 5
% plot simulation results with varying (c, gamma)
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'

figName_save = 'Fig5_OA_depens_gamma_c_colormap.png';

%% set model parameters
% depensatory growth: critical depensation
K = 1 ;         % carrying capacity
eta = 1;
K0 = 0.05*K;
F = @(x) eta*(x-K0).*(K-x).*x; % growth function

% other parameters
p = 1 ;         % price
q = 1;          % catchability
Emin = 0;       % minimum effort
E0 = 0.1;       % initial effort

% range of unit cost of effort: C = [0.01, 0.5]
% range of adjustment speed: G = [0.3, 5]
[C, G] = meshgrid(0.01:0.01:0.5,0.3:0.01:5);
[m, n] = size(C);
C = C(:); G = G(:); % vectorize the parameter

%% simulation
X_ss = zeros(size(G)); % equilibrium stock
E_ss = zeros(size(G)); % equilibrium effort
H_ss = zeros(size(G)); % equilibrium harvest

H0 = zeros(size(G)); % level of catch when stock falls below K0
Hmax = zeros(size(G)); % historic max catch

dt = 0.001; t = 0:dt:100;

for j = 1:length(C)
    cost = C(j); % unit cost of effort
    gamma = G(j); % speed of adjustment
    
    % approaching path to steady state simulation
    Xpath = zeros(1,length(t)); Xpath(1) = K;
    Epath = zeros(1,length(t)); Epath(1) = E0;
    
    for i = 2:length(t)
        rent = (p*q*Xpath(i-1)-cost)*Epath(i-1);
        Epath(i) = max(Emin,Epath(i-1)+gamma*rent*dt); 
        Xpath(i) = Xpath(i-1)+(F(Xpath(i-1))-q*Epath(i)*Xpath(i-1))*dt; 
    end
    Hpath = q*Epath.*Xpath;
    X_ss(j) = Xpath(end); E_ss(j) = Epath(end); 
    H_ss(j) = Hpath(end);
    
    [Hmax(j), imax] = max(Hpath); % max historic harvest 
    
    trap = (Xpath <= K0); % index of years when stock level falls below K0
    if sum(trap) >= 1
        H0(j) = Hpath(find(Hpath.*trap,1));
    else
        H0(j) = -999; % set default if stock never falls below K0
    end
    
    if (mod(j,1000) == 0 || j == length(G))
        fprintf(' step i = %d/%d .. completed \n',j, length(G))
    end
end

C = reshape(C,m,n);
G = reshape(G,m,n);
H_ss = reshape(H_ss,m,n);
Hmax = reshape(Hmax,m,n);
H0 = reshape(H0,m,n);

%% plot colored contours
H0_plot = H0; H0_plot(H0 < 0) = nan;

figure('Position', [20 20 700 500])
[c2,s2] = contourf(C,G,100*H0_plot./Hmax);
v = [2 4 6 8 10 12 14 16];
clabel(c2,s2,v,'FontWeight','bold')
xlabel('cost of effort, c','FontSize',12)
ylabel('speed of adjustment, \gamma','FontSize',12)
zlabel('percentage of H_{max}')
colorbar

%% save figure =============================================
saveas(gcf,figName_save)