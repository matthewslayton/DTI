% STOP! Have you run FEAT yet? YOu need to submit submit_ST.sh which runs qsub_ST.sh for the given subjects, days, runs, and trials.
% then you can return to this script to rename the Betas and the single trials are done.

% FEAT is done and now we need to name the single-trial betas something
% useful. Grab the cope files and add subject, day, run, trial, and the
% object ID for that trial's stimulus

% the outputs of FEAT first level are here:
% /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/5007/SingleTrials_FSL/design_day1_run1/design.feat

% cope1 is obj1's beta and cope2 is obj2's beta
% I need to load those for each output, and remember each day and run has twenty, one for each paired trial.
% So, day1 run 1 has 20 outputs, each of which has two betas in it (cope1 and cope2). That's how I get 40 single trial betas

% pe are parameter estimates
% cope contrasts between beta weights. One cope for each contrast
% tstat tells you sig level of fit between regressor and betas/PEs. There are as many tstats as contrasts
% varcope gives variance of the COPEs. As many as there are contrasts
% zstat tells you whether you can reject null hypothesis or not

clear all

% to use SPM
% on laptop
addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12;
addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/mfMRI_v2-master/nifti/;

% on velociraptor
%addpath '/Users/matthewslayton/spm12';

%subjects = {'5010','5015','5016'};
%,'5017','5019','5020','5021','5022'};
subjects = {'5002'};
% 5007, 5011, 5012, 5014 already run and are on desktop
% 5001 and 5006 are still running
% 5002 day 1 only has run 2 fmriprep outputs

for subj = 1:length(subjects)

    subject = subjects{subj};

    %destination = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/renamed_betas/%s/',subject);
    destination = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/renamedBetas/%s/',subject);
    if ~exist(destination,'dir'); mkdir(destination); end
    
    for currDay = 1%2:4 %4 days

        for currRun = 1 %3 runs per day
                %%% need to add the stimID to the file name
    	        addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/
                subdir = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/',subject,'/');
        
                cd (subdir)
                output_files = dir('*.mat');
                output_list = {output_files.name}.';
            
                % where are the ENC files?
                ENC_counter = 1;
                for curr = 1:length(output_list)
                    currOutputCell = output_list(curr);
                    currOutputMat = cell2mat(currOutputCell);
                    strPos = strfind(currOutputMat,'_output');
                    trialType = currOutputMat(strPos-4:strPos);
                    if trialType == '_ENC_'
                        ENC_files(ENC_counter) = curr;
                        ENC_counter = ENC_counter + 1;
                    end
                end
                if currDay == 1
                    runCounter = 0; %0 runs have been calculated so far
                elseif currDay == 2
                    runCounter = 3; %3 runs have gone
                elseif currDay == 3
                    runCounter = 6;
                elseif currDay == 4
                    runCounter = 9;
                end
        
                currOutputCell = output_list(ENC_files(runCounter+currRun));
                currOutputMat = cell2mat(currOutputCell);
                load(currOutputMat) %loads as output_tbl

                %which object between 1 and 40? initialize here
                objNum = 1;

            for currTrial = 1:20 %20 trials per run

                for cope = 1:2 %2 per feat output
            
                    %which stimID? and do I add leading zeros or not?
                    if cope == 1
                        currID = cell2mat(output_tbl.ID1(currTrial));
                    elseif cope == 2
                        currID = cell2mat(output_tbl.ID2(currTrial));
                    end

                %box    
                %source = sprintf('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/%s/SingleTrials_FSL/design_day%d_run%d/trial%d/design.feat/stats/',subject,currDay,currRun,currTrial);
                %currFilePath = sprintf('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/%s/SingleTrials_FSL/design_day%d_run%d/trial%d/design.feat/stats/cope%d.nii.gz',subject,currDay,currRun,currTrial,cope);
               
                %laptop
                %source = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/data_out/%s_design_day%d_run%d/trial%d/design.feat/stats/',subject,currDay,currRun,currTrial);
                %currFilePath = sprintf('/Users/matthewslayton/Desktop/ST_localOnly/data_out/%s_design_day%d_run%d/trial%d/design.feat/stats/cope%d.nii.gz',subject,currDay,currRun,currTrial,cope);
                %munin
                source = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/trialDataOut/%s/design_day%d_run%d/trial%d/design.feat/stats/',subject,currDay,currRun,currTrial);
                currFilePath = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/trialDataOut/%s/design_day%d_run%d/trial%d/design.feat/stats/cope%d.nii.gz',subject,currDay,currRun,currTrial,cope);

                currFileUnzip = gunzip(currFilePath); %loads as a cell
                currFile = load_untouch_nii(currFileUnzip{:});

                newFile.('hdr') = currFile.hdr;
                newFile.('filetype') = 2;
                newFile.('fileprefix') = currFile.fileprefix;
                newFile.('machine') = currFile.machine;
                newFile.('ext') = currFile.ext;
                newFile.('img') = currFile.img;
                newFile.('untouch') = currFile.untouch;

                save_untouch_nii(newFile,strcat(destination,sprintf('%s_day%d_run%d_trial%02d_obj%02d_stimID%s.nii',subject,currDay,currRun,currTrial,objNum,num2str(currID))))

                %increment objNum so I can count the order. If I don't keep
                %track of this, then finder can sort the by name or however. I
                %want to keep them in presentation order
                objNum = objNum + 1;

                end %cope
            end %currTrial
        end %currRun
    end %currDay
end %subj


% some of the commented lines are from previous versions that used box and
% my desktop. For now we're doing everything on munin, which is what the
% current verion of this script does
%day 1 run 2, trials 13, 19 backwards
%day 1 run 3 trials 4, 9, and 19 are backwards

% copyfile(source,destination)
%newName = strcat(destination,sprintf('/%s_day%d_run%d_trial%d_obj%s.nii',subject,currDay,currRun,currTrial,num2str(currID)));
%copyfile(currFile,newName,'f')
%copyfile(sprintf('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/%s/SingleTrials_FSL/design_day%d_run%d/trial%d/design.feat/stats/cope%d.nii.gz',subject,currDay,currRun,currTrial,cope),'testName','f')



% addpath /Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/ROIs

% currFilePath = '/Users/matthewslayton/Documents/Duke/Simon_Lab/RSA_practice/ModelX_ROIs/ROIs/BD_ROI_001.nii.gz';
% currFileUnzip = gunzip(currFilePath); %loads as a cell
% currFile = load_untouch_nii(currFileUnzip{:});
