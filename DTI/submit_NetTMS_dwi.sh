#!/bin/bash

# Call the script that makes subjid, subj, run, and t1run arrays from subjectPipelineProgress.xlsx 
subject_array_script=$(/mnt/munin2/Simon/NetTMS.01/Scripts/DWI/create_subject_arrays.sh)

# Read the captured subject arrays into separate variables
SUBJ=$(grep -oP 'SUBJ: \K.*' <<< "$subject_array_script")
SUBJID=$(grep -oP 'SUBJID: \K.*' <<< "$subject_array_script")
RUN=$(grep -oP 'RUN: \K.*' <<< "$subject_array_script")
T1RUN=$(grep -oP 'T1RUN: \K.*' <<< "$subject_array_script")

# Convert the variables into arrays
IFS=', ' read -r -a SUBJ <<< "$SUBJ"
IFS=', ' read -r -a SUBJID <<< "$SUBJID"
IFS=', ' read -r -a RUN <<< "$RUN"
IFS=', ' read -r -a T1RUN <<< "$T1RUN"

# Iterate over the arrays
for ((k = 0; k < ${#SUBJ[@]}; k++)); do
    # Get the values from arrays
    SUBJ_val="${SUBJ[$k]}"
    SUBJ2_val=${SUBJ_val:(-5)}
    SUBJID_val="${SUBJID[$k]}"
    RUN_val="${RUN[$k]}"
    T1RUN_val="${T1RUN[$k]}"

    # Print the values
    echo "SUBJ: $SUBJ_val"
    echo "SUBJ2: $SUBJ2_val"
    echo "SUBJID: $SUBJID_val"
    echo "RUN: $RUN_val"
    echo "T1RUN: $T1RUN_val"
    echo

    # Execute further commands or qsub script using the extracted values
    qsub -v EXPERIMENT=$EXPERIMENT /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/qsub_NetTMS_dwi.sh "$SUBJ_val" "$SUBJ2_val" "$SUBJID_val" "$RUN_val" "$T1RUN_val"
done
