function dist = dist2Target(Hrebuild, X0,Xtarget,Trebuild,r)
% this function computes the X at the end of the rebuilding period
% X0 = initial stock to start with
% Xtarget = target stock for rebuilding
% Trebuild = length of rebuilding period (>=1)
% Hrebuild = harvest rate (constant during the rebuilding period)
% r = intrinsic growth rate (carrying capacity = 1)

% define rebuilding period (continuous time)
dt = 0.01;t = 0:dt:Trebuild; tlength = length(t);

% start rebuild from X0
Xrebuild = zeros(tlength,1); Xrebuild(1) = X0;
for i=2:tlength
    xlag = Xrebuild(i-1);
    Xrebuild(i) = xlag +(r*xlag*(1-xlag) - Hrebuild)*dt;
end

% distance to target at the end of rebuilding period
dist = norm(Xtarget - Xrebuild(end));
%... if Xtarget - Xrebuild(end) > 0, then target not achieved
%... if Xtarget - Xrebuild(end) <= 0, then target achieved
end