# Replication Materials for *Fishery Collapse Revisited*
authors: Qingran Li, Martin Smith
last update on Aug 1, 2020


__OA_sim.m__  simulates the trajectories of stock, effort, and harvest leading to the open access equilibrium with a logistic growth function. Outputs from this function are
`Hmax` = maximum historical catch, imax = index of time when `Hmax` occurs in the trajectory
`Hmin` = minimum historical catch (after observing `Hmax`)
`Hpath,Xpath,Epath` = trajectory to open access equilibrium for harvest, stock, effort

__OA_collapse_gamma_plot.m__  creates Figure 1. 

__OA_collapse_r_gamma_contour.m__  creates Figure 2 and Figure 3. User should choose the value of the Fig_num parameter before model run.

__OA_collapse_r_gamma_overlay.m__  creates Figure 4 and Figure B1. User should choose the value of the Fig_num parameter before model run.

__OA_changing_c_overT.m__  creates Figure B2 and Figure B3. User should choose the value of the `Fig_num` parameter before model run.

__OA_depens_gamma_c_contour.m__  creates Figure 5.
 
__OPT_Schaefer_sim.m__  computes the equilibrium stock (`x_star`), effort (`E_star`) and harvest (`h_star`) for optimal managed fishery with the Schaefer production function $H=qEx$.

__OPT_Schaefer_c_plot.m__  creates Figure 6.

__OPT_CobbD_sim1.m__  computes the equilibrium stock (`x_star`), equilibrium harvest (`h_star`), and max historical catch (`hmax`) for optimal managed fishery using the Cobb-Douglas function $H=qE^0.5 x$.

__OPT_CobbD_sim2.m__  computes the equilibrium stock (`x_star`), equilibrium harvest (`h_star`), and max historical catch (`hmax`) for optimal managed fishery using the Cobb-Douglas function $H=qEx^0.5$.

__OPT_CobbD_c_plot.m__  creates Figure 7 and Figure B4. User should choose the value of the `Fig_num` parameter before model run.

__Reed_logN_sim.m__  simulates the trajectory of escape, recruitment, and optimal harvest of the Reed model. Random draws from Z’s distribution are trimmed if they fall outside the 0.05 and 0.95 quantiles.

__Reed_model_paths.m__ creates Figure B5.

__Reed_model_density_plot.m__  creates Figure 8.

__dist2Target.m__  defines the objective function to solve for the harvest of a rebuilding plan.

__OA_r_gamma_rebuild_plot.m__  creates Figure 9.

