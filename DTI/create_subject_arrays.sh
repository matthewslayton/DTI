#!/bin/bash

# Convert Excel file to CSV
python << END_OF_PYTHON_SCRIPT
import pandas as pd

# Read Excel file
df = pd.read_excel('/mnt/munin2/Simon/NetTMS.01/Analysis/SubjectPipelineProgress.xlsx')

# Save as CSV file (overwrite if exists)
df.to_csv('/mnt/munin2/Simon/NetTMS.01/Analysis/SubjectPipelineProgress.csv', index=False, mode='w')
END_OF_PYTHON_SCRIPT

# Function to get column index by header name
get_column_index() {
    local csv_file="$1"
    local header_name="$2"
    awk -F',' -v header_name="$header_name" '
        BEGIN {
            IGNORECASE = 1
        }
        NR == 1 {
            for (i = 1; i <= NF; i++) {
                gsub(/^[ \t]+|[ \t]+$/, "", $i)
                header_index[$i] = i
            }
        }
        END {
            print header_index[header_name]
        }
    ' "$csv_file"
}

# Initialize arrays
SUBJ=()
SUBJID=()
RUN=()
T1RUN=()

# Read the CSV file and extract SUBJ, SUBJID, RUN, and T1RUN columns dynamically
csv_file='/mnt/munin2/Simon/NetTMS.01/Analysis/SubjectPipelineProgress.csv'

SUBJ_index=$(get_column_index "$csv_file" "SUBJECT_ID")
SUBJID_index=$(get_column_index "$csv_file" "SCAN_ID")
RUN_index=$(get_column_index "$csv_file" "DWI_RUN")
T1RUN_index=$(get_column_index "$csv_file" "T1_RUN")
got_connectomes_index=$(get_column_index "$csv_file" "GOT_CONNECTOMES")
skip_subject_index=$(get_column_index "$csv_file" "SKIP_THIS_SUBJECT")
fmriprep_index=$(get_column_index "$csv_file" "FMRIPREP")

echo "SUBJ_index: $SUBJ_index"
echo "SUBJID_index: $SUBJID_index"
echo "RUN_index: $RUN_index"
echo "T1RUN_index: $T1RUN_index"
echo "got_connectomes_index: $got_connectomes_index"
echo "skip_subject_index: $skip_subject_index"
echo "fmriprep_index: $fmriprep_index"


while IFS=',' read -ra columns; do
    if [[ "${columns[skip_subject_index-1]}" != "y" && "${columns[got_connectomes_index-1]}" != "y" && "${columns[fmriprep_index-1]}" == "y" ]]; then
        SUBJ+=("${columns[SUBJID_index-1]}")
        SUBJID+=("${columns[SUBJ_index-1]}")
        RUN+=($(printf "%03d" "$(echo "${columns[RUN_index-1]}" | tr -d '[:space:]')"))
        T1RUN+=($(printf "%03d" "$(echo "${columns[T1RUN_index-1]}" | tr -d '[:space:]')"))
    fi
done < <(tail -n +2 "$csv_file")

# Print the populated SUBJ, SUBJID, RUN, and T1RUN arrays
echo "SUBJ: ${SUBJ[@]}"
echo "SUBJID: ${SUBJID[@]}"
echo "RUN: ${RUN[@]}"
echo "T1RUN: ${T1RUN[@]}"


# add need the fmriprep complete
# mags moved the got_connectomes column so see if it still works
# rename the columns to whatever mags named them