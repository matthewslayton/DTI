% here you make semantic RDMs. In this case, we're using the feature norms, but you can use GloVe or whatever method
% you like to establish distances/differences between the various objects

clear all 

addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/Analysis_files

load featMat_sortedByID_onlyFeatures.mat
load featMat_sortedByID_namesID.mat
STAMP_concepts = featMat_sortedByID_namesID.concept;

%NOTE: my 995x995 RDM is based on the STAMP IDs, so I have to add the dinolab IDs
%featMat_sortedByID_namesID has two cols, 'concept' which has the names and
%'id' which has the STAMP IDs. So, I need to take the object ID from the
%beta name, match it to the concept col

%%% remember, and RDM by this method takes the feature matrix and does
%%% corrcoef. So really, I have to find the 120 items in question so it's
%%% 120x5520 and then do corrcoef

%cd /Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_RDMs %maybe don't do this? Use full paths instead? Not sure

% I suppose I should use this, but the numbers are the same: /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/dinoObjectIDs_851.xlsx
objectLibrary = readtable('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/Sandbox/MS-sandbox/dinoObjectIDs.xlsx');
objIDCol = objectLibrary.ID;
objNameCol = objectLibrary.Object1DisplayName;

subjects = {'5025','5026'};

for subj = 1:length(subjects)

    subject = subjects{subj};
  

    all_betas = dir(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/renamedBetas/%s/*.nii',subject));

    
    %%%% (1) Sort semantic RDMs by stimID %%%%
    
    % let's grab the stimIDs for a given day. Sort into numerical order
    stimIDs_day1 = zeros(120,1);
    for row = 1:120
        stimIDs_day1(row) = str2double(cell2mat(extractBetween(all_betas(row).name,'stimID','.')));
    end
    % sort stimIDs in ascending order
    day1_sorted = sortrows(stimIDs_day1);

    stimIDs_day2 = zeros(120,1);
    for row = 1:120
        stimIDs_day2(row) = str2double(cell2mat(extractBetween(all_betas(row+120).name,'stimID','.')));
    end
    % sort stimIDs
    day2_sorted = sortrows(stimIDs_day2);

    stimIDs_day3 = zeros(120,1);
    for row = 1:120
        stimIDs_day3(row) = str2double(cell2mat(extractBetween(all_betas(row+240).name,'stimID','.')));
    end
    % sort stimIDs
    day3_sorted = sortrows(stimIDs_day3);

    stimIDs_day4 = zeros(120,1);
    for row = 1:120
        stimIDs_day4(row) = str2double(cell2mat(extractBetween(all_betas(row+360).name,'stimID','.')));
    end
    % sort stimIDs
    day4_sorted = sortrows(stimIDs_day4);

    
    day1_feat = zeros(120,5520);
    for num = 1:120
    
        %what ID are we talking about
        currID = day1_sorted(num);
        %where is it in the dinolab library
        dinoRow = find(objIDCol==currID);
        %where is it in the STAMP library
        currItem = objNameCol(dinoRow);
        %which row in the RDM
        RDMrow = find(strcmp(STAMP_concepts,currItem));
    
        % not all dino items are in the STAMP feature set. Should it be NaNs?
        if isempty(RDMrow) == 1
            %day1_feat(num,:) = zeros(1,5520);
            disp(num)
        else
            currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
            day1_feat(num,:) = currRow;
        end
    end
    
    %%%%%% for missing object, just remove that trial
    
    day1_RDM = corrcoef(day1_feat');
    
    day2_feat = zeros(120,5520);
    for num = 1:120
    
        %what ID are we talking about
        currID = day2_sorted(num);
        %where is it in the dinolab library
        dinoRow = find(objIDCol==currID);
        %where is it in the STAMP library
        currItem = objNameCol(dinoRow);
        %which row in the RDM
        RDMrow = find(strcmp(STAMP_concepts,currItem));
    
        % not all dino items are in the STAMP feature set. Should it be NaNs?
        if isempty(RDMrow) == 1
            day2_feat(num,:) = zeros(1,5520);
        else
            currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
            day2_feat(num,:) = currRow;
        end
    end
    
    day2_RDM = corrcoef(day2_feat');
    
    day3_feat = zeros(120,5520);
    for num = 1:120
    
        %what ID are we talking about
        currID = day3_sorted(num);
        %where is it in the dinolab library
        dinoRow = find(objIDCol==currID);
        %where is it in the STAMP library
        currItem = objNameCol(dinoRow);
        %which row in the RDM
        RDMrow = find(strcmp(STAMP_concepts,currItem));
    
        % not all dino items are in the STAMP feature set. Should it be NaNs?
        if isempty(RDMrow) == 1
            day3_feat(num,:) = zeros(1,5520);
        else
            currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
            day3_feat(num,:) = currRow;
        end
    end
    
    day3_RDM = corrcoef(day3_feat');
    
    day4_feat = zeros(120,5520);
    for num = 1:120
    
        %what ID are we talking about
        currID = day4_sorted(num);
        %where is it in the dinolab library
        dinoRow = find(objIDCol==currID);
        %where is it in the STAMP library
        currItem = objNameCol(dinoRow);
        %which row in the RDM
        RDMrow = find(strcmp(STAMP_concepts,currItem));
    
        % not all dino items are in the STAMP feature set. Should it be NaNs?
        if isempty(RDMrow) == 1
            day4_feat(num,:) = zeros(1,5520);
        else
            currRow = featMat_sortedByID_onlyFeatures{RDMrow,:};
            day4_feat(num,:) = currRow;
        end
    end
    
    day4_RDM = corrcoef(day4_feat');

    destination = strcat('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_RDMs/',subject,'/');

    % make output folder if it's not already there
    if ~exist(destination,'dir'); mkdir(destination); end

    save(strcat(destination,subject,'_day1_RDM.mat'),'day1_RDM')
    save(strcat(destination,subject,'_day2_RDM.mat'),'day2_RDM')
    save(strcat(destination,subject,'_day3_RDM.mat'),'day3_RDM')
    save(strcat(destination,subject,'_day4_RDM.mat'),'day4_RDM')

end

% /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP_scripts/make_PCs_features.m
% original feature matrix. 995 items sorted by stimID (which is just the row number because alphabetical)
%%%% the thing is, I don't have to do it this way, where you go from
%%%% 995x5520 to an individual 120x120.
% you can just index the big RDM. Also the 995 STAMP doesn't really apply
% to NetTMS where there are actually 851, though I suppose the stimIDs are
% the same. My library has extra items, though we can't use the features
% for that part of the RDM. So how did I do it? It obviously ran. I just
% NaNed-out the rows with new items! Whew ok. I guess I can do it this
% strangely roundabout way for now

%load features_stimIDorder.mat
% load the corr mat sorted by stimID
%load features_stimID_corrmat.mat

%load feature_sorted_corrMat.mat


%%% this is how I made the 995x995 RDM based on the STAMP features
%remove the mccrae features row
% itemFeatures(1,:) = [];
% % 
% featMat_sortedByID = sortrows(itemFeatures,{'id'},"ascend");
% featMat_sortedByID_namesID = featMat_sortedByID(:,1:2);
% %save('featMat_sortedByID_namesID.mat','featMat_sortedByID_namesID');
% featMat_sortedByID_onlyFeatures = featMat_sortedByID(:,8:end);
% %save('featMat_sortedByID_onlyFeatures.mat','featMat_sortedByID_onlyFeatures')
% feature_sorted_corrMat = corrcoef(table2array(featMat_sortedByID_onlyFeatures)');
% %save('feature_sorted_corrMat.mat','feature_sorted_corrMat')

%all_betas = dir(sprintf('/Users/matthewslayton/Desktop/ST_localOnly/renamed_betas/%s/*.nii',subject));