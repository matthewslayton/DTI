%%% makes brain RDMs %%%
% this script extracts values from a beta and creates an ROI.mat

clear all
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/spm12')

subjects = {'5016'};
%subjects = {'5004','5005','5010','5015','5016','5017','5019','5020','5021','5022'};
% 5007, 5011, 5012, 5014 already run and are on desktop
% 5001 and 5006 are still running
% 5002 day 1 only has run 2 fmriprep outputs

for subj = 1:length(subjects)

    subject = subjects{subj};

    % get the single trial betas
    %all_betas = dir(sprintf('/Users/matthewslayton/Desktop/ST_localOnly/renamed_betas/%s/*.nii',subject));
    all_betas = dir(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/renamedBetas/%s/*.nii',subject));
    
    beta_names = cell(length(all_betas),2); %full name, stimID
    for row = 1:length(all_betas)
    
        %get the stimIDs
        currBeta = all_betas(row).name;
        currID = str2double(cell2mat(extractBetween(all_betas(row).name,'stimID','.')));
        beta_names{row,1} = currBeta;
        beta_names{row,2} = currID;
    end
    
    % there are 480 per subject, 120 per day (remember 20 trials per 3 runs,
    % two objects per trial is 40 per run for 3 runs = 120)

    % something for if we're missing betas
%     if length(beta_names) ~= 480
%         disp('There are not 480 betas like there should be')
%         continue
%     end
    
    % make four cells, one for each day
    beta_names_day1 = beta_names(1:120,:);
    beta_names_day2 = beta_names(121:240,:);
    beta_names_day3 = beta_names(241:360,:);
    beta_names_day4 = beta_names(361:480,:);
    
    % sort by col 2 which has the stimIDs
    beta_names_day1_sorted = sortrows(beta_names_day1,2);
    beta_names_day2_sorted = sortrows(beta_names_day2,2);
    beta_names_day3_sorted = sortrows(beta_names_day3,2);
    beta_names_day4_sorted = sortrows(beta_names_day4,2);
    
    % the final form needs to be a 4x120 cell of the names only
    betas = vertcat(beta_names_day1_sorted(:,1)',beta_names_day2_sorted(:,1)',...
        beta_names_day3_sorted(:,1)',beta_names_day4_sorted(:,1)');
    
    % final form of stimIDs is a 4x120 double of the stimIDs only
    stimIDs_cell = vertcat(beta_names_day1_sorted(:,2)',beta_names_day2_sorted(:,2)',...
        beta_names_day3_sorted(:,2)',beta_names_day4_sorted(:,2)');
    
    stimIDs = cell2mat(stimIDs_cell);
    
    for X = 1:246 %all ROIs
        tic

        ROI_file = sprintf('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/ROIs/BN_ROI_%03d.nii.gz', X);
        currFileUnzip = gunzip(ROI_file); %loads as a cell
    
        ROI = spm_read_vols(spm_vol(currFileUnzip{:})); %used to load ROI_file directly, but it can't read compressed
        ROI(ROI==0) = NaN;
        
        for j = 1:4  %day loop
            try
                parfor i = 1:size(betas, 2)  % stim loop
                    BETA = spm_read_vols(spm_vol(sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/renamedBetas/%s/%s',subject,betas{j,i})));
                    Xvals = ROI .* BETA;
                    vals=(Xvals(~isnan(Xvals)));
                    ROIvals(:,i) = reshape(vals, size(vals,1), 1);
                end
                
                %make the brain RDM
                R = corrcoef(ROIvals, 'rows', 'pairwise');
                stimID = stimIDs(j,:);

                % make output folder if it's not already there
                
                outputFolder = '/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/';
                if ~exist(outputFolder,'dir'); mkdir(outputFolder); end
                subjOutputFolder = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/%s/',subject);
                if ~exist(subjOutputFolder,'dir'); mkdir(subjOutputFolder); end
                filename = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/RSA_mats/%s/%s_ROI%03d_Day%d.mat',subject,subject,X,j);
                save(filename, "ROIvals", "R", "stimID"); % save 1 file for each ROI / day
                clear ROIvals R stimID;
            catch
                fprintf('error on day %d, ROI %d\n', j, X);
            end
        end
        toc
    end

end %subj loop

% betas needs to be a 4x120 cell. 4 days and 120 individual trials/objects per day
% these betas (and stimIDs) need to be in stimID order.

% so, I need to load all the renamed betas and sort by day and then by
% stimID. After that I have to put them into a cell.

%ROI_file = sprintf('/Users/simonwdavis/Library/CloudStorage/Dropbox/ppp/ROIs/BN_ROI_%03d.nii', X);

%BETA = spm_read_vols(spm_vol(sprintf('/Users/simonwdavis/Library/CloudStorage/Dropbox/ppp/betas/%s', betas{j,i}) ));
%BETA = spm_read_vols(spm_vol(sprintf('/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/betas/%s', betas{j,i}) ));
%BETA = spm_read_vols(spm_vol(sprintf('/Users/matthewslayton/Desktop/ST_localOnly/renamed_betas/%s/%s',subject,betas{j,i})));
%outputFolder = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/%s/',subject);
%filename = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/RSA_mats/%s/%s_ROI%03d_Day%d.mat', subject, subject, X, j);
