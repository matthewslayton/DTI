ste_BN%function Vo = colour_atlas(P,x,outname)
% Colour in a brain region atlas using a vector of values for each region
% FORMAT:
% Q = colour_atlas(P,x,fname)
%
% INPUT:
% P          - filename of atlas image
% x          - vector of values to assign to atlas regions
% outname    - filename of output image
%
% OUTPUT:
% Vo         - Header information for output image (see 'spm_vol')
%
% Vector x must have the same length as the number of unique values in the atlas
% image, excluding zero.
% Values in x are assigned to atlas values in numerical order, so if atlas
% values are continuous:
%     region 1 = x(1), region 2 = x(2) etc.
% For an atlas with regions numbered 10, 15 & 5:
%     region 10 = x(2), region 15 = x(3), region 5 = x(1)
% This function assumes that all atlases have integer-numbered regions, and
% rounds the values loaded from the atlas image, because sometimes SPM
% incorrectly loads integer-valued atlases with non-integer values (perhaps
% a rounding error). If your atlas has non-integer values, modify the code.
%


%%%%%% t-vals for all subjects by day.
% in this case, we want iTBS MCI. That's 5002, 5007, 5011, 5012, 5016, 5020
addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/
load BL_ROI_tstat
load TMS1_ROI_tstat
load TMS2_ROI_tstat
load TMS3_ROI_tstat

P = '/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/BN_Atlas_246_2mm.nii.gz';
Vatlas = spm_vol(P);
Yatlas = spm_read_vols(Vatlas);
atvals = unique(Yatlas);
atvals = atvals(atvals~=0);

for x_val = 1:12

    %%%%% pick one
    % iTBS-MCI
    if x_val == 1
        x = BL_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/MCI_BL_vo_output.nii');
    elseif x_val == 2
        x = TMS1_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/MCI_TMS1_vo_output.nii');
    elseif x_val == 3   
        x = TMS2_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/MCI_TMS2_vo_output.nii');
    elseif x_val == 4   
        x = TMS3_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/MCI_TMS3_vo_output.nii');
        
        % sham
    elseif x_val == 5
        x = BL_sham_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/sham_BL_vo_output.nii');
    elseif x_val == 6        
        x = TMS1_sham_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/sham_TMS1_vo_output.nii');
    elseif x_val == 7    
        x = TMS2_sham_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/sham_TMS2_vo_output.nii');
    elseif x_val == 8  
        x = TMS3_sham_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/sham_TMS3_vo_output.nii');
        
        % hOA
    elseif x_val == 9
        x = BL_hOA_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/hOA_BL_vo_output.nii');
    elseif x_val == 10       
        x = TMS1_hOA_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/hOA_TMS1_vo_output.nii');
    elseif x_val == 11
        x = TMS2_hOA_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/hOA_TMS2_vo_output.nii');
    elseif x_val == 12
        x = TMS3_hOA_ROI_tstat';
        outname = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/hOA_TMS3_vo_output.nii');
        
    end

    for behav = 1:size(x, 1)
        x = x(behav, :);
        bname = sprintf('%d', behav);
        
        % change what's in '' to something meaningful
        [p,n,e] = spm_fileparts(P);
    
        Yo = zeros(size(Yatlas));
        for region = 1:length(atvals)
            % Use round in case integers in atlas are loaded incorrectly
            Yo(round(Yatlas)==atvals(region)) = x(region);
        end
        
        Vo = Vatlas;
        Vo = rmfield(Vo,{'pinfo','private'});
        Vo.fname = outname;
        Vo.dt = [spm_type('int16'),0]; % Should be signed data type
        spm_write_vol(Vo,Yo);
    end
    disp('Done');
end %x-val

%%%%%% INDIVIDUAL SUBJECTS %%%%%%%


%%%% (1) Prepare to make color map %%%%
subjects = {'5007','5011','5012','5014'};

for subj = 1:length(subjects)

    subject = subjects{subj};

    RDM_folder = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_corr/%s/',subject);
    addpath(RDM_folder)
    
    load all_corr_day1.mat
    load all_corr_day2.mat
    load all_corr_day3.mat
    load all_corr_day4.mat

    % needs to be 4x246
    atlas_allCorr = vertcat(all_corr_day1',all_corr_day2',all_corr_day3',all_corr_day4');
    save('atlas_allCorr.mat','atlas_allCorr')
    
    load atlas_allCorr.mat
    
    BNA_vals2 = atlas_allCorr;
    save('BNA_vals2.mat','BNA_vals2')
    
    tms3_bl = all_corr_day4'-all_corr_day1';
    tms3_tms1 = all_corr_day4'-all_corr_day2';

    % load data file
    %homedir = '/Users/christinayu/Desktop/visualization/';
    %homedir = '/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS/Analysis_files/';
    homedir = '/Users/matthewslayton/Documents/Duke/Simon_Lab/Analysis_files';

    cd(homedir)
    load BNA_vals2.mat
    % x = BNA_vals2;
    % x = all_corr_day1';
    % x = all_corr_day3';
    % x = tms3_bl;

    for x_val = 1:3 %which day's corr values (or contrast) will I run?
        
        if x_val == 1 %TMS1
            x = all_corr_day2'; %TMS1
            outname = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_brainmaps/',subject,'_vo_output_tms1.nii');
        elseif x_val == 2 %TMS3
            x = all_corr_day4'; %TMS3
            outname = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_brainmaps/',subject,'_vo_output_tms3.nii');
        elseif x_val == 3 %TMS3-TMS1
           x = tms3_tms1; %contrast
         outname = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_brainmaps/',subject,'_vo_output_tms3-tms1.nii');
        end     
       
        %P = '/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS/Analysis_files/BN_Atlas_246_2mm.nii.gz';
        P = '/Users/matthewslayton/Documents/Duke/Simon_Lab/Analysis_files/BN_Atlas_246_2mm.nii.gz';
        %outname = '/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/Analysis_files_and_scripts/vo_output_tms3-tms1.nii';
        

        %%%%%% what if I want to do an average of all my subjects?
    
    
        %%% resume original script
        % define the background image--should have the same number of ROIs as your matrix
        % if nargin<1 || isempty(P)
        %     [P,sts] = spm_select(1,'image','Select atlas image ...');
        %     if sts == 0
        %         error('User quit')
        %     end
        % end
        Vatlas = spm_vol(P);
        Yatlas = spm_read_vols(Vatlas);
        atvals = unique(Yatlas);
        atvals = atvals(atvals~=0);
    
    
        % change 'correls' to the name of your n (kinds of maps you want to make) x m (# of ROIs) matrix
        % for behav = 1:size(values, 1)
        %     x = aa(behav, :);
        for behav = 1:size(x, 1)
            x = x(behav, :);
            bname = sprintf('%d', behav);
            
            % change what's in '' to something meaningful
            [p,n,e] = spm_fileparts(P);
        %     if nargin<3 || isempty(outname)
        %         outname = fullfile(p,[n,'_BNA_ROI', bname,e]);
        %     end
        
            Yo = zeros(size(Yatlas));
            for region = 1:length(atvals)
                % Use round in case integers in atlas are loaded incorrectly
                Yo(round(Yatlas)==atvals(region)) = x(region);
            end
            
            Vo = Vatlas;
            Vo = rmfield(Vo,{'pinfo','private'});
            Vo.fname = outname;
            Vo.dt = [spm_type('int16'),0]; % Should be signed data type
            spm_write_vol(Vo,Yo);
        end
        disp('Done');

    end %x_val loop

end %subj loop



%%%%%% AVERAGE SUBJECTS %%%%%%%

%%%% (1) Prepare to make color map %%%%
subjects = {'5007','5011','5012','5014'};

allDays = zeros(246,4*length(subjects));
counter = 0; %need to go through allDays

for subj = 1:length(subjects)

    subject = subjects{subj};
    subName = strcat('S',subject(2:end));

    RDM_folder = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_corr/%s/',subject);
    cd(RDM_folder)
    
    load all_corr_day1.mat
    load all_corr_day2.mat
    load all_corr_day3.mat
    load all_corr_day4.mat

    allDays(:,1+counter) = all_corr_day1;
    allDays(:,2+counter) = all_corr_day2;
    allDays(:,3+counter) = all_corr_day3;
    allDays(:,4+counter) = all_corr_day4;

    counter = counter + 4;
    
end

day1_avg = mean([allDays(:,1),allDays(:,5),allDays(:,9),allDays(:,13)],2,'omitnan');
day2_avg = mean([allDays(:,2),allDays(:,6),allDays(:,10),allDays(:,14)],2,'omitnan');
day3_avg = mean([allDays(:,3),allDays(:,7),allDays(:,11),allDays(:,15)],2,'omitnan');
day4_avg = mean([allDays(:,4),allDays(:,8),allDays(:,12),allDays(:,16)],2,'omitnan');

avgAllCor = vertcat(day1_avg',day2_avg',day3_avg',day4_avg');

%%%% how does it look with only 5007, 5011, 5012, and not 5014? 5014's
%%%% values are super low and turns out they're hOA anyway, plus right-side
%%%% stim site
day1_avg = mean([allDays(:,1),allDays(:,5),allDays(:,9)],2,'omitnan');
day2_avg = mean([allDays(:,2),allDays(:,6),allDays(:,10)],2,'omitnan');
day3_avg = mean([allDays(:,3),allDays(:,7),allDays(:,11)],2,'omitnan');
day4_avg = mean([allDays(:,4),allDays(:,8),allDays(:,12)],2,'omitnan');



for x_val = 1:4 %which day's corr values (or contrast) will I run?
    
    if x_val == 1 %TMS1
        x = day2_avg'; %TMS1
        outname = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_brainmaps/avg_no5014_vo_output_tms1.nii');
    elseif x_val == 2 %TMS3
        x = day4_avg'; %TMS3
        outname = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_brainmaps/avg_no5014_vo_output_tms3.nii');
    elseif x_val == 3 %TMS3-TMS1
        x = day4_avg'-day2_avg'; %contrast
        outname = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_brainmaps/avg_no5014_vo_output_tms3-tms1.nii');
    elseif x_val ==4 %BL
        x = day1_avg'; %BL
        outname = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_brainmaps/avg_no5014_vo_output_bl.nii');
    end     
   
    P = '/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS/Analysis_files/BN_Atlas_246_2mm.nii.gz';
    P = '/Users/matthewslayton/Documents/Duke/Simon_Lab/Analysis_files/BN_Atlas_246_2mm.nii.gz';
    %outname = '/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/Analysis_files_and_scripts/vo_output_tms3-tms1.nii';
    
    Vatlas = spm_vol(P);
    Yatlas = spm_read_vols(Vatlas);
    atvals = unique(Yatlas);
    atvals = atvals(atvals~=0);


    % change 'correls' to the name of your n (kinds of maps you want to make) x m (# of ROIs) matrix
    % for behav = 1:size(values, 1)
    %     x = aa(behav, :);
    for behav = 1:size(x, 1)
        x = x(behav, :);
        bname = sprintf('%d', behav);
        
        % change what's in '' to something meaningful
        [p,n,e] = spm_fileparts(P);
    
        Yo = zeros(size(Yatlas));
        for region = 1:length(atvals)
            % Use round in case integers in atlas are loaded incorrectly
            Yo(round(Yatlas)==atvals(region)) = x(region);
        end
        
        Vo = Vatlas;
        Vo = rmfield(Vo,{'pinfo','private'});
        Vo.fname = outname;
        Vo.dt = [spm_type('int16'),0]; % Should be signed data type
        spm_write_vol(Vo,Yo);
    end
    disp('Done');

end %x_val loop


% step7_colour_atlas_BNA.m
% function Vo = colour_atlas(P,x,outname)
% colour_atlas('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/Analysis_files_and_scripts/BN_Atlas_246_2mm.nii',BNA_vals2,'/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/Analysis_files_and_scripts/vo_output.nii');


% is stim site always one of the inferior parietal lobule ROIs? I only checked for 5007
% 5007 -42, -18, 26
% 5011 -76, -26, 55
% 5012 -42.17, -12.79, 52.53 <-- probably same as 5007
% 5014 57.32, 4.86, -15.42 %hOA
% /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/brainnetome_atlas.xlsx

set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
X = categorical({'TMS Day 1','TMS Day 3'});
X = reordercats(X,{'TMS Day 1','TMS Day 3'});
Y = [day2_avg(135) day4_avg(135)];

b = bar(X,Y,0.4,'EdgeColor','none');
b.FaceColor = 'flat';
b.CData(1,:) = [.01 .9 .3];
b.CData(2,:) = [.95 .594 .08];
ylabel('Correlation','FontSize',16)
title('Left Inferior Parietal Lobule (stimulation site)','FontSize',16)

% what if I assume that 5007 and 5012 are both in 135, one of the IPL ROIs
% then for 5011, it looks closer to 145, another IPL region
% IPL is 135, 137, 139, 141, 143, 145

day1_avg = mean([allDays(:,1),allDays(:,5),allDays(:,9)],2,'omitnan');
day2_avg = mean([allDays(:,2),allDays(:,6),allDays(:,10)],2,'omitnan');
day3_avg = mean([allDays(:,3),allDays(:,7),allDays(:,11)],2,'omitnan');
day4_avg = mean([allDays(:,4),allDays(:,8),allDays(:,12)],2,'omitnan');


day2_5007 = allDays(135,2);
day4_5007 = allDays(135,4);
day2_5011 = allDays(145,6);
day4_5011 = allDays(145,8);
day2_5012 = allDays(135,10);
day4_5012 = allDays(135,12);

day2_threeMCI = mean([day2_5007 day2_5011 day2_5012],2,'omitnan');
day4_threeMCI = mean([day4_5007 day4_5011 day4_5012],2,'omitnan');


%set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
X = categorical({'TMS Day 1','TMS Day 3'});
X = reordercats(X,{'TMS Day 1','TMS Day 3'});
Y = [day2_threeMCI day4_threeMCI];

b = bar(X,Y,0.4,'EdgeColor','none');
b.FaceColor = 'flat';
b.CData(1,:) = [.01 .9 .3];
b.CData(2,:) = [.95 .594 .08];
ylabel('Correlation','FontSize',16)
title('Left Inferior Parietal Lobule (stimulation site)','FontSize',16)

% I'm guessing
day2_5014 = allDays(142,14);
day4_5014 = allDays(142,16);

figure
X = categorical({'TMS Day 1','TMS Day 3'});
X = reordercats(X,{'TMS Day 1','TMS Day 3'});
Y = [day2_5014 day4_5014];

b = bar(X,Y,0.4,'EdgeColor','none');
b.FaceColor = 'flat';
b.CData(1,:) = [.01 .9 .3];
b.CData(2,:) = [.95 .594 .08];
ylabel('Correlation','FontSize',16)
title('Left Inferior Parietal Lobule (stimulation site)','FontSize',16)



%%%%%% NEXT:
%%%%%% Simon wants:
%%% (1) four brain images for the four days
%%% (2) TMS3-BL or TMS3-TMS1
%%% (3) Bar plot with r's for different ROIs. e.g. HC, ATL, IFG

% Left IFG is ROIs 29, 31, 33, 35, 37, 39
% Right IFG is ROIs 30, 32, 34, 36, 38, 40
% Left HC is 215, 217
% Right HC is 216, 218

% atlas_allCorr is 4x246, so the cols are the ROIs

left_IFG = [atlas_allCorr(:,29) atlas_allCorr(:,31) atlas_allCorr(:,33) atlas_allCorr(:,35) atlas_allCorr(:,37) atlas_allCorr(:,39)];    
right_IFG = [atlas_allCorr(:,30) atlas_allCorr(:,32) atlas_allCorr(:,34) atlas_allCorr(:,36) atlas_allCorr(:,38) atlas_allCorr(:,40)];    
left_HC = [atlas_allCorr(:,215) atlas_allCorr(:,217)];
right_HC = [atlas_allCorr(:,216) atlas_allCorr(:,218)];

dayMean_L_IFG = mean(left_IFG,2);
dayMean_R_IFG = mean(right_IFG,2);
dayMean_L_HC = mean(left_HC,2);
dayMean_R_HC = mean(right_HC,2);

set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

figure
bar(dayMean_L_IFG)
xlabel('Days')
ylabel('Correlation')
title('Left IFG')
figure

bar(dayMean_R_IFG)
xlabel('Days')
ylabel('Correlation')
title('Right IFG')
figure

bar(dayMean_L_HC)
xlabel('Days')
ylabel('Correlation')
title('Left HC')
figure

bar(dayMean_R_HC)
xlabel('Days')
ylabel('Correlation')
title('Right HC')
figure


% looks like stim site is 135, which is an inferior parietal lobule ROI
bar(atlas_allCorr(:,135),0.4,'FaceColor',[.9 .1 .4])
xlabel('Days','FontSize',16)
ylabel('Correlation','FontSize',16)
title('Left Inferior Parietal Lobule (stimulation site)','FontSize',16)

%set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

figure
b = bar(atlas_allCorr(:,135),0.4);
b.FaceColor = 'flat';
b.CData(1,:) = [.7 .1 .05];
b.CData(2,:) = [.8 .3 .08];
b.CData(3,:) = [.9 .5 .1];
b.CData(4,:) = [.95 .694 .125];

X = categorical({'TMS Day 1','TMS Day 3'});
X = reordercats(X,{'TMS Day 1','TMS Day 3'});
Y = [atlas_allCorr(2,135) atlas_allCorr(4,135)];

set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
b = bar(X,Y,0.4,'EdgeColor','none');
b.FaceColor = 'flat';
b.CData(1,:) = [.01 .9 .3];
b.CData(2,:) = [.95 .594 .08];
ylabel('Correlation','FontSize',16)
title('Left Inferior Parietal Lobule (stimulation site)','FontSize',16)


% these have 246 corr values each. There are 246 ROIs. There is one r value
% per ROI per day. No trials. Should there be one per trial?

[h,p] = ttest(all_corr_day1,all_corr_day4);


allDays_corr = [all_corr_day1,all_corr_day2,all_corr_day3,all_corr_day4];
days = {'day1';'day2';'day3';'day4'};

[p,tbl,stats] = anova1(allDays_corr,days);


[p,tbl,stats] = anova1(allDays_corr);


%%%% corr for each item and each day. Then ask if there's a significant
%%%% difference between days and put that stat in the brain. Is that a
%%%% linear effect? Don't do an ANOVA treating day like a categorical
%%%% variable. Rather, treat IV like an ordinal variable. IV is day and DV
%%%% is correlation. Could do GLM where IV is ordinal and look for linear
%%%% relationship between correlations and day

% then you take the brainnetome atlas and replaces the values in the atlas
% image (say for ROI 1) with the corr value. 



