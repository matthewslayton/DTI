%%%%%% Single Trial Modeling using LSS Step 3
% we need to make the design.fsf file that FSL needs to run.
% this is instead of manually specifying all the maths and contrasts in the GUI

close all
clear
clc

subjects = {'5001','5001','5001','5001',...
    '5002','5002','5002','5002',...
    '5004','5004','5004','5004',...
    '5005','5005','5005','5005',...
    '5010','5010','5010','5010',...
    '5015','5015','5015','5015',...
    '5016','5016','5016','5016',...
    '5017','5017','5017','5017',...
    '5019','5019','5019','5019',...
    '5020','5020','5020','5020',...
    '5021','5021','5021','5021',...
    '5022','5022','5022','5022'};
biac_ID = {'00414','00595','00597','00598',... %5001
    '00373','00706','00710','00713',... %5002 %note, 00373 doesn't have the actual scans. Need 00614
    '00432','00562','00566','00568',... %5004
    '00616','00655','00658','00661',... %5005
    '01224','01271','01275','01279',... %5010
    '00953','01233','01239','01242',... %5015
    '00971','01007','01012','01014',... %5016
    '00992','01099','01103','01105',... %5017
    '01086','01183','01187','01189',... %5019
    '01165','01178','01182','01184',... %5020
    '01210','01286','01292','01296',... %5021
    '01228','01262','01266','01272',... %5022
    }; 

dayNum = [1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4,...
    1,2,3,4];

subjects = {'5002'};
biac_ID = {'00614'}; 
dayNum = 1;

subjects = {'5002','5002','5002','5002'};
biac_ID = {'00614','00706','00710','00713'}; 
dayNum = [1,2,3,4];

subjects = {'5020'};
biac_ID = {'01184'}; 
dayNum = 4;

subjects = {'5020','5021','5021','5021','5021','5022','5022','5022','5022'};
biac_ID = {'01184','01210','01286','01292','01296','01228','01262','01266','01272'};
dayNum = [4,1,2,3,4,1,2,3,4];

subjects = {'5022','5022','5022','5022'};
biac_ID = {'01228','01262','01266','01272'};
dayNum = [1,2,3,4];

subjects = {'5025','5025','5025','5025',...
    '5026','5026','5026','5026'};

biac_ID = {'01325', '01365', '01368', '01370',... %5025 hOA
'01375','01389', '01392','01396'}; %5026 MCI

dayNum = [1,2,3,4,...
    1,2,3,4];

%% generate fsf
template_file = '/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/design_netTMS_template.fsf';
template = textscan(fopen(template_file), '%s', 'Delimiter','\n', 'CollectOutput', true);
fclose('all');


for subj = 1:length(subjects) %remember subj is my day  loop too

    subject = subjects{subj};
	biac = biac_ID{subj};
    currDay = dayNum(subj); %biac number determines the day number, so we don't need a loop

    for currRun = 1:3
    
        tic

        design = template{1,1};

        for currTrial = 1:20

            design{18,1} = 'set fmri(analysis) 2'; %statistics only, not full analysis
            
            % # Output directory on munin. Matlab has to know what it is so use /Volumes/Data
            outputdir = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/trialDataOut/%s/design_day%d_run%d/trial%d/',subject,currDay,currRun,currTrial);
            if ~exist(outputdir); mkdir(outputdir); end

            % this is for the cluster, so it's /mnt/munin2
            design{33,1} = sprintf('set fmri(outputdir) "/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/trialDataOut/%s/design_day%d_run%d/trial%d/design.feat"',subject,currDay,currRun,currTrial);

            % # Total volumes
            design{36,1} = 'set fmri(tr) 2.000000';
            design{39,1} = 'set fmri(npts) 165'; %for 00414 it's 160. For 00562 it's 167. For 01184 it's 165

            % # Delete volumes
            design{42,1} = 'set fmri(ndelete) 4';

            % # Z threshold
            design{188,1} = 'set fmri(z_thresh) 2.7';

            % # Standard Image
            design{248,1} = 'set fmri(regstandard) "/usr/local/packages/fsl-6.0.6/data/standard/MNI152_T1_2mm_brain.nii.gz"';

            % # 4D AVW data or FEAT directory (1)
            design{279,1} = sprintf('set feat_files(1) "/mnt/munin2/Simon/NetTMS.01/Data/Processed_Data/fmriprep_out/sub-%s/ses-1/func/sub-%s_ses-1_task-encoding_run-%d_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold"',biac,biac,currRun);

           %  # Confound EVs text file for analysis 1
            design{285,1} = sprintf('set confoundev_files(1) "/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/Confounds/%s/%s_DAY%d_ENC_Confounds_RUN%d.txt"',subject,subject,currDay,currRun);

            % # Subject's structural image for analysis 1
            %design{285,1} = sprintf('set highres_files(1) "/mnt/munin2/Simon/NetTMS.01/Analysis/TMS_Localizers/%s/%s_t1_brain"',subject,subject);

            % # Custom EV file (EV 1)
            design{320,1} = sprintf('set fmri(custom1) "/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/EVs/%s/%s_Day%d_Run%d/Trial%d_EV1_obj1.txt"', ...
                subject,subject,currDay,currRun,currTrial);

            % # Custom EV file (EV 2)
            design{370,1} = sprintf('set fmri(custom2) "/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/EVs/%s/%s_Day%d_Run%d/Trial%d_EV2_obj2.txt"', ...
                subject,subject,currDay,currRun,currTrial);

            % # Custom EV file (EV 3)
            design{420,1} = sprintf('set fmri(custom3) "/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/EVs/%s/%s_Day%d_Run%d/Trial%d_EV3_trials.txt"', ... 
                subject,subject,currDay,currRun,currTrial);

            % # Custom EV file (EV 4)
            design{470,1} = sprintf('set fmri(custom4) "/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/EVs/%s/%s_Day%d_Run%d/Trial%d_EV4_bp.txt"', ...
                subject,subject,currDay,currRun,currTrial);
            cd(outputdir)
            fid = fopen('design.fsf','w');
            fprintf(fid,'%s\n', design{:});
            fclose(fid);
	        fprintf(strcat('finished: ',subject));
	        toc
        end %currTrial loop
    end %currRun loop
end %sub loop


%%%% each 1st-level model generates a 
%%% filtered_func_data.nii.gz which is big and useless, and can probably be deleted at the end of the 1st-level script

%%%%% MATTHEW %%%%%
% addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/
% subdir = strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/',subject,'/');
% sub_str = subject;

%%%%%% you have to load the three runs
% /Volumes/Data/Simon/NetTMS.01/Analysis/TMS_Localizers/5020/sub-01165_ses-1_task-encoding_run-1_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz

%%%%%% load onset files
% /Volumes/Data/Simon/NetTMS.01/Analysis/TMS_Localizers/5020/Onset_Files/5020_Day1_ENC_CMEM_SR_RUN1.txt

%%%%%% load confounds
% /Volumes/Data/Simon/NetTMS.01/Analysis/TMS_Localizers/5020/fmriprep_outputs/5020_DAY1_ENC_Confounds_RUN1.txt

%%%%%% load skull-stripped T1
% /Volumes/Data/Simon/NetTMS.01/Analysis/TMS_Localizers/5020/5020_t1_brain.nii.gz

%%%%%% set up the contrasts, which you can get from the template file

%%% then make sure the submit scripts give the info we need. Don't need Day because it's always day 1.
