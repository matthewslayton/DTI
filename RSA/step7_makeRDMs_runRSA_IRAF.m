%%% this script makes model RDMs and then finds corr between model RDMs and neural RDMs for each ROI

%to do semantic RSA you'll need RDMs for each day (120 items), sorted numerically (1,2,3...)
% go back to step6_makeSemRDMs.m if you don't already have them

clear all



addpath /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RDMs/;


cd /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/
addpath /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/
addpath /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/spm12

%subjects = {'5011','5012','5014'};
subjects = {'5002','5007','5010','5011','5012','5014',...
    '5015','5016','5017','5020','5021','5022','5025','5026'};
% iTBS MCI: 5002, 5007, 5011, 5012, 5016, 5020, 5026
% cTBS MCI: 5001, 5004, 5005 %probably skip these for now
% Sham MCI: 5010, 5021, 5022
% hOA: 5014, 5015, 5017, 5025
% exclude: 5006, 5019

%%%% we need variables that hold all the subjects' data.
% So far we have 120 trials per day * 246 ROIs which is 29,520 per subject
howManyRows = length(subjects) * 120 * 246;

allSubj_day1_IRAF = zeros(howManyRows,14);
allSubj_day2_IRAF = zeros(howManyRows,14);
allSubj_day3_IRAF = zeros(howManyRows,14);
allSubj_day4_IRAF = zeros(howManyRows,14);

% I don't really have a great solution for this. I need to add the
% similarity info and pairIDs, so I'm going to load them separately.
% Trouble is, it does 480 per subject all together, and I need to repeat
% the subject-specific 480 multiple times, so I have to grab them one block
% at a time
subject_counter = 1;

for subj = 1:length(subjects)
    tic
    subject = subjects{subj};
  
    all_betas = dir(sprintf('/Users/matthewslayton/Desktop/ST_localOnly/renamed_betas/%s/*.nii',subject));
    %all_betas = dir(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/renamedBetas/%s/*.nii',subject));
    
    % later on figure out how to make this length variable
    % I know there are 480 betas and 120 per day. I can use something like this
    % to find the day indices and then see where they change, but for today
    % that's not really necessary

    %%%% (1) Sort single-trial beta stimIDs %%%%
    
    % let's grab the stimIDs for a given day. Sort into numerical order
    stimIDs_day1 = zeros(120,1);
    for row = 1:120
        stimIDs_day1(row) = str2double(cell2mat(extractBetween(all_betas(row).name,'stimID','.')));
    end
    % sort stimIDs in ascending order
    day1_sorted = sortrows(stimIDs_day1);
  
    % also want to keep track of which run each stimID goes with
    runMat = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
    3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,...
    3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];

    stimID_and_run = horzcat(stimIDs_day1,runMat');
    % sort based on stimID col
    day1_run_sorted = sortrows(stimID_and_run,1); 
    
    stimIDs_day2 = zeros(120,1);
    for row = 1:120
        stimIDs_day2(row) = str2double(cell2mat(extractBetween(all_betas(row+120).name,'stimID','.')));
    end
    % sort stimIDs
    day2_sorted = sortrows(stimIDs_day2);
    stimID_and_run = horzcat(stimIDs_day2,runMat');
    % sort based on stimID col
    day2_run_sorted = sortrows(stimID_and_run,1); 
    
    stimIDs_day3 = zeros(120,1);
    for row = 1:120
        stimIDs_day3(row) = str2double(cell2mat(extractBetween(all_betas(row+240).name,'stimID','.')));
    end
    % sort stimIDs
    day3_sorted = sortrows(stimIDs_day3);
    stimID_and_run = horzcat(stimIDs_day3,runMat');
    %sort based on stimID col
    day3_run_sorted = sortrows(stimID_and_run,1); 
    
    stimIDs_day4 = zeros(120,1);
    for row = 1:120
        stimIDs_day4(row) = str2double(cell2mat(extractBetween(all_betas(row+360).name,'stimID','.')));
    end
    % sort stimIDs
    day4_sorted = sortrows(stimIDs_day4);
    stimID_and_run = horzcat(stimIDs_day4,runMat');
    %sort based on stimID col
    day4_run_sorted = sortrows(stimID_and_run,1); 
    
    IDs_tbl = readtable('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/reference_spreadsheets/dinoObjectIDs_851.xlsx');
    % has to be in alphabetical order so it matches the order the VGG layers were made
  
    % rows and cols to take from the big 850x850 RDM to make individual 120x120 RDMs
    day1_indices = zeros(120,1);
    day2_indices = zeros(120,1);
    day3_indices = zeros(120,1);
    day4_indices = zeros(120,1);
    for row = 1:120
        day1_indices(row) = find(IDs_tbl{:,1}==stimIDs_day1(row)); %find the ID num in the first col of the table
        day2_indices(row) = find(IDs_tbl{:,1}==stimIDs_day2(row)); %find the ID num in the first col of the table
        day3_indices(row) = find(IDs_tbl{:,1}==stimIDs_day3(row)); %find the ID num in the first col of the table
        day4_indices(row) = find(IDs_tbl{:,1}==stimIDs_day4(row)); %find the ID num in the first col of the table
    end
    % here I'm asking which of the 851 objects do I include from the VGG layer RDMs
    day1_ind_sorted = sortrows(day1_indices);
    day2_ind_sorted = sortrows(day2_indices);
    day3_ind_sorted = sortrows(day3_indices);
    day4_ind_sorted = sortrows(day4_indices);

    addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/vgg16_19layer_outputs/
    load Layer_3.mat %851x851 in alphabetical order
    load Layer_10.mat %I'm sorry, how do we read the layers off the diagram? 
    load Layer_18.mat %final max pooling

    day1_layer_3_RDM = Layer_3(day1_ind_sorted,day1_ind_sorted);
    day2_layer_3_RDM = Layer_3(day1_ind_sorted,day2_ind_sorted);
    day3_layer_3_RDM = Layer_3(day1_ind_sorted,day3_ind_sorted);
    day4_layer_3_RDM = Layer_3(day1_ind_sorted,day4_ind_sorted);

    day1_layer_10_RDM = Layer_10(day1_ind_sorted,day1_ind_sorted);
    day2_layer_10_RDM = Layer_10(day1_ind_sorted,day2_ind_sorted);
    day3_layer_10_RDM = Layer_10(day1_ind_sorted,day3_ind_sorted);
    day4_layer_10_RDM = Layer_10(day1_ind_sorted,day4_ind_sorted);

    day1_layer_18_RDM = Layer_18(day1_ind_sorted,day1_ind_sorted);
    day2_layer_18_RDM = Layer_18(day1_ind_sorted,day2_ind_sorted);
    day3_layer_18_RDM = Layer_18(day1_ind_sorted,day3_ind_sorted);
    day4_layer_18_RDM = Layer_18(day1_ind_sorted,day4_ind_sorted);

    
    %%%% (2) Load the behavioral info %%%%
    
    % this extracts cols grouped by data type so you don't get weird errors
    %addpath /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/
    % wouldn't hurt to double check and see if these are sorted in sub_no -> day_no -> EncRun -> stimID
    [num,txt,raw] = xlsread('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/reference_spreadsheets/netTMS_subMem_noNames.xlsx','CRET'); %no object name col
    num_cret = num;
    
    [num,txt,raw] = xlsread('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/reference_spreadsheets/netTMS_subMem_noNames.xlsx','PRET'); %no object name col
    num_pret = num;
    
    % CRET is 160 and PRET is 120. That's because CRET has lures.
    % We need to exclude those
    %                                   sub_no                        %day_no             EncRun
    subMem_CRET_day1 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==1 & num_cret(:,6)~=999,:);
    subMem_CRET_day2 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==2 & num_cret(:,6)~=999,:);
    subMem_CRET_day3 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==3 & num_cret(:,6)~=999,:);
    subMem_CRET_day4 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==4 & num_cret(:,6)~=999,:);

    subMem_PRET_day1 = num_pret(num_pret(:,1)==str2double(subject) & num_pret(:,2)==1,:);
    subMem_PRET_day2 = num_pret(num_pret(:,1)==str2double(subject) & num_pret(:,2)==2,:);
    subMem_PRET_day3 = num_pret(num_pret(:,1)==str2double(subject) & num_pret(:,2)==3,:);
    subMem_PRET_day4 = num_pret(num_pret(:,1)==str2double(subject) & num_pret(:,2)==4,:);

    PRET_SR_day1 = subMem_PRET_day1(:,7);
    PRET_SR_day2 = subMem_PRET_day2(:,7);
    PRET_SR_day3 = subMem_PRET_day3(:,7);
    PRET_SR_day4 = subMem_PRET_day4(:,7);

    %%%% (3) Load the model RDMs and prepare them %%%%
    % semantic RDMs were made in the previous step: step6_makeSemRDMs.m
    % visual RDMs are made with Ricky's script, vgg16.py
    % For IRAF we NaN the diagonal and NaN items that appeared in the same run
    % If we were doing regular RSA (where you do corrcoef for the entire RDM and not just one row at a time) you
    % have the NaN half of it. "triu(day1_RDM)" gives you the upper triangular half of the matrix

    %%% semantic RDM -- feature norms
    addpath(strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_RDMs/',subject))
    load(strcat(subject,'_day1_RDM.mat')) %which rows have NaNs?
    % change the diagonal of 1s to NaNs
    day1_RDM(logical(eye(size(day1_RDM)))) = NaN;
    % turn the bottom triangle of the RDM to 0s
    %%%%% for IRAF we do the whole thing. For regular RSA, we get the upper half triangular half
    %day1_RDM = triu(day1_RDM); %get upper triangular part of matrix
    % turn those 0s into NaNs
    day1_RDM(day1_RDM==0)=NaN;
    
    %we have a little more nan-ing to do. for every row, nan the
    %cell where the item col is in the same run
    for row = 1:length(day1_RDM) 
        for col = 1:length(day1_RDM)
            if day1_run_sorted(row,2) == day1_run_sorted(col,2) %if the items are from the same run
                day1_RDM(row,col) = NaN;
            end
        end
    end
    
    load(strcat(subject,'_day2_RDM.mat'))
    day2_RDM(logical(eye(size(day2_RDM)))) = NaN;
    %day2_RDM = triu(day2_RDM);
    day2_RDM(day2_RDM==0)=NaN;
    for row = 1:length(day2_RDM) 
        for col = 1:length(day2_RDM)
            if day2_run_sorted(row,2) == day2_run_sorted(col,2) %if the items are from the same run
                day2_RDM(row,col) = NaN;
            end
        end
    end
    
    load(strcat(subject,'_day3_RDM.mat'))
    day3_RDM(logical(eye(size(day3_RDM)))) = NaN;
    %day3_RDM = triu(day3_RDM);
    day3_RDM(day3_RDM==0)=NaN;
    for row = 1:length(day3_RDM) 
        for col = 1:length(day3_RDM)
            if day3_run_sorted(row,2) == day3_run_sorted(col,2) 
                day3_RDM(row,col) = NaN;
            end
        end
    end
    
    load(strcat(subject,'_day4_RDM.mat'))
    day4_RDM(logical(eye(size(day4_RDM)))) = NaN;
    %day4_RDM = triu(day4_RDM); 
    day4_RDM(day4_RDM==0)=NaN;
    for row = 1:length(day4_RDM) 
        for col = 1:length(day4_RDM)
            if day4_run_sorted(row,2) == day4_run_sorted(col,2) %if the items are from the same run
                day4_RDM(row,col) = NaN;
            end
        end
    end
    
    %%% visual RDM -- VGG16
    % DAY 1
    % layer 3
    % change the diagonal of 1s to NaNs
    day1_layer_3_RDM(logical(eye(size(day1_layer_3_RDM)))) = NaN;
    % turn the bottom triangle of the RDM to 0s
    %day1_layer_3_RDM = triu(day1_layer_3_RDM);
    % turn those 0s into NaNs
    day1_layer_3_RDM(day1_layer_3_RDM==0)=NaN;
    for row = 1:length(day1_layer_3_RDM) 
        for col = 1:length(day1_layer_3_RDM)
            if day1_run_sorted(row,2) == day1_run_sorted(col,2) %if the items are from the same run
                day1_layer_3_RDM(row,col) = NaN;
            end
        end
    end
    % layer 10
    day1_layer_10_RDM(logical(eye(size(day1_layer_10_RDM)))) = NaN;
   % day1_layer_10_RDM = triu(day1_layer_10_RDM);
    day1_layer_10_RDM(day1_layer_10_RDM==0)=NaN;
    for row = 1:length(day1_layer_10_RDM) 
        for col = 1:length(day1_layer_10_RDM)
            if day1_run_sorted(row,2) == day1_run_sorted(col,2) 
                day1_layer_10_RDM(row,col) = NaN;
            end
        end
    end
    % layer 18
    day1_layer_18_RDM(logical(eye(size(day1_layer_18_RDM)))) = NaN;
    %day1_layer_18_RDM = triu(day1_layer_18_RDM);
    day1_layer_18_RDM(day1_layer_18_RDM==0)=NaN;
    for row = 1:length(day1_layer_18_RDM) 
        for col = 1:length(day1_layer_18_RDM)
            if day1_run_sorted(row,2) == day1_run_sorted(col,2) 
                day1_layer_18_RDM(row,col) = NaN;
            end
        end
    end
    % DAY 2
    % layer 3
    day2_layer_3_RDM(logical(eye(size(day2_layer_3_RDM)))) = NaN;
    %day2_layer_3_RDM = triu(day2_layer_3_RDM);
    day2_layer_3_RDM(day2_layer_3_RDM==0)=NaN;
    for row = 1:length(day2_layer_3_RDM) 
        for col = 1:length(day2_layer_3_RDM)
            if day2_run_sorted(row,2) == day2_run_sorted(col,2)
                day2_layer_3_RDM(row,col) = NaN;
            end
        end
    end
    % layer 10
    day2_layer_10_RDM(logical(eye(size(day2_layer_10_RDM)))) = NaN;
    %day2_layer_10_RDM = triu(day2_layer_10_RDM);
    day2_layer_10_RDM(day2_layer_10_RDM==0)=NaN;
    for row = 1:length(day2_layer_10_RDM) 
        for col = 1:length(day2_layer_10_RDM)
            if day2_run_sorted(row,2) == day2_run_sorted(col,2) 
                day2_layer_10_RDM(row,col) = NaN;
            end
        end
    end
    % layer 18
    day2_layer_18_RDM(logical(eye(size(day2_layer_18_RDM)))) = NaN;
    %day2_layer_18_RDM = triu(day2_layer_18_RDM);
    day2_layer_18_RDM(day2_layer_18_RDM==0)=NaN;
    for row = 1:length(day2_layer_18_RDM) 
        for col = 1:length(day2_layer_18_RDM)
            if day2_run_sorted(row,2) == day2_run_sorted(col,2) 
                day2_layer_18_RDM(row,col) = NaN;
            end
        end
    end            
    % DAY 3
    % layer 3
    day3_layer_3_RDM(logical(eye(size(day3_layer_3_RDM)))) = NaN;
    %day3_layer_3_RDM = triu(day3_layer_3_RDM);
    day3_layer_3_RDM(day3_layer_3_RDM==0)=NaN;
    for row = 1:length(day3_layer_3_RDM) 
        for col = 1:length(day3_layer_3_RDM)
            if day3_run_sorted(row,2) == day3_run_sorted(col,2)
                day3_layer_3_RDM(row,col) = NaN;
            end
        end
    end
    % layer 10
    day3_layer_10_RDM(logical(eye(size(day3_layer_10_RDM)))) = NaN;
    %day3_layer_10_RDM = triu(day3_layer_10_RDM);
    day3_layer_10_RDM(day3_layer_10_RDM==0)=NaN;
    for row = 1:length(day3_layer_10_RDM) 
        for col = 1:length(day3_layer_10_RDM)
            if day3_run_sorted(row,2) == day3_run_sorted(col,2) 
                day3_layer_10_RDM(row,col) = NaN;
            end
        end
    end
    % layer 18
    day3_layer_18_RDM(logical(eye(size(day3_layer_18_RDM)))) = NaN;
    %day3_layer_18_RDM = triu(day3_layer_18_RDM);
    day3_layer_18_RDM(day3_layer_18_RDM==0)=NaN;
    for row = 1:length(day3_layer_18_RDM) 
        for col = 1:length(day3_layer_18_RDM)
            if day3_run_sorted(row,2) == day3_run_sorted(col,2) 
                day3_layer_18_RDM(row,col) = NaN;
            end
        end
    end            
    % DAY 4
    % layer 3
    day4_layer_3_RDM(logical(eye(size(day4_layer_3_RDM)))) = NaN;
    %day4_layer_3_RDM = triu(day4_layer_3_RDM);
    day4_layer_3_RDM(day4_layer_3_RDM==0)=NaN;
    for row = 1:length(day4_layer_3_RDM) 
        for col = 1:length(day4_layer_3_RDM)
            if day4_run_sorted(row,2) == day4_run_sorted(col,2)
                day4_layer_3_RDM(row,col) = NaN;
            end
        end
    end
    % layer 10
    day4_layer_10_RDM(logical(eye(size(day4_layer_10_RDM)))) = NaN;
    %day4_layer_10_RDM = triu(day4_layer_10_RDM);
    day4_layer_10_RDM(day4_layer_10_RDM==0)=NaN;
    for row = 1:length(day4_layer_10_RDM) 
        for col = 1:length(day4_layer_10_RDM)
            if day4_run_sorted(row,2) == day4_run_sorted(col,2) 
                day4_layer_10_RDM(row,col) = NaN;
            end
        end
    end
    % layer 18
    day4_layer_18_RDM(logical(eye(size(day4_layer_18_RDM)))) = NaN;
    %day4_layer_18_RDM = triu(day4_layer_18_RDM);
    day4_layer_18_RDM(day4_layer_18_RDM==0)=NaN;
    for row = 1:length(day4_layer_18_RDM) 
        for col = 1:length(day4_layer_18_RDM)
            if day4_run_sorted(row,2) == day4_run_sorted(col,2) 
                day4_layer_18_RDM(row,col) = NaN;
            end
        end
    end


    %%%% (4) Run RSA. We need to do this for all 246 brainnetome ROIs %%%%

    addpath(strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/'));
    IRAF_sem_day1 = zeros(120,246); %trial by ROI
    IRAF_layer3_day1 = zeros(120,246);
    IRAF_layer10_day1 = zeros(120,246);
    IRAF_layer18_day1 = zeros(120,246);
   
    for mat = 1:246 %246 ROIs
        % load the brain RDM
        fileName = sprintf('%s_ROI%03d_Day1.mat',subject,mat);
        load(fileName)
        % change the diagonal of 1s to NaNs
        R(logical(eye(size(R)))) = NaN;
        % turn the bottom triangle of the RDM to 0s
        %R = triu(R);
        % turn those 0s into NaNs
        R(R==0)=NaN;
            
        for row = 1:size(R,1) %rows
            try
                % we have one semantic RDM and three visual RDMs
                % day1_RDM, day1_layer_3_RDM, day1_layer_10_RDM,day1_layer_18_RDM
                currCorr = corrcoef(day1_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_sem_day1(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day1_layer_3_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer3_day1(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day1_layer_10_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer10_day1(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day1_layer_18_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer18_day1(row,mat) = currCorr(1,2);
            
            catch
                IRAF_sem_day1(row,mat) = NaN;
                IRAF_layer3_day1(row,mat) = NaN;
                IRAF_layer10_day1(row,mat) = NaN;
                IRAF_layer18_day1(row,mat) = NaN;
            end %try-catch
        end %row loop for RDMs
        clear R
        clear R_clean
        clear ROIvals
        clear StimID 
    end %mat loop

    %%% Day 2
    IRAF_sem_day2 = zeros(120,246); 
    IRAF_layer3_day2 = zeros(120,246);
    IRAF_layer10_day2 = zeros(120,246);
    IRAF_layer18_day2 = zeros(120,246);
    for mat = 1:246
        fileName = sprintf('%s_ROI%03d_Day2.mat',subject,mat);
        load(fileName)

        % change the diagonal of 1s to NaNs
        R(logical(eye(size(R)))) = NaN;
        % turn the bottom triangle of the RDM to 0s
        %R = triu(R);
        % turn those 0s into NaNs
        R(R==0)=NaN;
            
        for row = 1:size(R,1) %rows
            try
                currCorr = corrcoef(day2_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_sem_day2(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day2_layer_3_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer3_day2(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day2_layer_10_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer10_day2(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day2_layer_18_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer18_day2(row,mat) = currCorr(1,2);
            
            catch
                IRAF_sem_day2(row,mat) = NaN;
                IRAF_layer3_day2(row,mat) = NaN;
                IRAF_layer10_day2(row,mat) = NaN;
                IRAF_layer18_day2(row,mat) = NaN;
            end %try-catch
        end %row loop for RDMs
        clear R
        clear R_clean
        clear ROIvals
        clear StimID 
    end %mat loop

    %%% Day 3
    IRAF_sem_day3 = zeros(120,246); 
    IRAF_layer3_day3 = zeros(120,246);
    IRAF_layer10_day3 = zeros(120,246);
    IRAF_layer18_day3 = zeros(120,246);
    for mat = 1:246
        fileName = sprintf('%s_ROI%03d_Day3.mat',subject,mat);
        load(fileName)

        % change the diagonal of 1s to NaNs
        R(logical(eye(size(R)))) = NaN;
        % turn the bottom triangle of the RDM to 0s
        %R = triu(R);
        % turn those 0s into NaNs
        R(R==0)=NaN;
            
        for row = 1:size(R,1) %rows
            try
                currCorr = corrcoef(day3_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_sem_day3(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day3_layer_3_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer3_day3(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day3_layer_10_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer10_day3(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day3_layer_18_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer18_day3(row,mat) = currCorr(1,2);
            
            catch
                IRAF_sem_day3(row,mat) = NaN;
                IRAF_layer3_day3(row,mat) = NaN;
                IRAF_layer10_day3(row,mat) = NaN;
                IRAF_layer18_day3(row,mat) = NaN;
            end %try-catch
        end %row loop for RDMs
        clear R
        clear R_clean
        clear ROIvals
        clear StimID 
    end %mat loop

    %%% Day 4
    IRAF_sem_day4 = zeros(120,246); 
    IRAF_layer3_day4 = zeros(120,246);
    IRAF_layer10_day4 = zeros(120,246);
    IRAF_layer18_day4 = zeros(120,246);
    for mat = 1:246
        fileName = sprintf('%s_ROI%03d_Day4.mat',subject,mat);
        load(fileName)
        % change the diagonal of 1s to NaNs
        R(logical(eye(size(R)))) = NaN;
        % turn the bottom triangle of the RDM to 0s
        %R = triu(R);
        % turn those 0s into NaNs
        R(R==0)=NaN;
            
        for row = 1:size(R,1) %rows
            try
                currCorr = corrcoef(day4_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_sem_day4(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day4_layer_3_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer3_day4(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day4_layer_10_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer10_day4(row,mat) = currCorr(1,2);
    
                currCorr = corrcoef(day4_layer_18_RDM(row,:),R(row,:),'rows','pairwise');
                IRAF_layer18_day4(row,mat) = currCorr(1,2);
            
            catch
                IRAF_sem_day4(row,mat) = NaN;
                IRAF_layer3_day4(row,mat) = NaN;
                IRAF_layer10_day4(row,mat) = NaN;
                IRAF_layer18_day4(row) = NaN;
            end %try-catch
        end %row loop for RDMs
        clear R
        clear R_clean
        clear ROIvals
        clear StimID 
    end %mat loop

%%%%%%% NOTE: if you're not doing IRAF, it should look like this:

%    %%% Day 2
%    currFolder = strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/',subName,'_Day2/');
%    addpath(currFolder)
%    day2_ROIs = dir(strcat(currFolder,'*.mat'));
%    addpath /Users/matthewslayton/Desktop/ST_localOnly/RSA_RDMs
%    load(strcat(subject,'_day2_RDM.mat')) %which rows have NaNs?
%
%    % change the diagonal of 1s to NaNs
%    day2_RDM(logical(eye(size(day2_RDM)))) = NaN;
%    % turn the bottom triangle of the RDM to 0s
%    day2_RDM = triu(day2_RDM);
%    % turn those 0s into NaNs
%    day2_RDM(day2_RDM==0)=NaN;
%
%    all_corr_day2 = zeros(246,1);
%    for mat = 1:246
%        try
%            load(day2_ROIs(mat).name) %loads R, ROIvals, stimID
%            % change the diagonal of 1s to NaNs
%            R(logical(eye(size(R)))) = NaN;
%            % turn the bottom triangle of the RDM to 0s
%            R = triu(R);
%            % turn those 0s into NaNs
%            R(R==0)=NaN;
%            
%            currCorr = corrcoef(day2_RDM,R,'rows','complete');
%            all_corr_day2(mat) = currCorr(1,2);
%        catch
%            all_corr_day2(mat) = NaN; %if I can't load the mat file, just add NaN
%        end
%        clear R
%        clear R_clean
%        clear ROIvals
%        clear StimID 
%    end %mat loop

%%%%%% then to output everything
%    %destination = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_corr/%s/',subject);
%    destination = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_corr/%s/',subject);
%
%    % make output folder if it's not already there
%    if ~exist(destination,'dir'); mkdir(destination); end
%
%    save(strcat(destination,'all_corr_day1.mat'),'all_corr_day1')
%    save(strcat(destination,'all_corr_day2.mat'),'all_corr_day2')
%    save(strcat(destination,'all_corr_day3.mat'),'all_corr_day3')
%    save(strcat(destination,'all_corr_day4.mat'),'all_corr_day4')
%%%% though I have to admit, even if I were doing 'vanilla' RSA, an output table is a nice idea


    %%%% (5) Put everything into one massive table %%%%

    % first set up doubles
    subMem_day1_IRAF = zeros(120*246,14);
    subMem_day2_IRAF = zeros(120*246,14);
    subMem_day3_IRAF = zeros(120*246,14);
    subMem_day4_IRAF = zeros(120*246,14);
    % note, we dont' need separate tables for PRET. The items, brain data, and RSA are all about Encoding.
    % we need two columns that tell us whether that item was subsequently remembered during CRET and PRET

    counter = 1;
    for num = 1:246 %all ROIs

        subMem_day1_IRAF(counter:counter+119,:) = horzcat(subMem_day1,PRET_SR_day1,IRAF_sem_day1(:,num),IRAF_layer3_day1(:,num),IRAF_layer10_day1(:,num),IRAF_layer18_day1(:,num),repmat(num,120,1));
        subMem_day2_IRAF(counter:counter+119,:) = horzcat(subMem_day2,PRET_SR_day2,IRAF_sem_day2(:,num),IRAF_layer3_day2(:,num),IRAF_layer10_day2(:,num),IRAF_layer18_day2(:,num),repmat(num,120,1));
        subMem_day3_IRAF(counter:counter+119,:) = horzcat(subMem_day3,PRET_SR_day3,IRAF_sem_day3(:,num),IRAF_layer3_day3(:,num),IRAF_layer10_day3(:,num),IRAF_layer18_day3(:,num),repmat(num,120,1));
        subMem_day4_IRAF(counter:counter+119,:) = horzcat(subMem_day4,PRET_SR_day4,IRAF_sem_day4(:,num),IRAF_layer3_day4(:,num),IRAF_layer10_day4(:,num),IRAF_layer18_day4(:,num),repmat(num,120,1));

        counter = counter + 120;

    end
    

    % add the subject-specific 29,520 rows of output to the all-subjects
    % array (120 trials * 246 ROIs) that is length(subjects * 29520 long

    allSubj_day1_IRAF(subject_counter:subject_counter+29519,:) = subMem_day1_IRAF;
    allSubj_day2_IRAF(subject_counter:subject_counter+29519,:) = subMem_day2_IRAF;
    allSubj_day3_IRAF(subject_counter:subject_counter+29519,:) = subMem_day3_IRAF;
    allSubj_day4_IRAF(subject_counter:subject_counter+29519,:) = subMem_day4_IRAF;

    subject_counter = subject_counter + 29520;
    

    toc
end %subj loop

destination = '/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/step7_output/';
save(strcat(destination,'allSubj_day1_IRAF.mat'),'allSubj_day1_IRAF')
save(strcat(destination,'allSubj_day2_IRAF.mat'),'allSubj_day2_IRAF')
save(strcat(destination,'allSubj_day3_IRAF.mat'),'allSubj_day3_IRAF')
save(strcat(destination,'allSubj_day4_IRAF.mat'),'allSubj_day4_IRAF')


%%%% PART 2: take Similarity, SimBin, and PairID, which has 6720 rows for
%%%% 480 trials per subject and 14 subjects.

%addpath '/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/step7_output/'
%load allSubj_CRET_day1_IRAF.mat
%load allSubj_CRET_day2_IRAF.mat
%load allSubj_CRET_day3_IRAF.mat
%load allSubj_CRET_day4_IRAF.mat

%%%% PART 2: take Similarity, SimBin, and PairID, which has 6720 rows for
%%%% 480 trials per subject and 14 subjects.

allSubj_day1_IRAF_tbl = array2table(allSubj_day1_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','PRET_SR','sem','vis_l03','vis_l10','vis_l18','ROI'});
allSubj_day2_IRAF_tbl = array2table(allSubj_day2_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','PRET_SR','sem','vis_l03','vis_l10','vis_l18','ROI'});
allSubj_day3_IRAF_tbl = array2table(allSubj_day3_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','PRET_SR','sem','vis_l03','vis_l10','vis_l18','ROI'});
allSubj_day4_IRAF_tbl = array2table(allSubj_day4_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','PRET_SR','sem','vis_l03','vis_l10','vis_l18','ROI'});


% add the similarity, SimBin, and pairID cols
threeMissingCols = readtable('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/reference_spreadsheets/sim_pairID.xlsx');
    % has 6720, 480 trials * 14 subjects
counter = 1;

% make empty table with named cols
headers = {'Similarity','SimBin','pairID'};
allSubjSimPair_day1_tbl = cell2table(cell(0,3),'VariableNames',headers);
allSubjSimPair_day2_tbl = cell2table(cell(0,3),'VariableNames',headers);
allSubjSimPair_day3_tbl = cell2table(cell(0,3),'VariableNames',headers);
allSubjSimPair_day4_tbl = cell2table(cell(0,3),'VariableNames',headers);

for subj = 1:length(subjects)

    % split the sim/pair data by day
    simPair_day1 = threeMissingCols(counter:counter+119,:);
    simPair_day2 = threeMissingCols(counter+120:counter+239,:);
    simPair_day3 = threeMissingCols(counter+240:counter+359,:);
    simPair_day4 = threeMissingCols(counter+360:counter+479,:);

    counter = counter + 480;
    
    combineSimPair_day1_tbl = cell2table(cell(0,3),'VariableNames',headers);
    combineSimPair_day2_tbl = cell2table(cell(0,3),'VariableNames',headers);
    combineSimPair_day3_tbl = cell2table(cell(0,3),'VariableNames',headers);
    combineSimPair_day4_tbl = cell2table(cell(0,3),'VariableNames',headers);
    for num = 1:246
    
        combineSimPair_day1 = vertcat(combineSimPair_day1,simPair_day1);
        combineSimPair_day2 = vertcat(combineSimPair_day2,simPair_day2);
        combineSimPair_day3 = vertcat(combineSimPair_day3,simPair_day3);
        combineSimPair_day4 = vertcat(combineSimPair_day4,simPair_day4);
    
    end


    allSubjSimPair_day1 = vertcat(allSubjSimPair_day1,combineSimPair_day1);
    allSubjSimPair_day2 = vertcat(allSubjSimPair_day2,combineSimPair_day2);
    allSubjSimPair_day3 = vertcat(allSubjSimPair_day3,combineSimPair_day3);
    allSubjSimPair_day4 = vertcat(allSubjSimPair_day4,combineSimPair_day4);

end

allValues_day1 = horzcat(allSubj_day1_IRAF,allSubjSimPair_day1);
allValues_day2 = horzcat(allSubj_day2_IRAF,allSubjSimPair_day2);
allValues_day3 = horzcat(allSubj_day3_IRAF,allSubjSimPair_day3);
allValues_day4 = horzcat(allSubj_day4_IRAF,allSubjSimPair_day4);

allTable = vertcat(allValues_day1,allValues_day2,allValues_day3,allValues_day4);

destination = '/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/IRAF_for_Simon/';
writetable(allTable,strcat(destination,'all_IRAF_output_sep17.csv'),'Delimiter',',')



%%%% (0) load the semantic RDMs %%%%
% they come from: /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP_scripts/make_PCs_features.m

%cd /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS/Analysis_files/;
%addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS/Analysis_files/;
%cd /Users/matthewslayton/Documents/Duke/Simon_Lab/Analysis_files/;
%addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/Analysis_files/;


% I need the current subject and then to repeat 246 times for the total number of ROIs
% /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP_scripts/make_PCs_features.m
% original feature matrix. 995 items sorted by stimID (which is just the row number because alphabetical)
%load features_stimIDorder.mat
% load the corr mat sorted by stimID -- remember, the items are in alphabetical order
%load features_stimID_corrmat.mat

% need to grab the stimIDs used for a given day and select only those rows

% addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/spm12
% addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/mfMRI_v2-master/nifti/;
% set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

%addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/betas/;
%addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/spm12')
%%% later on make this subject-specific, something like strcat('[path]/subject/*.nii')
% find all the .nii.gz files 
%all_betas = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/betas/*.nii.gz');
%addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/betas/;

%%%% (2) Separate the neural RDMs by day %%%%  
    % first put the mat files into day-specific folders so they're easier to grab
    
    %all_ROIs = dir(sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/%s/*.mat',subject));
    %all_ROIs = dir(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/%s/*.mat',subject));
    
    %%% now we're going to sort into separate folders for each day
%     for row = 1:length(all_ROIs)
%         currROI = all_ROIs(row).name;
%         currDay = str2double(cell2mat(extractBetween(currROI,'Day','.mat')));
%         subName = strcat('S',subject(2:end));
%     
%         %outputFolder = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/',subject,'/',subName,'_Day',num2str(currDay),'/');
%         outputFolder = strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/',subName,'_Day',num2str(currDay),'/');
%         % make output folder if it's not already there
%         if ~exist(outputFolder,'dir'); mkdir(outputFolder); end
%         
%         %copyfile(strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/',subject,'/',currROI),outputFolder);
%         copyfile(strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/',currROI),outputFolder);
%     end
%     
%     clear R %neural RDM
%     clear ROIvals %voxels x trials
%     clear StimID %stimIDs that day

% at this point we have the following files (using day 1 as an example)
    %%% day1_run_sorted, which is 120x2, stimID x run it appears in
    %%% day1_ind_sorted, 120x1 the row number in the ID table where that item appears
    %%% I have RSA mats (meaning the neural RDM) for each day and ROI
    % e.g. /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/5002/5002_ROI001_Day1.mat
    %%% I've also loaded the visual RDMs, e.g. day1_layer_3_RDM
    % and I made the semantic RDMs (based on the feature norms) in step5

    %%%% (3) Find the corr values between semantic RDM and neural RDM %%%%


  %(1) Take the big semantic, visual, and brain RDMs and split
    %into SR and SF
    %(2) Then loop through each row of the RDMs and do corrcoef for
    %each row. Save these in the IRAF matrix
    %(3) Btw, need to delete the trialDataOut I don't need and then
    %run steps 1 thorugh 4 for 5025 and 5026
    %(4) Check to see that each RDM is going in stimID order. It's
    %per subject per day, and then stimID order.
    
    %simon reshapes the matrices first which corrcoef may be doing?
    %reshape(R,size(R)*size(R),1)
    
    %%%%%% NOTE: can't just do ascending stimIDs because we have the new items with 1000+ IDs
    % or can't we? Just let them be sorted? it's ok if the object
    % names don't appear in perfect alphabetical order. The goal is
    % to be consistent
    
    %%%%i got the CRET and PRET info and sorted by sub_no -> day_no
    %%%% -> EncRun -> StimID. That gives me the objects presented
    %%%% during encoding (which is what I want) and the most
    %%%% important CRET_SR and PRET_SR cols where it's 1 for a hit,
    %%%% 0 for a miss, and NaN for anything else, including CR, FA,
    %%%% and no response.
    %%% I'd like to check that the stimIDs match and then have
    %%% subject, day, run (i.e. encRun) and the SR col.
    
    %%% if SR and SF are different sizes, the smaller the n the
    %%% more inflated your corr values can be
    
    %%% don't split the RDMs ahead of time. Just do corrcoef row by
    %%% row and add the column of SR/SF
    
    % Subject Trial Model SubMem IRAF-ROI1 IRAF-ROI2 etc
    
    %addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/
    %addpath /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/netTMS_subMem.xlsx
    
    %subMem_tbl = readtable('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/netTMS_subMem.xlsx');
    %subMem_CRET_tbl = subMem_tbl(:,1:8);
    %subMem_PRET_tbl = subMem_tbl(:,9:16);

   
%     subMem_CRET_day2_IRAF = horzcat(subMem_CRET_day2,IRAF_sem_day2,IRAF_layer3_day2,IRAF_layer10_day2,IRAF_layer18_day2); 
%     subMem_CRET_day3_IRAF = horzcat(subMem_CRET_day3,IRAF_sem_day3,IRAF_layer3_day3,IRAF_layer10_day3,IRAF_layer18_day3);  
%     subMem_CRET_day4_IRAF = horzcat(subMem_CRET_day4,IRAF_sem_day4,IRAF_layer3_day4,IRAF_layer10_day4,IRAF_layer18_day4);
%     subMem_PRET_day1_IRAF = horzcat(subMem_PRET_day1,IRAF_sem_day1,IRAF_layer3_day1,IRAF_layer10_day1,IRAF_layer18_day1);
%     subMem_PRET_day2_IRAF = horzcat(subMem_PRET_day2,IRAF_sem_day2,IRAF_layer3_day2,IRAF_layer10_day2,IRAF_layer18_day2);
%     subMem_PRET_day3_IRAF = horzcat(subMem_PRET_day3,IRAF_sem_day3,IRAF_layer3_day3,IRAF_layer10_day3,IRAF_layer18_day3);
%     subMem_PRET_day4_IRAF = horzcat(subMem_PRET_day4,IRAF_sem_day4,IRAF_layer3_day4,IRAF_layer10_day4,IRAF_layer18_day4);

    %%%% change to table

     % note: num doesn't have the object names, but they don't really matter anyway
    %num_cret = num_cret(:,1:7);
    %num_pret = num(:,8:14);
    
    %%%%% something like this will give me just the rows for a
    %%%%% given subject, day, and enc run. Awesome! 
    
    % the goal here is to get my subject, day, encRun-specific
    % info. I have stimIDs and the SR/SF col where SR = 1, SF = 0

    %%%% do these need to separated by encRun?
    %subMem_CRET_day4 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==4 & num_cret(:,7)==1,:);

    %%% by day is fine. We want 120x1
    %%%% hold on now. Sometimes we're missing trials, right?
    %%%% we need the subMems to all have 120 rows
    % for example, 5010 is missing trials 1 through 14 on day 4.
    % also 5016 day4 run3 is corrupted
    % actually, I should just fix this in the spreadsheet!
    % it won't generalize, but truthfully, I would have to spot what's
    % wrong using the Enc trial numbers (which are not currently included
    % in the spreadsheet) or get the original behavioral output mat files,
    % which is probably overkill. Still, for now, since I made the
    % spreadheet manually anyway, I may as well just prepare it properly

    %if size(subMem_PRET_day4,1) ~= 120


    %end

    
    %%%% next, DON'T split the RDMs by subsequent memory. Instead,
    %%%% just run the whole model, get the IRAF value for that row
    %%%% (remember, it's a specific item for that row), and add it
    %%%% to the table. The input is going to be included in the
    %%%% output as well. 
    %%%% One more thing. You have to exclude within-run
    %%%% comparisons. The reason is that brain activity will be
    %%%% more similar during close time points compared with
    %%%% far-away time points, so you want to avoid those
    %%%% comparisons so you don't mess up your results. 
    %%%% to do that, you have to know which items are in the same
    %%%% run. That's why you have the run col sorted by stimID (and
    %%%% the RDMs are already sorted by stimID. Everything is
    %%%% sorted the same way). 
    %%%% so, if you're working on item 1, NaN every other item in
    %%%% that run. Essentially, you're naning out the cells where
    %%%% run 1 items are in the row and column. Essentially you're
    %%%% taking out a square (assuming the items were sorted by
    %%%% run which they're not, but it's a useful way to visualize
    %%%% it). You NaN everything out ahead of running for that
    %%%% subject because each subject saw items in a different
    %%%% order
    
    % At this point,we have 120 rows per day (40 per EncRun), and there are 246 cols for the ROIs
    % We need to grab all of the subject data like subject number and day number and then add columns
    % that info about subsequent memory performance, object similarity when presented as pairs during encoding
    % and of course the RSA correlation values we just calculated

    %%%%%%% LAST STEP
    %%% get those data tables, add the IRAF values and SR/SF col
    % we have IRAF_sem_day1 through 4, IRAF_layer3, 10, 18 for 4 days

    % remember, not only do we have IRAF values for each trial on each day, we ALSO have 246 ROIs
    % I think it would be good to stack everything. So, make an ROI col 1 through 246. You have all the results
    % for each ROI grouped together as default. So, ROIcol would be 1 1 1 1 1 1 etc, 
%     % There are 120 per day, 40 per EncRun. So, we need 1 120 times, 2 120 times, etc.
%     ROIcol = zeros(246*120,1);
%     counter = 1;
%     for num = 1:246
%             currRepeat = repmat(num,120,1);
%             ROIcol(counter:counter+119) = currRepeat;
%             counter = counter + 120;
%     end

    % then we'll have IRAF_sem_day1 etc which are 120x246
    % so, grab each col one at a time and stick them together
    % now, the arrays like subMem_CRET_day1_IRAF are 120x5 each time, so I
    % have to stack them
    % now, subMem_CRET_day1 is just the original content. Day, run, stimID.
    % Have to repeat that


%     sz = [29520 16]; %120 trials 246 ROIs = 29520
%     varTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];         
%     varNames = ["sub_no","day_no","run_no","RET_trial_no","stimID","EncRun","CRET_SR","CR_div_total",'Similarity,','SimBin','pairID',"sem","vis_l03","vis_l10","vis_l18","ROI"];
%     subMem_CRET_day1_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%     subMem_CRET_day2_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%     subMem_CRET_day3_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%     subMem_CRET_day4_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% 
%     subMem_PRET_day1_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%     subMem_PRET_day2_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%     subMem_PRET_day3_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%     subMem_PRET_day4_IRAF_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% 
% 
%     counter = 1;
%     for num = 1:246 %ROIs
% 
%         subMem_CRET_day1_IRAF_tbl(counter:counter+6719,1:13) = subMem_CRET_day1_IRAF;
%         subMem_CRET_day1_IRAF_tbl(counter:counter+6719,14:16) = simPair_day1;
% 
% 
%     end
% 
% 
%     allSubj_CRET_day1_IRAF = zeros(howManyRows,16);
%     allSubj_CRET_day2_IRAF = zeros(howManyRows,16);
%     allSubj_CRET_day3_IRAF = zeros(howManyRows,16);
%     allSubj_CRET_day4_IRAF = zeros(howManyRows,16);
%     allSubj_PRET_day1_IRAF = zeros(howManyRows,16);
%     allSubj_PRET_day2_IRAF = zeros(howManyRows,16);
%     allSubj_PRET_day3_IRAF = zeros(howManyRows,16);
%     allSubj_PRET_day4_IRAF = zeros(howManyRows,16);
% 
%     subMem_CRET_day1_IRAF_tbl = array2table(subMem_CRET_day1_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     subMem_CRET_day2_IRAF_tbl = array2table(subMem_CRET_day2_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     subMem_CRET_day3_IRAF_tbl = array2table(subMem_CRET_day3_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     subMem_CRET_day4_IRAF_tbl = array2table(subMem_CRET_day4_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','CRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     subMem_PRET_day1_IRAF_tbl = array2table(subMem_CRET_day1_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','PRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     subMem_PRET_day2_IRAF_tbl = array2table(subMem_CRET_day2_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','PRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     subMem_PRET_day3_IRAF_tbl = array2table(subMem_CRET_day3_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','PRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     subMem_PRET_day4_IRAF_tbl = array2table(subMem_CRET_day4_IRAF,'VariableNames',{'sub_no','day_no','run_no','trial_no','stimID','EncRun','PRET_SR','CR_div_totalNew','Similarity,','SimBin','pairID','sem','vis_l03','vis_l10','vis_l18','ROI'});
%     
% 
%     destination_sem = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_corr_sem/%s/',subject);
%     destination_vis = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_corr_vis/%s/',subject);
% 
%     % make output folder if it's not already there
%     if ~exist(destination_sem,'dir'); mkdir(destination_sem); end
%     if ~exist(destination_vis,'dir'); mkdir(destination_vis); end
% 
%     save(strcat(destination_sem,'subMEM_CRET_day1_IRAF.mat'),'subMem_CRET_day1_IRAF_tbl')
%     save(strcat(destination_sem,'subMEM_CRET_day2_IRAF.mat'),'subMem_CRET_day2_IRAF_tbl')
%     save(strcat(destination_sem,'subMEM_CRET_day3_IRAF.mat'),'subMem_CRET_day3_IRAF_tbl')
%     save(strcat(destination_sem,'subMEM_CRET_day4_IRAF.mat'),'subMem_CRET_day4_IRAF_tbl')
%     save(strcat(destination_vis,'subMEM_PRET_day1_IRAF.mat'),'subMem_PRET_day1_IRAF_tbl')
%     save(strcat(destination_vis,'subMEM_PRET_day2_IRAF.mat'),'subMem_PRET_day2_IRAF_tbl')
%     save(strcat(destination_vis,'subMEM_PRET_day3_IRAF.mat'),'subMem_PRET_day3_IRAF_tbl')
%     save(strcat(destination_vis,'subMEM_PRET_day4_IRAF.mat'),'subMem_PRET_day4_IRAF_tbl')

       %%%% later on let's automate this so we can check future subjects for
    %%%% extra trials. I'm doing this manual shitty correction because
    %%%% of time pressure.
%% the issue is that even if CRET has extra trials, some don't match what was presented during encoding!
%%% so, the solution for now will be to cut rows or add NaN rows in the
%%% spreadsheet. Later I'll have to check CRET and PRET against ENC and see
%%% what the discrepancies are. For now let's just cut everything to 120 so
%%% it all fits together. Need to check Enc output_tbl for ID1 and ID2 and
%%% see where the differences are from the stimID col in CRET and PRET.
%%% Then can remove incorrect rows a=or



    % you would look for how many of each encRun doing something like this 
%     for day = 1:4
%         encRun_1 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==day & num_cret(:,6)==1,:);
%         encRun_2 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==day & num_cret(:,6)==2,:);
%         encRun_3 = num_cret(num_cret(:,1)==str2double(subject) & num_cret(:,2)==day & num_cret(:,6)==3,:);
% 
%         howManyOnes = repmat(1,1,encRun_1);
%         howManyTwos = repmat(2,1,encRun_2);
%         howManyThrees = repmat(3,1,encRun_3);
% 
%         currRunMat = horzcat(howManyOnes,howManyTwos,howManyThrees);
%     end
    % I need one day at a time. So, what's between day and _
    % day_indices = zeros(480,1);
    % for row = 1:480 
    %     day_indices(row) = str2double(cell2mat(extractBetween(all_betas(row).name,'day','_')));
    % end
%     
%  if strcmp(subject,'5011') == 1 %encRun 3 has an extra non-lure trial
%         stimIDs_day3 = zeros(121,1);
%         for row = 1:121
%             stimIDs_day3(row) = str2double(cell2mat(extractBetween(all_betas(row+240).name,'stimID','.')));
%         end
%         specialRunMat = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
%         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
%         2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
%         2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
%         3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,...
%         3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];
%         % sort stimIDs
%         day3_sorted = sortrows(stimIDs_day3);
%         stimID_and_run = horzcat(stimIDs_day3,specialRunMat');
%         %sort based on stimID col
%         day3_run_sorted = sortrows(stimID_and_run,1); 
% 
%     elseif strcmp(subject,'5016') == 1
%         stimIDs_day3 = zeros(122,1);
%         for row = 1:122
%             stimIDs_day3(row) = str2double(cell2mat(extractBetween(all_betas(row+240).name,'stimID','.')));
%         end
%         specialRunMat = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
%         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
%         2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
%         2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
%         3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,...
%         3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];
%         % sort stimIDs
%         day3_sorted = sortrows(stimIDs_day3);
%         stimID_and_run = horzcat(stimIDs_day3,specialRunMat');
%         %sort based on stimID col
%         day3_run_sorted = sortrows(stimID_and_run,1); 
% 
%     elseif strcmp(subject,'5014') == 1
%         stimIDs_day3 = zeros(119,1);
%         for row = 1:121
%             stimIDs_day3(row) = str2double(cell2mat(extractBetween(all_betas(row+240).name,'stimID','.')));
%         end
%     specialRunMat = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
%     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
%     2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
%     2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,...
%     3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,...
%     3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];
%     % sort stimIDs
%     day3_sorted = sortrows(stimIDs_day3);
%     stimID_and_run = horzcat(stimIDs_day3,specialRunMat');
%     %sort based on stimID col
%     day3_run_sorted = sortrows(stimID_and_run,1); 
%     else
%         stimIDs_day3 = zeros(120,1);
%         for row = 1:120
%             stimIDs_day3(row) = str2double(cell2mat(extractBetween(all_betas(row+240).name,'stimID','.')));
%         end
%     % sort stimIDs
%     day3_sorted = sortrows(stimIDs_day3);
%     stimID_and_run = horzcat(stimIDs_day3,runMat');
%     %sort based on stimID col
%     day3_run_sorted = sortrows(stimID_and_run,1); 
%     end

%     if subject == '5016' %problem where day 3 has two extra trials in EncRun 1
% 
%         IRAF_sem_day3_cret = vertcat(IRAF_sem_day3,NaN(2,1));
%         IRAF_layer3_day3_cret = vertcat(IRAF_layer3_day3,NaN(2,1));
%         IRAF_layer10_day3_cret = vertcat(IRAF_layer10_day3,NaN(2,1));
%         IRAF_layer18_day3_cret = vertcat(IRAF_layer18_day3,NaN(2,1));
%         subMem_CRET_day3_IRAF = horzcat(subMem_CRET_day3,IRAF_sem_day3_cret,IRAF_layer3_day3_cret,IRAF_layer10_day3_cret,IRAF_layer18_day3_cret);
% %     elseif subject == '5011'
% %         IRAF_sem_day3_cret = vertcat(IRAF_sem_day3,NaN(1,1));
% %         IRAF_layer3_day3_cret = vertcat(IRAF_layer3_day3,NaN(1,1));
% %         IRAF_layer10_day3_cret = vertcat(IRAF_layer10_day3,NaN(1,1));
% %         IRAF_layer18_day3_cret = vertcat(IRAF_layer18_day3,NaN(1,1));
% %         subMem_CRET_day3_IRAF = horzcat(subMem_CRET_day3,IRAF_sem_day3_cret,IRAF_layer3_day3_cret,IRAF_layer10_day3_cret,IRAF_layer18_day3_cret);
% %     
%     elseif subject == '5014'
%         subMem_CRET_day3_cret = vertcat(subMem_CRET_day3,NaN(1,8));
%         subMem_CRET_day3_IRAF = horzcat(subMem_CRET_day3_cret,IRAF_sem_day3,IRAF_layer3_day3,IRAF_layer10_day3,IRAF_layer18_day3);
%     else
%         subMem_CRET_day3_IRAF = horzcat(subMem_CRET_day3,IRAF_sem_day3,IRAF_layer3_day3,IRAF_layer10_day3,IRAF_layer18_day3);
%     end


% % subName = strcat('S',subject(2:end));
% %%% Day 1
% %currFolder = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/',subject,'/',subName,'_Day1/');
% currFolder = strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/',subName,'_Day1/');
% addpath(currFolder)
% day1_ROIs = dir(strcat(currFolder,'*.mat'));
% addpath /Users/matthewslayton/Desktop/ST_localOnly/RSA_RDMs
% load(strcat(subject,'_day1_RDM.mat')) %which rows have NaNs?
% 
% %day1_RDM_original = day1_RDM;
% 
% addpath /Users/matthewslayton/Desktop/ST_localOnly/RSA_RDMs
% load(strcat(subject,'_day1_RDM.mat')) %which rows have NaNs?
% % change the diagonal of 1s to NaNs
% day1_RDM(logical(eye(size(day1_RDM)))) = NaN;
% % turn the bottom triangle of the RDM to 0s
% day1_RDM = triu(day1_RDM); %get uoper triangular part of matrix
% % turn those 0s into NaNs
% day1_RDM(day1_RDM==0)=NaN;
% 
% % currCorr = corrcoef(brainRDM,modelRDM,'rows','complete');
% 
% %day1_RDM_clean = day1_RDM(1:119,1:119);
% % day1_RDM_clean = day1_RDM;
% % remove cols that are all NaN
% % day1_RDM_clean(:,all(isnan(day1_RDM),1)) = [];
% % remove rows that are all NaN
% % day1_RDM_clean(all(isnan(day1_RDM),2),:) = [];
%need col that says subsequently remembered or forgotten in CRET and PRET

% the quick and dirty way is comparing one item with all items
% better to compare among only the remembered and only the forgotten

%%% or you can just find the indices for SR or for SF, subset the big RDM, and then do corrcoef. 
% indices you want so you subset the big RDM. 
%%% so you have two sematic RDMs, one for SR and one for SF, and then two for visual RDMs, for SR and SF
%% simon NaNs out the rows and cols he doesn't need for the analysis. That works too


%%% simon loops through for item
                        %    for model (but I may do these separately)

%%% output can be two cols, stimID, correlation, or better yet add day col




%%%% before continuing, we have to NaN out the 1s on the diagonal
% Nan the diagonal RDM(logical(eye(size(RDM))))=NaN;
% getting rid of the lower triangle RDM= triu(RDM);
% corrcoef(RDM1,RDM2,'rows','complete');

% RDM(logical(eye(size(RDM))))=NaN;
% RDM= triu(RDM);
% RDM(RDM==0)=NaN;
% currCorr = corrcoef(brainRDM,modelRDM,'rows','complete');

    % grab the RDM row that matches the stimID and make a day-specific matrix
 %   objLibrary = readtable('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/library_of_dinolab_objects.xlsx');
 %   objIDCol = objLibrary.ID;
 %   objNameCol = objLibrary.item;

%%%%% THIS IS NOT NECESSARY. YOU CAN JUST INDEX THE SUBSET YOU NEED, e.g. RDM([1,7,11],[1,7,11])

    % NOTE: my 995x995 RDM is already in stimID order (it's alphabetical)
    % all I have to do is identify the 120 objects from that day and we're good
%     day1_feat = zeros(120,5520);
%     day2_feat = zeros(120,5520);
%     day3_feat = zeros(120,5520);
%     day4_feat = zeros(120,5520);
%     
%     for num = 1:120
%         if stimIDs_day1(num) > 995 %new item, beyond the 995 in dino lab set
%             day1_feat(num,:) = NaN(1,5520);
%         else 
%             day1_feat(num,:) = features_stimIDorder{stimIDs_day1(num),:};
%         end
% 
%         if stimIDs_day2(num) > 995 
%             day2_feat(num,:) = NaN(1,5520);
%         else 
%             day2_feat(num,:) = features_stimIDorder{stimIDs_day2(num),:};
%         end
% 
%         if stimIDs_day3(num) > 995 
%             day3_feat(num,:) = NaN(1,5520);
%         else 
%             day3_feat(num,:) = features_stimIDorder{stimIDs_day3(num),:};
%         end
% 
%         if stimIDs_day4(num) > 995 
%             day4_feat(num,:) = NaN(1,5520);
%         else 
%             day4_feat(num,:) = features_stimIDorder{stimIDs_day4(num),:};
%         end
%     end
% 
%     day1_RDM = corrcoef(day1_feat');
%     day2_RDM = corrcoef(day2_feat');
%     day3_RDM = corrcoef(day3_feat');
%     day4_RDM = corrcoef(day4_feat');
% 
%     %cd(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_RDMs/%s/',subject))
%     destination_RDM = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_RDMs/%s/',subject);
%     save(strcat(destination_RDM,subject,'_day1_RDM.mat'),'day1_RDM')
%     save(strcat(destination_RDM,subject,'_day2_RDM.mat'),'day2_RDM')
%     save(strcat(destination_RDM,subject,'_day3_RDM.mat'),'day3_RDM')
%     save(strcat(destination_RDM,subject,'_day4_RDM.mat'),'day4_RDM')

    %%%% option 1 is to make the model RDMs the same size as num of betas, or
    %%%% betas same size as model RDMs.
    %%% Cortney does it afterward.

    % NOTE: my 995x995 RDM is based on the STAMP IDs, so I have to add the dinolab IDs
    %featMat_sortedByID_namesID has two cols, 'concept' which has the names and
    %'id' which has the STAMP IDs. So, I need to take the object ID from the
    %beta name, match it to the concept col
    
    %%%% remember, an RDM by this method takes the feature matrix and does
    %%%% corrcoef. So really, I have to find the 120 items in question so it's
    %%%% 120x5520 and then do corrcoef


 %%%% option 1 is to make the model RDMs the same size as num of betas, or
    %%%% betas same size as model RDMs.
    %%% Cortney does it afterward.
    
    % the mat outputs have data for one ROI.
    % R is the neural pattern similarity and has dimensions num betas x num betas. 
    % tmp is num voxels x num betas (I don't have tmp yet). Beta value for each
    % voxel in the ROI, one for each item/beta. Simon grabbed these to make the
    % Rs. Just didn't save it like Cortney does. tmp lets you make Rs as well
    % as beta series which lets you do functional connectivity
    
    % ROIvals has voxel x num betas. There's one value per voxel per trial.
    % Then you get R, which is the neural RDM. How well is activity correlated
    % between each voxel for each trial? 120 trials, which is why we get
    % 120x120. So, you get trial 1 to trial 1, trial 1 to trial 2, etc.
    
    % The single trial beta is an image. Each pixel has a number and that's the
    % beta for each voxel. Really it's a single trial 'betas' because each
    % voxel has their own beta. Take all the per-voxel betas for trial 1 and
    % correlate with all the per-voxel betas for trial 2, and that goes into
    % the 1x2 cell and 2x1 cell in R. 
    
    % a neural RDM says during trial 1, the voxels had a given activity, what
    % is the correlation between the voxel activity in trial 2. The answer goes
    % into R. Correlation of all the voxels for each trial. It's multivariate
    % considers more than one voxel at a time. In univariate, our analysis in
    % one voxel. 
    
    %%% y = cope1 * x + ...
    % y is activity, cope is beta coefficient, and x is 'average of the other
    % trials.' The question is what is the activity associated with this trial
    % holding all the others constant. So 'multiplying by 0' doesn't remove
    % them. You're not really multiplying by 0. It's like a logical 0. Not
    % actual multiplication. It's the average of all the trials, variance, etc.
    % 0 means "variables of non-interest" vs variable of interest. 
    % Could also do repeated measures ANOVA where you treat day like a
    % categorical variable. a linear relationship is interesting, but a V-shape
    % might be good too. 
    
    
    %%%% So, you have to sort your neural RDM and model RDM in the same way and include the same items
    %%% Simon made these in stimID order, so we're good.
    
    %%% I should get rid of the NaNs. For example day 1, delete row and col 120
    %%% from model RDM and only look at 1 to 119 of neural RDM




    
%     cd /Users/matthewslayton/Desktop/ST_localOnly/RSA_RDMs %maybe don't do this? Use full paths instead? Not sure
%     
%     STAMP_concepts = featMat_sortedByID_namesID.concept;
%     
%     day1_feat = zeros(120,5520);
%     for num = 1:120
%     
%         %what ID are we talking about
%         currID = day1_sorted(num);
%         %where is it in the dinolab library
%         dinoRow = find(objIDCol==currID);
%         %where is it in the STAMP library
%         currItem = objNameCol(dinoRow);
%         %which row in the RDM
%         RDMrow = find(strcmp(STAMP_concepts,currItem));
%     
%         % not all dino items are in the STAMP feature set. Should it be NaNs?
%         if isempty(RDMrow) == 1
%             %day1_feat(num,:) = zeros(1,5520);
%             disp(num)
%         else
%             currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
%             day1_feat(num,:) = currRow;
%         end
%     end
%     
%     %%%%%% for missing object, just remove that trial
%     
%     day1_RDM = corrcoef(day1_feat');
%     
%     day2_feat = zeros(120,5520);
%     for num = 1:120
%     
%         %what ID are we talking about
%         currID = day2_sorted(num);
%         %where is it in the dinolab library
%         dinoRow = find(objIDCol==currID);
%         %where is it in the STAMP library
%         currItem = objNameCol(dinoRow);
%         %which row in the RDM
%         RDMrow = find(strcmp(STAMP_concepts,currItem));
%     
%         % not all dino items are in the STAMP feature set. Should it be NaNs?
%         if isempty(RDMrow) == 1
%             day2_feat(num,:) = zeros(1,5520);
%         else
%             currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
%             day2_feat(num,:) = currRow;
%         end
%     end
%     
%     day2_RDM = corrcoef(day2_feat');
%     
%     day3_feat = zeros(120,5520);
%     for num = 1:120
%     
%         %what ID are we talking about
%         currID = day3_sorted(num);
%         %where is it in the dinolab library
%         dinoRow = find(objIDCol==currID);
%         %where is it in the STAMP library
%         currItem = objNameCol(dinoRow);
%         %which row in the RDM
%         RDMrow = find(strcmp(STAMP_concepts,currItem));
%     
%         % not all dino items are in the STAMP feature set. Should it be NaNs?
%         if isempty(RDMrow) == 1
%             day3_feat(num,:) = zeros(1,5520);
%         else
%             currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
%             day3_feat(num,:) = currRow;
%         end
%     end
%     
%     day3_RDM = corrcoef(day3_feat');
%     
%     day4_feat = zeros(120,5520);
%     for num = 1:120
%     
%         %what ID are we talking about
%         currID = day4_sorted(num);
%         %where is it in the dinolab library
%         dinoRow = find(objIDCol==currID);
%         %where is it in the STAMP library
%         currItem = objNameCol(dinoRow);
%         %which row in the RDM
%         RDMrow = find(strcmp(STAMP_concepts,currItem));
%     
%         % not all dino items are in the STAMP feature set. Should it be NaNs?
%         if isempty(RDMrow) == 1
%             day4_feat(num,:) = zeros(1,5520);
%         else
%             currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
%             day4_feat(num,:) = currRow;
%         end
%     end
%     
%     day4_RDM = corrcoef(day4_feat');
%     
%     save(strcat(subject,'_day1_RDM.mat'),'day1_RDM')
%     save(strcat(subject,'_day2_RDM.mat'),'day2_RDM')
%     save(strcat(subject,'_day3_RDM.mat'),'day3_RDM')
%     save(strcat(subject,'_day4_RDM.mat'),'day4_RDM')

%     all_corr_day1 = zeros(246,1);
%     for mat = 1:246
%         try
%             load(day1_ROIs(mat).name) %loads R, ROIvals, stimID
%             R_clean = R(1:119,1:119);
%             
%             currCorr = corrcoef(day1_RDM_clean,R_clean);
%             all_corr_day1(mat) = currCorr(1,2);
%         catch
%             all_corr_day1(mat) = NaN; %if I can't load the mat file, just add NaN
%         end
%     
%         clear R
%         clear R_clean
%         clear ROIvals
%         clear StimID 
%     end
% 
%     %%% Day 2
%     %currFolder = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/',subject,'/',subName,'_Day2/');
%     currFolder = strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/',subName,'_Day2/');
%     addpath(currFolder)
%     day2_ROIs = dir(strcat(currFolder,'*.mat'));
%     addpath /Users/matthewslayton/Desktop/ST_localOnly/RSA_RDMs
%     load day2_RDM.mat %row 120 is NaNs
%     day2_RDM_clean = day2_RDM(1:119,1:119);
%     all_corr_day2 = zeros(246,1);
%     for mat = 1:246
%         try
%             load(day2_ROIs(mat).name) %loads R, ROIvals, stimID
%             R_clean = R(1:119,1:119);
%             
%             currCorr = corrcoef(day2_RDM_clean,R_clean);
%             all_corr_day2(mat) = currCorr(1,2);
%         catch
%             all_corr_day2(mat) = NaN; %if I can't load the mat file, just add NaN
%         end
%     
%         clear R
%         clear R_clean
%         clear ROIvals
%         clear StimID 
%     end
% 
%     %%% Day 3
%     %currFolder = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/',subject,'/',subName,'_Day3/');
%     currFolder = strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/',subName,'_Day3/');
%     addpath(currFolder)
%     day3_ROIs = dir(strcat(currFolder,'*.mat'));
%     addpath /Users/matthewslayton/Desktop/ST_localOnly/RSA_RDMs
%     load day3_RDM.mat %row 119 and 120 are NaNs
%     day3_RDM_clean = day1_RDM(1:118,1:118);
%     all_corr_day3 = zeros(246,1);
%     for mat = 1:246
%         try
%             load(day3_ROIs(mat).name) %loads R, ROIvals, stimID
%             R_clean = R(1:118,1:118);
%             
%             currCorr = corrcoef(day3_RDM_clean,R_clean);
%             all_corr_day3(mat) = currCorr(1,2);
%         catch
%             all_corr_day3(mat) = NaN; %if I can't load the mat file, just add NaN
%         end
%     
%         clear R
%         clear R_clean
%         clear ROIvals
%         clear StimID 
%     end
% 
%     %%% Day 4
%     %currFolder = strcat('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/',subject,'/',subName,'_Day4/');
%     currFolder = strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/',subject,'/',subName,'_Day4/');
%     addpath(currFolder)
%     day4_ROIs = dir(strcat(currFolder,'*.mat'));
%     addpath /Users/matthewslayton/Desktop/ST_localOnly/RSA_RDMs
%     load day4_RDM.mat %rows 117-120 are NaNs
%     day4_RDM_clean = day4_RDM(1:116,1:116);
%     all_corr_day4 = zeros(246,1);
%     for mat = 1:246
%         try
%             load(day4_ROIs(mat).name) %loads R, ROIvals, stimID
%             R_clean = R(1:116,1:116);
%             
%             currCorr = corrcoef(day4_RDM_clean,R_clean);
%             all_corr_day4(mat) = currCorr(1,2);
%         catch
%             all_corr_day4(mat) = NaN; %if I can't load the mat file, just add NaN
%         end
%     
%         clear R
%         clear R_clean
%         clear ROIvals
%         clear StimID 
%     end

%     %destination = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_corr/%s/',subject);
%     destination = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_corr/%s/',subject);
% 
%     % make output folder if it's not already there
%     if ~exist(destination,'dir'); mkdir(destination); end
% 
%     save(strcat(destination,'all_corr_day1.mat'),'all_corr_day1')
%     save(strcat(destination,'all_corr_day2.mat'),'all_corr_day2')
%     save(strcat(destination,'all_corr_day3.mat'),'all_corr_day3')
%     save(strcat(destination,'all_corr_day4.mat'),'all_corr_day4')
% 
% 
% end %subj loop


%%%% this is how I made the 995x995 RDM based on the STAMP features
% %remove the mccrae features row
% itemFeatures(1,:) = [];
% % 
% featMat_sortedByID = sortrows(itemFeatures,{'id'},"ascend");
% featMat_sortedByID_namesID = featMat_sortedByID(:,1:2);
% save('featMat_sortedByID_namesID.mat','featMat_sortedByID_namesID');
% featMat_sortedByID_onlyFeatures = featMat_sortedByID(:,8:end);
% save('featMat_sortedByID_onlyFeatures.mat','featMat_sortedByID_onlyFeatures')
% feature_sorted_corrMat = corrcoef(table2array(featMat_sortedByID_onlyFeatures)');
% save('feature_sorted_corrMat.mat','feature_sorted_corrMat')





 %all_ROIs = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/*.mat');
        % for row = 1:983
    %     currROI = all_ROIs(row).name;
    %     currDay = str2double(cell2mat(extractBetween(currROI,'Day','.mat')));
    % 
    %     if currDay == 1       
    %         copyfile(strcat('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/',currROI),'/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/ModelX_ROIs/mats/S007_Day1');
    %     elseif currDay == 2
    %         copyfile(strcat('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/',currROI),'/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/ModelX_ROIs/mats/S007_Day2');
    %     elseif currDay == 3
    %         copyfile(strcat('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/',currROI),'/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/ModelX_ROIs/mats/S007_Day3');
    %     elseif currDay == 4
    %         copyfile(strcat('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/',currROI),'/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/ModelX_ROIs/mats/S007_Day4');
    %     end
    % end


%%%%% ALL OF THIS WAS FOR 5007. I NEED IT TO WORK FOR ANY SUBJECT
% addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day1/
% day1_ROIs = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day1/*.mat');
% load day1_RDM.mat %row 120 is NaNs
% day1_RDM_clean = day1_RDM(1:119,1:119);
% all_corr_day1 = zeros(246,1);
% for mat = 1:246
%     try
%         load(day1_ROIs(mat).name) %loads R, ROIvals, stimID
%         R_clean = R(1:119,1:119);
%         
%         currCorr = corrcoef(day1_RDM_clean,R_clean);
%         all_corr_day1(mat) = currCorr(1,2);
%     catch
%         all_corr_day1(mat) = NaN; %if I can't load the mat file, just add NaN
%     end
% 
%     clear R
%     clear R_clean
%     clear ROIvals
%     clear StimID 
% end
% 
% addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day2/
% day2_ROIs = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day2/*.mat');
% load day2_RDM.mat %row 120 is NaNs
% day2_RDM_clean = day2_RDM(1:119,1:119);
% all_corr_day2 = zeros(246,1);
% for mat = 1:246
%     try
%         load(day2_ROIs(mat).name) %loads R, ROIvals, stimID
%         R_clean = R(1:119,1:119);
%         
%         currCorr = corrcoef(day2_RDM_clean,R_clean);
%         all_corr_day2(mat) = currCorr(1,2);
%     catch
%         all_corr_day2(mat) = NaN; %if I can't load the mat file, just add NaN
%     end
% 
%     clear R
%     clear R_clean
%     clear ROIvals
%     clear StimID 
% end
% 
% addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day3/
% day3_ROIs = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day3/*.mat');
% load day3_RDM.mat %row 119 and 120 are NaNs
% day3_RDM_clean = day3_RDM(1:118,1:118);
% all_corr_day3 = zeros(246,1);
% for mat = 1:246
%     try
%         load(day3_ROIs(mat).name) %loads R, ROIvals, stimID
%         R_clean = R(1:118,1:118);
%         
%         currCorr = corrcoef(day3_RDM_clean,R_clean);
%         all_corr_day3(mat) = currCorr(1,2);
%     catch
%         all_corr_day3(mat) = NaN; %if I can't load the mat file, just add NaN
%     end
% 
%     clear R
%     clear R_clean
%     clear ROIvals
%     clear StimID 
% end
% 
% 
% addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day4/
% day4_ROIs = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/mats/S007_Day4/*.mat');
% load day4_RDM.mat %rows 117-120 are NaNs
% day4_RDM_clean = day4_RDM(1:116,1:116);
% all_corr_day4 = zeros(246,1);
% for mat = 1:246
%     try
%         load(day4_ROIs(mat).name) %loads R, ROIvals, stimID
%         R_clean = R(1:116,1:116);
%         
%         currCorr = corrcoef(day4_RDM_clean,R_clean);
%         all_corr_day4(mat) = currCorr(1,2);
%     catch
%         all_corr_day4(mat) = NaN; %if I can't load the mat file, just add NaN
%     end
% 
%     clear R
%     clear R_clean
%     clear ROIvals
%     clear StimID 
% end


% destination = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_corr/%s/',subject);
% 
% save(strcat(destination,'all_corr_day1.mat'),'all_corr_day1')
% save(strcat(destination,'all_corr_day2.mat'),'all_corr_day2')
% save(strcat(destination,'all_corr_day3.mat'),'all_corr_day3')
% save(strcat(destination,'all_corr_day4.mat'),'all_corr_day4')





