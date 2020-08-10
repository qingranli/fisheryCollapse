% This code creates Figure 9
% plot rebuilding plan results with varying (r, gamma)
clear; close all;
clc;

% cd 'C:\Users\NAMEX\Documents\Collapse_simulation'
figName_save = 'Fig9_OA_r_gamma_rebuild.png';

%% set model parameters
% logistic growth (pure compensation)
K = 1 ;         % carrying capacity
F = @(r,x) (r.*x.*(1-x./K)); % growth function

% other parameters
p = 1 ;         % price
q = 1;          % catchability
Emin = 0;       % minimum effort
E0 = 0.1;       % initial effort

c = 0.2;  % unit cost of effort -- NOTE PICKING NOT COLLAPSED TO SHOW REBUILD FROM OVERFISHED
x_ss =  min(K,c/(p*q)); % open access steady-state stock

Trebuild1 = 5; %target length of time for rebuilding (5 years)
Trebuild2 = 10; %target length of time for rebuilding (10 years)
Xtarget = 0.5; % target stock for rebuilding

% range of intrinsic growth rate: R
% range of adjustment speed: G 
[R, G] = meshgrid(0.1:0.01:1,0.1:0.1:5.1);
[m, n] = size(R);
R = R(:); G = G(:);  % vectorize the parameter

%% simulation with Trebuild = 5 years
Trebuild = Trebuild1;
fprintf('Simulation with %d-year rebuilding plan.\n',Trebuild)
Hmax = zeros(size(G)); % store historical max catch rate
Hrebuild = zeros(size(G)); % harvest rebuild
Rebuild = zeros(size(G)); % rebuild to target (=1), rebuild fails (=0)

myoption= optimset('Display','off','MaxFunEvals',1e+10,'TolX',1e-10,'MaxIter',1e+8);

for j = 1:length(R)
    r = R(j); % intrinsic growth rate
    gamma = G(j); % speed of adjustment
        
    % historical max catch of the open access path to equilibrium
    [h_max,~] = OA_sim(r,K,c,p,q,Emin,E0,gamma);
    Hmax(j) = h_max; % max historic harvest
    
    % solve for harvest that rebuilds stock to Xtarget by Trebuild
    fun = @(x)dist2Target(x,x_ss,Xtarget,Trebuild,r);
    h0 = 0; % initial estimate = 0
    [h,dist] = fmincon(fun,h0,[-1;1],[0;x_ss],[],[],[],[],[],myoption);
    Hrebuild(j) = h; % store h
    Rebuild(j) = -(dist > 1e-5)+1; % label for rebuild
    
    if (mod(j,1000) == 0 || j == length(R))
        fprintf(' step i = %d/%d .. completed \n',j, length(R))
    end     
end

Hratio1 = reshape(Hrebuild./Hmax,m,n); % ratio of Hrebuild/Hmax
Rebuild1 = reshape(Rebuild,m,n); % 0 = rebuild plan fails
clps1 = 1*(Hratio1 <= 0.1); % 1 = "collapse" in rebuild process

%% simulation with Trebuild = 10 years
Trebuild = Trebuild2;
fprintf('Simulation with %d-year rebuilding plan.\n',Trebuild)
Hmax = zeros(size(G)); % store historical max catch rate
Hrebuild = zeros(size(G)); % harvest rebuild
Rebuild = zeros(size(G)); % rebuild to target (=1), rebuild fails (=0)

myoption= optimset('Display','off','MaxFunEvals',1e+10,'TolX',1e-10,'MaxIter',1e+8);

for j = 1:length(R)
    r = R(j); % intrinsic growth rate
    gamma = G(j); % speed of adjustment
        
    % historical max catch of the open access path to equilibrium
    [h_max,~] = OA_sim(r,K,c,p,q,Emin,E0,gamma);
    Hmax(j) = h_max; % max historic harvest
    
    % solve for harvest that rebuilds stock to Xtarget by Trebuild
    fun = @(x)dist2Target(x,x_ss,Xtarget,Trebuild,r);
    h0 = 0; % initial estimate = 0
    [h,dist] = fmincon(fun,h0,[-1;1],[0;x_ss],[],[],[],[],[],myoption);
    Hrebuild(j) = h; % store h
    Rebuild(j) = -(dist > 1e-5)+1; % label for rebuild
    
    if (mod(j,1000) == 0 || j == length(R))
        fprintf(' step i = %d/%d .. completed \n',j, length(R))
    end     
end

Hratio2 = reshape(Hrebuild./Hmax,m,n); % ratio of Hrebuild/Hmax
Rebuild2 = reshape(Rebuild,m,n); % 0 = rebuild plan fails
clps2 = 1*(Hratio2 <= 0.1); % 1 = "collapse" in rebuild process

%% plot contour regions
R = reshape(R,m,n);
G = reshape(G,m,n);
figure('Position', [20 20 700 800])
subplot(2,1,1) % panel (a)
clps1(Rebuild1==0)=nan;
[~, h] = contourf(R,G,clps1);
set(h,'LineColor','none')
colormap(lines(2))
hold on
scatter(R(Rebuild1==0),G(Rebuild1==0),10,[0.5 0.5 0.5],'square','filled')
title(sprintf('(a) Scenario of %d-year rebuilding plan',Trebuild1))
xlabel('intrinsic growth rate, r','FontSize',12)
ylabel('speed of adjustment, \gamma','FontSize',12)
xlim([0.09 1]); ylim([0.1 5]);
hold off

subplot(2,1,2) % panel (b)
clps2(Rebuild2==0)=nan;
[~, h] = contourf(R,G,clps2);
set(h,'LineColor','none')
colormap(lines(2))
hold on
scatter(R(Rebuild2==0),G(Rebuild2==0),10,[0.5 0.5 0.5],'square','filled')
title(sprintf('(b) Scenario of %d-year rebuilding plan',Trebuild2))
xlabel('intrinsic growth rate, r','FontSize',12)
ylabel('speed of adjustment, \gamma','FontSize',12)
xlim([0.09 1]); ylim([0.1 5]);
hold off

%% add text to figure
% gtext(sprintf('False Positive:\nRebuilding harvest\n < 10%% historical max'),...
%     'FontSize',12,'FontWeight','Bold','Color','w')
% gtext(sprintf('Rebuilding harvest > 10%% historical max'),...
%     'FontSize',12,'FontWeight','Bold','Color','w')
% gtext(sprintf('Stock fails \nto rebuild'),'FontWeight','Bold','BackgroundColor','w')
%% save figure =============================================
saveas(gcf,figName_save)
