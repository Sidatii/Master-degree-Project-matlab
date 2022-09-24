%%%%%%%%
%%% FILTRATION
%%%%%%%%

%% Housekeeping
clearvars
close all

addpath utils

%% Read the model
[m,p,mss] = readmodel();

%% Set variances for Kalman filtration
p.std_SHK_L_GDP_GAP   = 0.8821;
p.std_SHK_DLA_GDP_BAR = 0.2205;

p.std_SHK_DLA_CORE_INF     = 0.6912;
p.std_SHK_D4L_CORE_INF_TAR = 2;

p.std_SHK_L_S = 0.3628; 
p.std_SHK_RS  = 0.1525; 

p.std_SHK_RR_BAR    = 0.7;
p.std_SHK_DLA_Z_BAR = 0.1;

p.std_SHK_L_GDP_RW_GAP = 0.4231;
p.std_SHK_RS_RW        = 0.5371;
p.std_SHK_DLA_CPI_RW   = 1.4813;
p.std_SHK_RR_RW_BAR    = 0.18;

m = assign(m,p);
m = solve(m);

%% Create model report 
m=modelreport(m);

%% Data sample
sdate = qq(2011,1);
edate = qq(2021,4);

%% Load data
d = dbload('results/history.csv');

dd.OBS_CORE_INF   = d.CORE_INF;

dd.OBS_L_GDP        = d.L_GDP;
dd.OBS_L_S          = d.L_S;
dd.OBS_RS           = d.RS;

dd.OBS_RS_RW        = d.RS_RW;

dd.OBS_DLA_CPI_RW   = d.DLA_CPI_RW;
dd.OBS_L_GDP_RW_GAP = d.L_GDP_RW_GAP;
dd.OBS_D4L_CORE_INF_TAR  = d.D4L_CORE_INF_TAR;

%% Filtration
% Input arguments:
%   m - solved model object
%   dd - database with observations for measurement variables
%   sdate:edate - date range to tun the filter
% Some output arguments:
%   m_kf - model object
%   g - output structure with smoother or prediction data
%   v - estimated variance scale factor
[m_kf,g,v,delta,pe] = filter(m,dd,sdate:edate);

h = g.mean;
d = dbextend(d,h);

%% Save the database
% Database is saved in file 'kalm_his.mat'
dbsave(d,'results/kalm_his.csv');

%% Report 
% full version
disp('Generating Filtration Report...');
x = report.new('Filtration report','visible',true);

%% Figures
% rng = qq(2012,1):edate;
rng = sdate:edate;
sty = struct();
sty.line.linewidth = 0.5;
sty.title.fontsize = 6;
sty.axes.fontsize = 6;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.axes.box = 'off';
sty.legend.location='Best';
sty.legend.FontSize=3;

x.figure('Observed and Trends','subplot',[2,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('GDP','legend',false);
x.series('',[d.L_GDP d.L_GDP_BAR]);

x.graph('Real Interest Rate','legend',false);
x.series('',[d.RR d.RR_BAR]);

x.graph('Foreign Real Interest Rate','legend',false);
x.series('',[d.RR_RW d.RR_RW_BAR]);

x.graph('Real Exchange Rate','legend',false);
x.series('',[d.L_Z d.L_Z_BAR]);

x.graph('Change in Eq. Real Exchange rate','legend',false);
x.series('',[d.DLA_Z_BAR]);

x.graph('Risk Premium','legend',false);
x.series('',[d.PREM]);

x.pagebreak();

x.figure('Gaps','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Core Inflation','legend',false);
x.series('',[d.DLA_CORE_INF d.D4L_CORE_INF_TAR]);

x.graph('Marginal Cost','legend',false);
x.series('',[d.RMC]);

x.graph('GDP GAP','legend',false);
x.series('',[d.L_GDP_GAP]);

x.graph('Monetary Conditions','legend',false);
x.series('',[d.MCI]);

x.graph('Real Interest Rate Gap','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Real Exchange Rate Gap','legend',false);
x.series('',[d.L_Z_GAP]);

x.graph('Foreign GDP Gap','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.graph('Foreign inflation','legend',false); % to be added during the video
x.series('',[d.DLA_CPI_RW]); % to be added during the video

x.graph('Foreign interest rates','legend',false); % to be added during the video
x.series('',[d.RS_RW]); % to be added during the video

x.figure('Shocks','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Core Inflation (cost-push)','legend',false);
x.series('',[d.SHK_DLA_CORE_INF]);

x.graph('Output gap','legend',false);
x.series('',[d.SHK_L_GDP_GAP]);

x.graph('Interest Rate','legend',false);
x.series('',[d.SHK_RS]);

x.graph('Exchange Rate','legend',false);
x.series('',[d.SHK_L_S]);

x.graph('Trend Real Interest Rate','legend',false);
x.series('',[d.SHK_RR_BAR]);

x.graph('Trend Real Exchange Rate','legend',false);
x.series('',[d.SHK_DLA_Z_BAR]);

x.figure('Interest rate and exchange rate','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Nominal interest rate','legend',false);
x.series('',[d.RS]);

x.graph('Real Interest Rate Gap','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Core Inflation qoq','legend',false);
x.series('',[d.DLA_CORE_INF]);

x.graph('Nominal exchange rate rate','legend',false);
x.series('',[d.S]);

x.graph('Real Exchange Rate Gap','legend',false);
x.series('',[d.L_Z_GAP]);

x.graph('Nominal exchange rate rate depreciation','legend',true);
x.series('',[d.DLA_S d.D4L_S], 'legendEntry=',{'qoq','yoy'});

x.graph('Inflation differential','legend',true);
x.series('',[d.DLA_CORE_INF d.DLA_CPI_RW], 'legendEntry=', {'domestic Core inflation','foreign inflation'});

x.graph('Interest rate differential','legend',true);
x.series('',[d.RS d.RS_RW], 'legendEntry=', {'domestic IR','foreign IR'});

x.graph('Exchange rate shock','legend',false);
x.series('',[d.SHK_L_S]);

x.figure('Core Inflation','subplot',[3,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Core Inflation qoq, percent','legend',true);
x.series('',[d.DLA_CORE_INF d.DLA_CORE_INF-d.SHK_DLA_CORE_INF], 'legendEntry=', {'Actual','Predicted'});

x.graph('Core Inflation and RMC, percent','legend',true);
x.series('',[d.DLA_CORE_INF-d.D4L_CORE_INF_TAR d.RMC],'legendEntry=', {'Core Inflation (deviation from the target)','RMC'});

x.graph('Marginal cost decomposition, pp','legend',true);
x.series('',[d.a3*d.L_GDP_GAP (1-d.a3)*d.L_Z_GAP],'legendEntry=',{'Output gap','RER gap'},'plotfunc',@barcon);
x.series('',d.RMC,'legendEntry=',{'RMC'});

x.figure('','style',sty,'range',rng,'dateformat','YY:P');
x.graph('Core Inflation decomposition, qoq percent','legend',true);
x.series('',[d.a1*d.DLA_CORE_INF{-1} (1-d.a1)*d.E_DLA_CORE_INF d.a2*d.a3*d.L_GDP_GAP d.a2*(1-d.a3)*d.L_Z_GAP d.SHK_DLA_CORE_INF],...
  'legendEntry=',{'Persistency','Expectations','Output Gap','RER Gap','Shock'},'plotfunc',@barcon);
x.series('',d.DLA_CORE_INF,'legendEntry=',{'Inflation'});

x.figure('Output gap','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Output gap, percent','legend',true);
x.series('',[d.L_GDP_GAP d.L_GDP_GAP-d.SHK_L_GDP_GAP],'legendEntry=',{'Actual','Predicted'});

x.graph('Output gap decomposition, pp','legend',true);
x.series('',[d.b1*d.L_GDP_GAP{-1} -d.b2*d.b4*d.RR_GAP d.b2*(1-d.b4)*d.L_Z_GAP d.b3*d.L_GDP_RW_GAP d.SHK_L_GDP_GAP],...
    'legendEntry=',{'Lag','RIR gap','RER gap','Foreign gap','Shock'},'plotfunc',@barcon);

x.figure('Decomposition','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P'); % to be added during the video

x.graph('MCI decomposition, pp','legend',true); % to be added during the video
x.series('',[d.b4*d.RR_GAP (1-d.b4)*(-d.L_Z_GAP)],'legendEntry=',{'RIR gap','RER gap'},'plotfunc',@barcon); % to be added during the video
x.series('',d.MCI,'legendEntry=','MCI'); % to be added during the video



x.publish('results/Filtration','display',false);
disp('Done!!!');

rmpath utils