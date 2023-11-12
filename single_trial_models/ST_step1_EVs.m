%%%%%% Single Trial Modeling using LSS Step 1
%%%%%%% load the behavioral output files, extract EVs, make txt files %%%%%%

%%%% trying to do univariate/functional localizer?
% go to /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/Analysis_scripts/automate_EV_txt.m
%%% this doesn't look at mem performnace in CRET or PRET, sorting by remembered and forgotten. Just when the EVs are.
% then we do per subject per trial, so EV1 and EV2 are the first and second
% trials and then EV3 is the other 38

%%% what do the txt files look like?
% three columns. First col has object onset times. Second col is 0s (always
% set Duration = 0 for univariate), and Third col is 1s for 'include this time point'
% In terms of formatting, they're separated by tabs like this:
% 3.4317781     0   1
% 27.3694756    0   1
% 36.0375881    0   1
% 42.4291426    0   1
% 50.7160884    0   1
% 57.0757981    0   1
% 67.5105371    0   1
% 73.6431092    0   1


% subjects = {'5001','5001','5001','5001',...
%     '5002','5002','5002','5002',...
%     '5004','5004','5004','5004',...
%     '5005','5005','5005','5005',...
%     '5006','5006','5006',...
%     '5007','5007','5007','5007',...
%     '5010','5010','5010','5010',...
%     '5011','5011','5011','5011',...
%     '5012','5012','5012','5012',...
%     '5014','5014','5014','5014',...
%     '5015','5015','5015','5015',...
%     '5016','5016','5016','5016',...
%     '5017','5017','5017','5017',...
%     '5019','5019','5019','5019',...
%     '5020','5020','5020','5020',...
%     '5021','5021','5021','5021',...
%     '5022','5022','5022','5022'};
% biac_ID = {'00414','00595','00597','00598',... %5001
%     '00373','00706','00710','00713',... %5002
%     '00432','00562','00566','00568',... %5004
%     '00616','00655','00658','00661',... %5005
%     '00665','00742','00744',... %5006
%     '00867','00890','00893','00895',... %5007
%     '01224','01271','01275','01279',... %5010
%     '00961','00990','00995','01001',... %5011
%     '01087','01101','01104','01107',... %5012
%     '00940','00976','00979','00980',... %5014
%     '00953','01233','01239','01242',... %5015
%     '00971','01007','01012','01014',... %5016
%     '00992','01099','01103','01105',... %5017
%     '01086','01183','01187','01189',... %5019
%     '01165','01178','01182','01184',... %5020
%     '01210','01286','01292','01296',... %5021
%     '01228','01262','01266','01272',... %5022
%     }; 
subjects = {'5010','5010','5010','5010',...
    '5015','5015','5015','5015',...
    '5016','5016','5016','5016',...
    '5017','5017','5017','5017',...
    '5019','5019','5019','5019',...
    '5020','5020','5020','5020',...
    '5021','5021','5021','5021',...
    '5022','5022','5022','5022'};
biac_ID = {'01224','01271','01275','01279',... %5010
    '00953','01233','01239','01242',... %5015
    '00971','01007','01012','01014',... %5016
    '00992','01099','01103','01105',... %5017
    '01086','01183','01187','01189',... %5019
    '01165','01178','01182','01184',... %5020
    '01210','01286','01292','01296',... %5021
    '01228','01262','01266','01272',... %5022
    }; 

subjects = {'5025','5025','5025','5025',...
    '5026','5026','5026','5026'};

biac_ID = {'01325', '01365', '01368', '01370',... %5025 hOA
'01375','01389', '01392','01396'}; %5026 MCI

% dayNum = [1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4,...
%     1,2,3,4];

for subj = 1:length(subjects) %already did 5001. Change back when you're ready!

    subject = subjects{subj};
    biac = biac_ID{subj};
    %currDay = dayNum(subj);

	%%%%% MATTHEW %%%%%
	addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/
	subdir = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/',subject,'/');
	% screening day
	% subdir = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/',subject,'/Screening Day Output/');

	cd (subdir)
	output_files = dir('*.mat');
	output_list = {output_files.name}.';

    % NOTE: we did this strange thing where the initial screening day was called "day 10" to contrast from the baseline day "day 1"
    % and the TMS days "day 2, day 3, and day 4." Because matlab and Finder order files strangely, we have to make sure
    % the "day 10" behavioral outputs aren't in there. My two cents are that we should have named them "day 0" or better yet "day 9"
    % so they wouldn't be an issue. The best solution is to store them in a sub-folder that matlab doesn't have access to.
    % we had an automated solution, but the manual option turned out to be better.
    
    % find where the screening day outputs are so we can skip them later
    % isDay10True = zeros(length(output_list),1);
    % for row = 1:length(output_list)
    % 
    %     currFileName = output_list{row};
    %     currDay = extractBetween(currFileName,'day','_');
    %     if strcmp(currDay{:},'10') == 1
    %         isDay10True(row) = 1;
    %      end
    % end

	% where are the ENC files? Remember, we're scanning during Encoding only
    % there should be 12 ENC files. Three per day for four days
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

    % munin
    path_analysis = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/EVs/%s/',subject);
    if ~exist(path_analysis,'dir'); mkdir(path_analysis); end

    % some subjects that we ran early on had issues, so I just use if statements to hangle them. There's more below
    if subject == '5006' %5006 only has 3 days
        finalDay = 3;
    else
        finalDay = 4; %every other subject
    end

    % here's the main loop. YOu want to check days 1 through 4
    for currDay = 1:finalDay
        % and all three encoding runs
	    for currRun = 1:3

            if currDay == 1
                runCounter = 0; %0 runs have been calculated so far
            elseif currDay == 2
                runCounter = 3; %3 runs have gone
            elseif currDay == 3
                runCounter = 6;
            elseif currDay == 4
                runCounter = 9;
            end
            
            % find and load the behavioral file
            currOutputCell = output_list(ENC_files(runCounter+currRun));
            currOutputMat = cell2mat(currOutputCell);
            load(currOutputMat) %loads as output_tbl
            tic
            for currTrial = 1:20 %enc has 20 trials of two objects each
    
                % this would be the double-trial model
                % EV1 is the current trial's obj1 onset
                EV1 = [output_tbl.tObj1Onset(currTrial) 2 1];
                % EV2 is the current trial's obj2 onset
                EV2 = [output_tbl.tObj2Onset(currTrial) 2 1];

                % EV3 will be the remaining 38 onsets. 20 trials of 2 objects
                % each and 19 remain
                onsetCol = zeros(40,1);
                trialCounter = 1; %should go up to 20 for the 20 pair-wise trials
                for row = 1:40
                    %need to skip the row that went into EV1 and EV2
                    if trialCounter == currTrial
                        if mod(row,2) == 1
                            onsetCol(row) = 0;
                            continue
                        elseif mod(row,2) == 0
                            onsetCol(row) = 0;
                            trialCounter = trialCounter+1;
                            continue
                        end
                    end

                    %ugh, the early subjects are all messed up
%                     if iscell(output_tbl.tObj1Onset(1)) == 0
%                         tObj1Onset = num2cell(output_tbl.tObj1Onset);
%                         output_tbl.tObj1Onset = tObj1Onset;
%                     end
%                     if iscell(output_tbl.tObj2Onset(1)) == 0
%                         tObj2Onset = num2cell(output_tbl.tObj2Onset);
%                         output_tbl.tObj2Onset = tObj2Onset;
%                     end
                    
                    % got to grab those onsets, and we're treating trial 1 and trial 2 separately
                    if mod(row,2) == 1
                        onsetCol(row) = cell2mat(output_tbl.tObj1Onset(trialCounter));
                        %don't increment trialCounter because we have to do obj2's onset on this same row
                    elseif mod(row,2) == 0
                        onsetCol(row) = cell2mat(output_tbl.tObj2Onset(trialCounter));
                        trialCounter = trialCounter+1; %if we've added obj2, then go to the next row
                    end
                end

%%%%%%%%%%% reminder, 5001  and 5004 don't have tObj2Onsets, so onsetCol has 19 not 38

                %remove the zero rows
                onsetCol(~any(onsetCol,2),:) = [];
                twoCol = ones(38,1)*2;
                EV3 = [onsetCol twoCol ones(38,1)];
    
                % EV4 can be button presses
                % To do that, take tObj2Onset + 2 + rt
                obj2Col = cell2mat(output_tbl.tObj2Onset);
                rtCol = cell2mat(output_tbl.rt);
                bpCol = obj2Col + rtCol + 2;
                twoCol_twenty = ones(20,1)*2;
                EV4 = [bpCol twoCol_twenty ones(20,1)];
    
                % need subject, day, and run
                fileNameInfo = sprintf('%s_Day%d_Run%d',subject,currDay,currRun);
                if ~exist([path_analysis,fileNameInfo],'dir'); mkdir([path_analysis,fileNameInfo]); end
    
                %%%% these aren't tab delimited?
                writecell(EV1, [path_analysis,fileNameInfo,strcat('/Trial',num2str(currTrial),'_EV1_obj1.txt')],'Delimiter',' ')
                writecell(EV2, [path_analysis,fileNameInfo,strcat('/Trial',num2str(currTrial),'_EV2_obj2.txt')],'Delimiter',' ')
                writematrix(EV3, [path_analysis,fileNameInfo,strcat('/Trial',num2str(currTrial),'_EV3_trials.txt')],'Delimiter',' ')
                writematrix(EV4, [path_analysis,fileNameInfo,strcat('/Trial',num2str(currTrial),'_EV4_bp.txt')],'Delimiter',' ')
	    

%                 writecell(EV1, [path_analysis,fileNameInfo,strcat('/Trial',num2str(sprintf('%02d',currTrial)),'_EV1_obj1.txt')],'Delimiter',' ')
%                 writecell(EV2, [path_analysis,fileNameInfo,strcat('/Trial',num2str(sprintf('%02d',currTrial)),'_EV2_obj2.txt')],'Delimiter',' ')
%                 writematrix(EV3, [path_analysis,fileNameInfo,strcat('/Trial',num2str(sprintf('%02d',currTrial)),'_EV3_trials.txt')],'Delimiter',' ')
%                 writematrix(EV4, [path_analysis,fileNameInfo,strcat('/Trial',num2str(sprintf('%02d',currTrial)),'_EV4_bp.txt')],'Delimiter',' ')
% 	    
           

	%%%% EV1 indexes the first trial. We need that to make the LSS algorithm work
	% It needs to have the onset, duration of 2, and then a third col which is 1. Just one row


	%%%% EV2 is the rest of the onsets. 
	% ENC had 60 per day (20 per run) with two images per trial. 
	% That means each of these should have 39 given 40 images per run

	%%%% alterantively, could do a 'double-trial model.' For that, EV1 has one row for obj 1 onset
	% EV2 has one row for obj 2 onset, and then EV3 has the remaining 38. 

	%%%% additional EVs?
	% could record button press times. To do that, have to figure out how resp relates to tObj2Onset, so startTime and tStart
    % 5001, 5002, and 5004 are tricky but when we have tObj2Onset, it's
    % easy

            end %currTrial loop

            toc
	    end %currRun loop

    end %currDay loop

end %subj loop

% other notes that you can ignore

% the difference here is that I learned to make LSS work I need to run 20
% models per day and run. So, day 1 run 1 needs 20 different models. I need
% to shuffle the EVs around so each obj1 and obj2 gets a turn to be on its
% own in EV1 and EV2.

%%%% each subject has two sessions, TT2 and TT3
%%%% each of these is a potential EV.
%%%% fixation, memory, counterfactual thinking, button presses, numerical distraction task, numerical judgment button presses
%%%% For us, first EV indexes single trial, second EV indexes all the other trials
%%% so, each EV must contain onset and duration of one or more events.
%%% ST models using LSS, will have at least two EVs. First is single trial of interest, such as the image cardinal presented on t=12s and lasted for 2s
%%% Then EV1 takes the onset of 12, duration of 2, and third col is 1 (parametric modulator)
%%% EV1 is one row only for one trial. EV2 will have 120 - 1 or however many the total is - 1.
%%% that's done separately for each run. 
%%% one model for each fMRI run. Each model has two EVs. First, single-trial, second is all other trials. 
%%% then nuissance regressors. 
%%% Our ENC has twenty trials with two images. But we probably want to treat those images separately. 
%%% can model the events as separate or together. 
%%% Probably better to do them separately, but the fact that there's a pair structure in ENC, it makes it harder
%%% to figure out how to structure the ST model. 1, 2, and then longer jitter. Not a continuous stream
%%% Might want to do double-trial model. Two EVs of interest. First EV codes for presentation of first image.
%%% EV2 codes for presentation of second image. Third EV codes for pairs 2 through 20. <- is this the right way to go?
%%% Step 0 gathers the relevant info and then Step 1 does this. 
%%%% four days of three enc runs, so 12 sets of EVs per subject. 
%%%%%% You want to make EVs for whatever will elicit fMRI activity. Image presentation, button presses, doing a task.
%%% "Onset duration 1" for whatever the event is
%%% The purpose of single-trial models is to get parameter estimates (betas) for each trial. 
%%% Then we could do sub remembered > sub forgotten or whatever we want afterward. 