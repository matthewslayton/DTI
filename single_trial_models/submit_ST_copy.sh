#!/bin/sh

EXPERIMENT=NetTMS.01 #environmental variable

# to execute these scripts, ssh -X mas51@cluster.biac.duke.edu, qinteract, 
# need to be in the folder that has these scripts too. 
# /mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/

#put fsl up here? or do I even need it?
#fsl &

for subj in 5011; do echo $subj;
	for day in 1 2 3 4; do echo $day;
	#for day in 1; do echo $day;
		for run in 1 2 3; do echo $run;
	#	for run in 1; do echo $run;
			for trial in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do echo $trial;
	#		for trial in 1; do echo $trial;
				qsub -v EXPERIMENT=NetTMS.01 /mnt/munin2/Simon/NetTMS.01/Analysis/SingleTrialModels/June_2023_LSS/qsub_ST.sh; -v SUBJ=$subj -v DAY=$day -v RUN=$run -v TRIAL=$trial
				echo "---Submitted Subj[$subj] Day[$day] Run[$run] Trial[$trial]---"	
			done
		done
	done
done
echo "---Subject Completed---"