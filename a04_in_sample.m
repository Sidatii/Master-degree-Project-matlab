%%%%%%%%%%%%%%%%%%%%%%%%
%%% In-sample Simulation
%%%%%%%%%%%%%%%%%%%%%%%%

% close all figure windows
close all;

% clear workspace
clearvars;

% add folder "utils" on matlab path
addpath utils

%% Set time ranges
stime = qq(2018,1); %starting point of the first simulation 
                    %stime-1 is the initial state
                    %stime is the first simulated time period
etime = qq(2021,4); %the end of the known history
       
%% Selection of model variables to include in the report:

% remove folder "utils" from matlab path
rmpath utils