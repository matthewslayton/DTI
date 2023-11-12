%%%%%% Single Trial Modeling using LSS Step 2

%% This script selects specific columns in confounds_timeseries generated by fMRIprep
% and write a new tsv/txt file to be read by Feat as nuisance regressors.
% It's adapted from Shenyang's step2_select_fmriprep_nuisance_regressors.m
%%%% doing univariate or functional localizer? go to /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/Analysis_scripts/generate_confounds.m


% this is set up so the subjects go four times. That way we can avoid a
% subj loop and a biac_ID loop. I've always done this one manually. You can get the info from redcap

subjects = {'5001','5001','5001','5001',...
    '5002','5002','5002','5002',...
    '5004','5004','5004','5004',...
    '5005','5005','5005','5005',...
    '5006','5006','5006',...
    '5007','5007','5007','5007',...
    '5010','5010','5010','5010',...
    '5011','5011','5011','5011',...
    '5012','5012','5012','5012',...
    '5014','5014','5014','5014',...
    '5015','5015','5015','5015',...
    '5016','5016','5016','5016',...
    '5017','5017','5017','5017',...
    '5019','5019','5019','5019',...
    '5020','5020','5020','5020',...
    '5021','5021','5021','5021',...
    '5022','5022','5022','5022'};
biac_ID = {'00414','00595','00597','00598',... %5001
    '00373','00706','00710','00713',... %5002
    '00432','00562','00566','00568',... %5004
    '00616','00655','00658','00661',... %5005
    '00665','00742','00744',... %5006
    '00867','00890','00893','00895',... %5007
    '01224','01271','01275','01279',... %5010
    '00961','00990','00995','01001',... %5011
    '01087','01101','01104','01107',... %5012
    '00940','00976','00979','00980',... %5014
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
    1,2,3,... %5006
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
    1,2,3,4,...
    1,2,3,4];

subjects = {'5025','5025','5025','5025',...
    '5026','5026','5026','5026'};

biac_ID = {'01325', '01365', '01368', '01370',... %5025 hOA
'01375','01389', '01392','01396'}; %5026 MCI

dayNum = [1,2,3,4,...
    1,2,3,4];

% confounds = ["csf" "white_matter" "dvars" "framewise_displacement" ...
%     "trans_x" "trans_y" "trans_z" "rot_x" "rot_y" "rot_z"];
% plus the unknown number of 'motion_outlier's

%% generate trial-level folders and txt files based on trialinfo
for subj = 1:length(subjects)
    
    subject = subjects{subj};
    %subject = '5011';
    biac = biac_ID{subj};
    currDay = dayNum(subj);
    addpath(strcat('/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/',subject,'/'));
    
    outputdir = sprintf('/Volumes/Data/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/Confounds/%s/',subject);
    if ~exist(outputdir,'dir'); mkdir(outputdir); end

    tic
    for currRun = 1:3
        % load the raw confound file

        % might call the func runs "func" or "encoding"
        try
            currConfoundFile = sprintf('/Volumes/Data/Simon/NetTMS.01/Data/Processed_Data/fmriprep_out/sub-%s/ses-1/func/sub-%s_ses-1_task-encoding_run-%d_desc-confounds_timeseries.tsv',biac,biac,currRun);
            t = readtable(currConfoundFile, "FileType","text",'Delimiter', '\t');     
        catch
            currConfoundFile = sprintf('/Volumes/Data/Simon/NetTMS.01/Data/Processed_Data/fmriprep_out/sub-%s/ses-1/func/sub-%s_ses-1_task-func_run-%d_desc-confounds_timeseries.tsv',biac,biac,currRun);
            t = readtable(currConfoundFile, "FileType","text",'Delimiter', '\t');    
        end
       % currConfoundFile = sprintf('/Volumes/Data/Simon/NetTMS.01/Data/Processed_Data/fmriprep_out/sub-%s/ses-1/func/sub-%s_ses-1_task-encoding_run-%d_desc-confounds_timeseries.tsv',biac,biac,currRun);
       % t = readtable(currConfoundFile, "FileType","text",'Delimiter', '\t');                

        % remove first four and grab only CSF, WM, DVARS, FD
        t_clean_tbl = t(5:end,["csf","white_matter","dvars","framewise_displacement"]);
        t_clean = table2cell(t_clean_tbl);
        % write table as txt file 
        output_path = strcat(outputdir,sprintf('%s_Day%d_ENC_Confounds_Run%d.txt',subject,currDay,currRun));
        writecell(t_clean,output_path,'Delimiter','tab');

    end %currRun loop
    toc
end %end subj loop

