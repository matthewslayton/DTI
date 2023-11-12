% at this point we've run single trial models and RSA
% now we want to compare each subject-day
% so, we need per-day data in cols and ROIs in rows
% then do one-sample t-test

% we want four matrices. one for BL, one for TMS1, etc

subjects = {'5001','5002','5004','5005','5007','5010','5011','5012','5014','5015',...
    '5016','5017','5019','5020','5021','5022','5025'};

%% (1) make a table for all the data
sz = [246 numel(subjects)*4]; % 246 ROIs
varTypes = ["double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double",...
    "double","double","double","double"];
varNames = ["5001-BL","5001-TMS1","5001-TMS2","5001-TMS3",...
    "5002-BL","5002-TMS1","5002-TMS2","5002-TMS3",...
    "5004-BL","5004-TMS1","5004-TMS2","5004-TMS3",...
    "5005-BL","5005-TMS1","5005-TMS2","5005-TMS3",...
    "5007-BL","5007-TMS1","5007-TMS2","5007-TMS3",...
    "5010-BL","5010-TMS1","5010-TMS2","5010-TMS3",...
    "5011-BL","5011-TMS1","5011-TMS2","5011-TMS3",...
    "5012-BL","5012-TMS1","5012-TMS2","5012-TMS3",...
    "5014-BL","5014-TMS1","5014-TMS2","5014-TMS3",...
    "5015-BL","5015-TMS1","5015-TMS2","5015-TMS3",...
    "5016-BL","5016-TMS1","5016-TMS2","5016-TMS3",...
    "5017-BL","5017-TMS1","5017-TMS2","5017-TMS3",...
    "5019-BL","5019-TMS1","5019-TMS2","5019-TMS3",...
    "5020-BL","5020-TMS1","5020-TMS2","5020-TMS3",...
    "5021-BL","5021-TMS1","5021-TMS2","5021-TMS3",...
    "5022-BL","5022-TMS1","5022-TMS2","5022-TMS3"];


allRSAdata = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

currCol = 1;
for subj = 1:length(subjects)

    subject = subjects{subj};
    %currSubMatFiles = dir(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_corr/%s/*.mat',subject));

    cd(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_corr/%s/',subject));
    load all_corr_day1.mat
    load all_corr_day2.mat
    load all_corr_day3.mat
    load all_corr_day4.mat

    allRSAdata{:,currCol} = all_corr_day1;
    allRSAdata{:,currCol+1} = all_corr_day2;
    allRSAdata{:,currCol+2} = all_corr_day3;
    allRSAdata{:,currCol+3} = all_corr_day4;

    currCol = currCol + 4;

end

cd /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/

save("allRSAdata.mat","allRSAdata")

%% (2) split into four day-specific matrices

BL_mat = horzcat(allRSAdata{:,1},allRSAdata{:,5},allRSAdata{:,9},allRSAdata{:,13},...
    allRSAdata{:,17},allRSAdata{:,21},allRSAdata{:,25},allRSAdata{:,29},...
    allRSAdata{:,33},allRSAdata{:,37},allRSAdata{:,41},allRSAdata{:,45},...
    allRSAdata{:,49},allRSAdata{:,53},allRSAdata{:,57});
TMS1_mat = horzcat(allRSAdata{:,2},allRSAdata{:,6},allRSAdata{:,10},allRSAdata{:,14},...
    allRSAdata{:,18},allRSAdata{:,22},allRSAdata{:,26},allRSAdata{:,30},...
    allRSAdata{:,34},allRSAdata{:,38},allRSAdata{:,42},allRSAdata{:,46},...
    allRSAdata{:,50},allRSAdata{:,54},allRSAdata{:,58});
TMS2_mat = horzcat(allRSAdata{:,3},allRSAdata{:,7},allRSAdata{:,11},allRSAdata{:,15},...
    allRSAdata{:,19},allRSAdata{:,23},allRSAdata{:,27},allRSAdata{:,31},...
    allRSAdata{:,35},allRSAdata{:,39},allRSAdata{:,43},allRSAdata{:,47},...
    allRSAdata{:,51},allRSAdata{:,55},allRSAdata{:,59});
TMS3_mat = horzcat(allRSAdata{:,4},allRSAdata{:,8},allRSAdata{:,12},allRSAdata{:,16},...
    allRSAdata{:,18},allRSAdata{:,22},allRSAdata{:,26},allRSAdata{:,30},...
    allRSAdata{:,36},allRSAdata{:,40},allRSAdata{:,44},allRSAdata{:,48},...
    allRSAdata{:,52},allRSAdata{:,56},allRSAdata{:,60});

save("BL_mat.mat","BL_mat")
save("TMS1_mat.mat","TMS1_mat")
save("TMS2_mat.mat","TMS2_mat")
save("TMS3_mat.mat","TMS3_mat")

%% (3) get iTBS MCI only
% 5002, 5007, 5011, 5012, 5016, 5020

addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/
load allRSAdata.mat

BL_MCI = horzcat(allRSAdata{:,5},allRSAdata{:,17},allRSAdata{:,25},allRSAdata{:,29},allRSAdata{:,41},allRSAdata{:,53});

TMS1_MCI = horzcat(allRSAdata{:,6},allRSAdata{:,18},allRSAdata{:,26},allRSAdata{:,30},allRSAdata{:,42},allRSAdata{:,54});

TMS2_MCI = horzcat(allRSAdata{:,7},allRSAdata{:,19},allRSAdata{:,27},allRSAdata{:,31},allRSAdata{:,43},allRSAdata{:,55});

TMS3_MCI = horzcat(allRSAdata{:,8},allRSAdata{:,20},allRSAdata{:,28},allRSAdata{:,32},allRSAdata{:,44},allRSAdata{:,56});


%% (4) t-test
% maybe need to calculate the noise for the data and use that distribution
% not the normal dist which is what t-test uses. Or convert our r values to
% z. https://dartbrains.org/content/RSA.html

%z = atanh(r); 

%test = atanh(BL_MCI(1,:));
%[h,~,~,stats] = ttest(test);
%disp(stats.tstat)

BL_MCI_ROI_tstat = zeros(246,1);
TMS1_MCI_ROI_tstat = zeros(246,1);
TMS2_MCI_ROI_tstat = zeros(246,1);
TMS3_MCI_ROI_tstat = zeros(246,1);
for ROI = 1:246

    [~,~,~,stats] = ttest(atanh(BL_MCI(ROI,:)));
    %disp(stats.tstat)
    BL_MCI_ROI_tstat(ROI) = stats.tstat;

    [~,~,~,stats] = ttest(atanh(TMS1_MCI(ROI,:)));
    TMS1_MCI_ROI_tstat(ROI) = stats.tstat;

    [~,~,~,stats] = ttest(atanh(TMS2_MCI(ROI,:)));
    TMS2_MCI_ROI_tstat(ROI) = stats.tstat;

    [~,~,~,stats] = ttest(atanh(TMS3_MCI(ROI,:)));
    TMS3_MCI_ROI_tstat(ROI) = stats.tstat;

end

save('BL_MCI_ROI_tstat.mat','BL_MCI_ROI_tstat')
save('TMS1_MCI_ROI_tstat.mat','TMS1_MCI_ROI_tstat')
save('TMS2_MCI_ROI_tstat.mat','TMS2_MCI_ROI_tstat')
save('TMS3_MCI_ROI_tstat.mat','TMS3_MCI_ROI_tstat')

% then go to step7_colour_atlas_BNA.m

%%%%%%%%%% 
%%%% next we want to plot the change in representation as the x-axis and change in d' on the y-axis.
% is this overall representation for the whole brain? One ROI?
% and when we say change, we're plotting the raw corr value for TMS1, 2,
% and 3? Or it's relative to TMS1? D-primes we have

% Left IFG is ROIs 29, 31, 33, 35, 37, 39
% Right IFG is ROIs 30, 32, 34, 36, 38, 40
% Left HC is 215, 217
% Right HC is 216, 218

% BL_MCI
% TMS1_MCI
% TMS2_MCI
% TMS3_MCI

% BL_MCI is 246x6 for 246 ROIs and 6 iTBS-MCI subjects
% left IFG covers six ROIs
BL_left_IPL = vertcat(BL_MCI(135,:),BL_MCI(137,:),BL_MCI(139,:),BL_MCI(141,:),BL_MCI(143,:),BL_MCI(145,:));
%BL_left_IFG has six rows for six ROIs and six cols for the six subjects
% find one representation value for that ROI per subject
BL_mean_L_IPL = mean(BL_left_IPL);

% so, take the means and replace that subject's col with the number for the
% indiv ROI

%%% 5002 - 5007 - 5011 - 5012 - 5016 - 5020
BL_new_L_IPL = horzcat(BL_MCI(137,1),BL_MCI(135,2),BL_mean_L_IPL(:,3),BL_mean_L_IPL(:,4),BL_MCI(141,5),BL_MCI(143,6));

% IPL is 135, 137, 139, 141, 143, 145
% 5002 137
% 5007 is 135
% 5011, 5012 can't get. Need to do
% 5016 is 141
% 5020 143


TMS1_left_IPL = vertcat(TMS1_MCI(135,:),TMS1_MCI(137,:),TMS1_MCI(139,:),TMS1_MCI(141,:),TMS1_MCI(143,:),TMS1_MCI(143,:));
TMS1_mean_L_IPL = mean(TMS1_left_IPL);

TMS2_left_IPL = vertcat(TMS2_MCI(135,:),TMS2_MCI(137,:),TMS2_MCI(139,:),TMS2_MCI(141,:),TMS2_MCI(143,:),TMS2_MCI(143,:));
TMS2_mean_L_IPL = mean(TMS2_left_IPL);

TMS3_left_IPL = vertcat(TMS3_MCI(135,:),TMS3_MCI(137,:),TMS3_MCI(139,:),TMS3_MCI(141,:),TMS3_MCI(143,:),TMS3_MCI(143,:));
TMS3_mean_L_IPL = mean(TMS3_left_IPL);

TMS1_new_L_IPL = horzcat(TMS1_MCI(137,1),TMS1_MCI(135,2),TMS1_mean_L_IPL(:,3),TMS1_mean_L_IPL(:,4),TMS1_MCI(141,5),TMS1_MCI(143,6));
TMS2_new_L_IPL = horzcat(TMS2_MCI(137,1),TMS2_MCI(135,2),TMS2_mean_L_IPL(:,3),TMS2_mean_L_IPL(:,4),TMS2_MCI(141,5),TMS2_MCI(143,6));
TMS3_new_L_IPL = horzcat(TMS3_MCI(137,1),TMS3_MCI(135,2),TMS3_mean_L_IPL(:,3),TMS3_mean_L_IPL(:,4),TMS3_MCI(141,5),TMS3_MCI(143,6));


%%% now I need the d-prime for that day for each subject
iTBS_MCI = readtable('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/iTBS-MCI-dprime.xlsx');

day1_cret = iTBS_MCI.Day1D_primeCRET;
day2_cret = iTBS_MCI.Day2D_primeCRET;
day3_cret = iTBS_MCI.Day3D_primeCRET;
day4_cret = iTBS_MCI.Day4D_primeCRET;

set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
scatter(BL_mean_L_IPL,day1_cret')
figure
scatter(TMS1_mean_L_IPL,day1_cret')
figure
scatter(TMS2_mean_L_IPL,day1_cret')
figure
scatter(TMS3_mean_L_IPL,day1_cret')

% what about TMS treatment effect? (TMS3-TMS1)/TMS1


%%%% *** later on when we have a visual RDM we'd like to show
%%%% representation go up with d-prime for CRET and not PRET
% relChange = (TMS3_mean_L_IPL-TMS1_mean_L_IPL)./TMS1_mean_L_IPL;
% relChange_day = (day4_cret-day2_cret)./day2_cret;
% %scatter(relChange,relChange_day)
% 
% figure
% mdl = fitlm(relChange,relChange_day);
% plot(mdl)
% 
% figure
% relChange = (TMS3_mean_L_IPL-BL_mean_L_IPL)./BL_mean_L_IPL;
% relChange_day = (day4_cret-day1_cret)./day1_cret;
% %scatter(relChange,relChange_day)
% mdl = fitlm(relChange,relChange_day);
% plot(mdl)
% 
% relChange = (TMS3_new_L_IPL-TMS1_new_L_IPL)./TMS1_new_L_IPL;
% figure
% mdl = fitlm(relChange,relChange_day);
% plot(mdl)
% 
% relChange_BL = (TMS3_new_L_IPL-BL_new_L_IPL)./BL_new_L_IPL;
% figure
% mdl = fitlm(relChange_BL,relChange_day);
% plot(mdl,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
% xlabel('Change in Representational Strength','FontSize',14)
% ylabel('Change in Memory Performance','FontSize',14)
% title('TMS Treatment Effect Relative to Baseline','FontSize',16)


%%%% that ROI didn't look good. Let's try another one

% BL_MCI
% TMS1_MCI
% TMS2_MCI
% TMS3_MCI

relChange_day_TMS1 = (day4_cret-day2_cret)./day2_cret;
relChange_day_BL = (day4_cret-day1_cret)./day1_cret;

% I want to know which row (ROI) has the highest average corr
allCorr_BL = zeros(246,1); %TMS3-BL
allCorr_TMS1 = zeros(246,1); %TMS3-TMS1
for ROI = 1:246

    % linear model
    currCorr_BL = (TMS3_MCI(ROI,:)-BL_MCI(ROI,:))./BL_MCI(ROI,:);
    currCorr_TMS1 = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);

    %mdl_BL = fitlm(currCorr_BL,relChange_day_BL);
    %mdl_TMS1 = fitlm(currCorr_TMS1,relChange_day_TMS1);
    %allCorr_BL(ROI) = mdl_BL.Rsquared.Adjusted;
    %allCorr_TMS1(ROI) = mdl_TMS1.Rsquared.Adjusted;

    % Pearson's corr
    r_BL = corrcoef(currCorr_BL,relChange_day_BL);
    r_TMS1 = corrcoef(currCorr_TMS1,relChange_day_TMS1);

    allCorr_BL(ROI) = r_BL(1,2);
    allCorr_TMS1(ROI) = r_TMS1(1,2);

end

BL_indx = find(allCorr_BL==max(allCorr_BL)); %111
TMS1_indx = find(allCorr_TMS1==max(allCorr_TMS1)); %2

%mdl_BL.Rsquared.Adjusted

% then I put it in excel, added a col of numbers 1 to 246, then sorted by
% largest to smallest for the corr values, and found that left PhG for
% TMS3-BL is the highest: 111	0.819098707	PhG_L
% for TMS3-TMS1 2	0.8029937	SFG, 145	0.527994156	IPL

% I want to try TMS3-BL ROI 111 and TMS3-TMS1 ROI 145

ROI = 111;
currCorr_BL = (TMS3_MCI(ROI,:)-BL_MCI(ROI,:))./BL_MCI(ROI,:);
mdl_BL = fitlm(currCorr_BL,relChange_day_BL);
plot(mdl_BL,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline','Parahippocampal Gyrus'},'FontSize',16)
text(-0.2,0.4,'r=-0.92','FontSize',18)

corrcoef(currCorr_BL,relChange_day_BL)

% figure
% ROI = 145;
% currCorr_TMS1 = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);
% mdl_TMS1 = fitlm(currCorr_TMS1,relChange_day_TMS1);
% plot(mdl_TMS1,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
% xlabel('Change in Representational Strength','FontSize',14)
% ylabel('Change in Memory Performance','FontSize',14)
% title('TMS Treatment Effect Relative to Baseline','FontSize',16)

figure
ROI = 113;
currCorr_TMS1 = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);
mdl_TMS1 = fitlm(currCorr_TMS1,relChange_day_TMS1);
plot(mdl_TMS1,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline','Parahippocampal Gyrus'},'FontSize',16)
text(1.9,3.2,'r = 0.74','FontSize',18)

% let's try TMS1 143 and 135. Both are IPL
figure
ROI = 135;
currCorr_TMS1 = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);
mdl_TMS1 = fitlm(currCorr_TMS1,relChange_day_TMS1);
plot(mdl_TMS1,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline','Inferior Parietal Lobule'},'FontSize',16)
text(-2,-2,'r = 0.63','FontSize',18)

figure
ROI = 143;
currCorr_TMS1 = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);
mdl_TMS1 = fitlm(currCorr_TMS1,relChange_day_TMS1);
plot(mdl_TMS1,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline','Inferior Parietal Lobule'},'FontSize',16)
text(1.9,3.2,'r = 0.67','FontSize',18)

figure
ROI = 153;
currCorr_TMS1 = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);
mdl_TMS1 = fitlm(currCorr_TMS1,relChange_day_TMS1);
plot(mdl_TMS1,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline','Precuneus'},'FontSize',16)
text(1.9,3.2,'r = 0.54','FontSize',18)

figure
ROI = 129;
currCorr_BL = (TMS3_MCI(ROI,:)-BL_MCI(ROI,:))./BL_MCI(ROI,:);
mdl_BL = fitlm(currCorr_BL,relChange_day_BL);
plot(mdl_BL,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline','Superior Parietal Lobule'},'FontSize',16)
text(4,-0.6,'r=0.48','FontSize',18)

figure
ROI = 141;
currCorr_BL = (TMS3_MCI(ROI,:)-BL_MCI(ROI,:))./BL_MCI(ROI,:);
mdl_BL = fitlm(currCorr_BL,relChange_day_BL);
plot(mdl_BL,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline','Inferior Parietal Lobule'},'FontSize',16)
text(0,1,'r = 0.36','FontSize',18)

%%%% can I put both MCI and sham on the same plot? Looks like ROI = 129 SPL
%%%% could work

ROI = 143;
currCorr_TMS1_MCI = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);
currCorr_TMS1_sham = (TMS3_sham(ROI,:)-TMS1_sham(ROI,:))./TMS1_sham(ROI,:);

mdl_MCI = fitlm(currCorr_TMS1_MCI,relChange_day_TMS1);
mdl_sham = fitlm(currCorr_TMS1_sham,relChange_day_TMS1_sham);

plot(mdl_MCI,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline — MCI','Inferior Parietal Lobule'},'FontSize',16)
text(0,1,'r = 0.67','FontSize',18)
figure
plot(mdl_sham,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline — Sham','Inferior Parietal Lobule'},'FontSize',16)
text(-1,7,'r = 0.51','FontSize',18)

figure
ROI = 135;
currCorr_TMS1_MCI = (TMS3_MCI(ROI,:)-TMS1_MCI(ROI,:))./TMS1_MCI(ROI,:);
currCorr_TMS1_sham = (TMS3_sham(ROI,:)-TMS1_sham(ROI,:))./TMS1_sham(ROI,:);
mdl_MCI = fitlm(currCorr_TMS1_MCI,relChange_day_TMS1);
mdl_sham = fitlm(currCorr_TMS1_sham,relChange_day_TMS1_sham);
plot(mdl_MCI,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline — MCI','Inferior Parietal Lobule'},'FontSize',16)
text(-8,1,'r = 0.63','FontSize',18)
figure
plot(mdl_sham,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline — Sham','Inferior Parietal Lobule'},'FontSize',16)
text(-2,10,'r = -0.69','FontSize',18)

figure

ROI = 129;
currCorr_BL_MCI = (TMS3_MCI(ROI,:)-BL_MCI(ROI,:))./BL_MCI(ROI,:);
currCorr_BL_sham = (TMS3_sham(ROI,:)-BL_sham(ROI,:))./BL_sham(ROI,:);
mdl_MCI = fitlm(currCorr_BL_MCI,relChange_day_BL);
mdl_sham = fitlm(currCorr_BL_sham,relChange_day_BL_sham);
plot(mdl_MCI,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline — MCI','Superior Parietal Lobule'},'FontSize',16)
text(0,1,'r = 0.48','FontSize',18)
figure
plot(mdl_sham,"LineWidth",2.7,'Color',[0.6350 0.0780 0.1840],"Marker","o","MarkerSize",12)
xlabel('Change in Representational Strength','FontSize',14)
ylabel('Change in Memory Performance','FontSize',14)
title({'TMS Treatment Effect Relative to Baseline — Sham','Superior Parietal Lobule'},'FontSize',16)
text(-8,0.5,'r = .08','FontSize',18)



%% (5) sham and hOA

% sham is 5010, 5021, 5022
BL_sham = horzcat(allRSAdata{:,21},allRSAdata{:,57},allRSAdata{:,61});
TMS1_sham = horzcat(allRSAdata{:,22},allRSAdata{:,58},allRSAdata{:,62});
TMS2_sham = horzcat(allRSAdata{:,23},allRSAdata{:,59},allRSAdata{:,63});
TMS3_sham = horzcat(allRSAdata{:,24},allRSAdata{:,60},allRSAdata{:,64});

% no 5010
BL_sham = horzcat(allRSAdata{:,57},allRSAdata{:,61});
TMS1_sham = horzcat(allRSAdata{:,58},allRSAdata{:,62});
TMS2_sham = horzcat(allRSAdata{:,59},allRSAdata{:,63});
TMS3_sham = horzcat(allRSAdata{:,60},allRSAdata{:,64});

BL_sham_ROI_tstat = zeros(246,1);
TMS1_sham_ROI_tstat = zeros(246,1);
TMS2_sham_ROI_tstat = zeros(246,1);
TMS3_sham_ROI_tstat = zeros(246,1);
for ROI = 1:246
    [~,~,~,stats] = ttest(atanh(BL_sham(ROI,:)));
    BL_sham_ROI_tstat(ROI) = stats.tstat;
    [~,~,~,stats] = ttest(atanh(TMS1_sham(ROI,:)));
    TMS1_sham_ROI_tstat(ROI) = stats.tstat;
    [~,~,~,stats] = ttest(atanh(TMS2_sham(ROI,:)));
    TMS2_sham_ROI_tstat(ROI) = stats.tstat;
    [~,~,~,stats] = ttest(atanh(TMS3_sham(ROI,:)));
    TMS3_sham_ROI_tstat(ROI) = stats.tstat;
end

% then go to step7_colour_atlas_BNA.m

% load the d-prime values
cret_mci_sham = readtable('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/cret_mci_sham.xlsx');
day1_cret_mci_sham = cret_mci_sham.CRET_1;
day2_cret_mci_sham = cret_mci_sham.CRET_2;
day3_cret_mci_sham = cret_mci_sham.CRET_3;
day4_cret_mci_sham = cret_mci_sham.CRET_4;


day1_cret_mci = vertcat(day1_cret_mci_sham(1:2),day1_cret_mci_sham(4:7));
day2_cret_mci = vertcat(day2_cret_mci_sham(1:2),day2_cret_mci_sham(4:7));
day3_cret_mci = vertcat(day3_cret_mci_sham(1:2),day3_cret_mci_sham(4:7));
day4_cret_mci = vertcat(day4_cret_mci_sham(1:2),day4_cret_mci_sham(4:7));

% has 5010
day1_cret_sham = vertcat(day1_cret_mci_sham(3),day1_cret_mci_sham(8:9));
day2_cret_sham = vertcat(day2_cret_mci_sham(3),day2_cret_mci_sham(8:9));
day3_cret_sham = vertcat(day3_cret_mci_sham(3),day3_cret_mci_sham(8:9));
day4_cret_sham = vertcat(day4_cret_mci_sham(3),day4_cret_mci_sham(8:9));
% no 5010
% day1_cret_sham = day1_cret_mci_sham(8:9);
% day2_cret_sham = day2_cret_mci_sham(8:9);
% day3_cret_sham = day3_cret_mci_sham(8:9);
% day4_cret_sham = day4_cret_mci_sham(8:9);


relChange_day_TMS1_sham = (day4_cret_sham-day2_cret_sham)./day2_cret_sham;
relChange_day_BL_sham = (day4_cret_sham-day1_cret_sham)./day1_cret_sham;

% I want to know which row (ROI) has the highest average corr
allCorr_BL_sham = zeros(246,1); %TMS3-BL
allCorr_TMS1_sham = zeros(246,1); %TMS3-TMS1
for ROI = 1:246

    % linear model
    currCorr_BL = (TMS3_sham(ROI,:)-BL_sham(ROI,:))./BL_sham(ROI,:);
    currCorr_TMS1 = (TMS3_sham(ROI,:)-TMS1_sham(ROI,:))./TMS1_sham(ROI,:);

    %mdl_BL = fitlm(currCorr_BL,relChange_day_BL);
    %mdl_TMS1 = fitlm(currCorr_TMS1,relChange_day_TMS1);
    %allCorr_BL(ROI) = mdl_BL.Rsquared.Adjusted;
    %allCorr_TMS1(ROI) = mdl_TMS1.Rsquared.Adjusted;

    % Pearson's corr
    r_BL = corrcoef(currCorr_BL,relChange_day_BL_sham);
    r_TMS1 = corrcoef(currCorr_TMS1,relChange_day_TMS1_sham);

    allCorr_BL_sham(ROI) = r_BL(1,2);
    allCorr_TMS1_sham(ROI) = r_TMS1(1,2);

end


% hOA is 5014, 5015, 5017, 5025 (this doesn't have 5025 in it)
BL_hOA = horzcat(allRSAdata{:,33},allRSAdata{:,37},allRSAdata{:,45});
TMS1_hOA = horzcat(allRSAdata{:,34},allRSAdata{:,38},allRSAdata{:,46});
TMS2_hOA = horzcat(allRSAdata{:,35},allRSAdata{:,39},allRSAdata{:,47});
TMS3_hOA = horzcat(allRSAdata{:,36},allRSAdata{:,40},allRSAdata{:,48});

BL_hOA_ROI_tstat = zeros(246,1);
TMS1_hOA_ROI_tstat = zeros(246,1);
TMS2_hOA_ROI_tstat = zeros(246,1);
TMS3_hOA_ROI_tstat = zeros(246,1);
for ROI = 1:246
    [~,~,~,stats] = ttest(atanh(BL_hOA(ROI,:)));
    BL_hOA_ROI_tstat(ROI) = stats.tstat;
    [~,~,~,stats] = ttest(atanh(TMS1_hOA(ROI,:)));
    TMS1_hOA_ROI_tstat(ROI) = stats.tstat;
    [~,~,~,stats] = ttest(atanh(TMS2_hOA(ROI,:)));
    TMS2_hOA_ROI_tstat(ROI) = stats.tstat;
    [~,~,~,stats] = ttest(atanh(TMS3_hOA(ROI,:)));
    TMS3_hOA_ROI_tstat(ROI) = stats.tstat;
end


%%% calculate cohen's d based on the iTBS-MCI vs sham plot
cret_vals = readtable('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/cret_values_iTBS-MCI_sham.xlsx');


cret_vals_MCI = cret_vals{1:6,:};
cret_vals_sham = cret_vals{8:9,:}; %leave out 5010

rel_cret_MCI_tms1 = (cret_vals_MCI(:,5)-cret_vals_MCI(:,3))./cret_vals_MCI(:,3);
rel_cret_MCI_BL = (cret_vals_MCI(:,5)-cret_vals_MCI(:,2))./cret_vals_MCI(:,2);
rel_cret_sham_tms1 = (cret_vals_sham(:,5)-cret_vals_sham(:,3))./cret_vals_sham(:,3);
rel_cret_sham_BL = (cret_vals_sham(:,5)-cret_vals_sham(:,2))./cret_vals_sham(:,2);


% cohen's d = (M1 - M2) / SDpooled
% SDpooled = sqrt((SD1^2 + SD2*2)/2)

mean_MCI = mean(rel_cret_MCI_tms1);
mean_sham = mean(rel_cret_sham_tms1);

sd_pooled = sqrt((std(rel_cret_MCI_tms1)^2 + (std(rel_cret_sham_tms1)^2)/2));

cohen_d = (mean_MCI - mean_sham) / sd_pooled;
% 0.47

%%% what about significance? 
relMCI_tms1 = (day4_cret_mci-day2_cret_mci)./day2_cret_mci;
relSham_tms1 = (day4_cret_sham-day2_cret_sham)./day2_cret_sham;

ttest(relMCI_tms1,relSham_tms1)

ttest(0.114003656,-0.107031531)

MCI_day4_day2 = [-0.178412918 0.080613736 0.087618084 0.439794546 0.314972352 -0.29435371];
%sham_day4_day2 = [-0.515644349 0.088977544 0.87225534];
sham_day4_day2 = [0.088977544 0.87225534];

[h,p] = ttest2(MCI_day4_day2,sham_day4_day2);
% p =.1956

% (TM3-TMS1)./TMS1

MCI_relative = [-0.17329716 0.210399213 0.061262217 1.853003147 1.884578214 -0.41935274];
%sham_relative = [-0.203051048 0.07311736 2.603165323];
sham_relative = [0.07311736 2.603165323];

[h,p] = ttest2(MCI_relative,sham_relative);

mean(MCI_relative)
mean(sham_relative)


MCI_rel_BL = [0.170183724 -0.419675815 0.034119575 0.320809369 0.587953794 0.006114225];
sham_rel_BL = [-0.212662431 -0.013810143 -0.108439069];

[h,p] = ttest2(MCI_rel_BL,sham_rel_BL);

[~,~,~,stats] = ttest2(MCI_rel_BL,sham_rel_BL);

MCI_high = [-0.186807701 -2.588697587 -0.3748669 -8.448524655 -1.055217698 0.134702461];
sham_high = [0 -0.783219303 0.653894223];

[h,p] = ttest2(MCI_high,sham_high);

[~,~,~,stats] = ttest2(MCI_high,sham_high);
