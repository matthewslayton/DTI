#!/bin/bash

source /etc/biac_sge.sh
EXPERIMENT=`findexp NetTMS.01`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}

if [ $EXPERIMENT = "ERROR" ]
then
        exit 32
else   

#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----" 

# -- END PRE-USER --
# **********************************************************

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M matthew.slayton@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

# to execute these scripts, ssh -X mas51@cluster.biac.duke.edu, qinteract, 
# need to be in the folder that has these scripts too. 
# /mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/
# Simon sent it in slack. to prevent tmp folder from being saved to home

cd /mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/tmp

SUBJ=$1
DAY=$2
RUN=$3
TRIAL=$4

echo ${SUBJ};
echo ${DAY};
echo ${RUN};
echo ${TRIAL};

OUTPUT=/mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/trialDataOut/${SUBJ}/design_day${DAY}_run${RUN}/trial${TRIAL}
echo $OUTPUT

echo "Begin Subj${SUBNUM} Day${DAY} Run${RUN} Trial${TRIAL}"

feat ${OUTPUT}/design.fsf;

OUTDIR=${EXPERIMENT}/Analysis/SingleTrialModels/June_2023_LSS/Logs

mkdir -p $OUTDIR

rm -f /mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/trialDataOut/${SUBJNUM}/${SUBJID}_ENC_CMEM_RUN${RUN}.feat/filtered_func_data.nii.gz


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER --
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----"
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER--
