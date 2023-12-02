#!/bin/sh

# This is a BIAC template script for jobs on the cluster
# You have to provide the Experiment on command line  
# when you submit the job the cluster.
#
# >  qsub -v EXPERIMENT=Dummy.01  script.sh args
#
# There are 2 USER sections 
#  1. USER DIRECTIVE: If you want mail notifications when
#     your job is completed or fails you need to set the 
#     correct email address.
#		   
#  2. USER SCRIPT: Add the user script in this section.
#     Within this section you can access your experiment 
#     folder using $EXPERIMENT. All paths are relative to this variable
#     eg: $EXPERIMENT/Data $EXPERIMENT/Analysis	
#     By default all terminal output is routed to the " Analysis "
#     folder under the Experiment directory i.e. $EXPERIMENT/Analysis
#     To change this path, set the OUTDIR variable in this section
#     to another location under your experiment folder
#     eg: OUTDIR=$EXPERIMENT/Analysis/GridOut 	
#     By default on successful completion the job will return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110
#     Arguments to the USER SCRIPT are accessible in the usual fashion
#     eg:  $1 $2 $3
# The remaining sections are setup related and don't require
# modifications for most scripts. They are critical for access
# to your data  	 

# --- BEGIN GLOBAL DIRECTIVE -- 
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
# -- END GLOBAL DIRECTIVE -- 

# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access 
#EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}

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

# to execute these scripts, ssh -X jz421@cluster.biac.duke.edu, qinteract, 
# need to be in the folder that has these scripts too. Simon sent it in slack.
# to prevent tmp folder from being saved to home

cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp

#arbitrary that these match the variable names from the submit.sh. $1 is the first input variable from the qsub command from submit.sh
SUBJ=$1
SUBJ2=$2 #Actually the scan id. Don't rename though cuz will confuse the lab...
SUBJID=$3
RUN=$4
T1RUN=$5

# manually add the variable definitions here so you can paste each step into the command window

echo $SUBJ >> qsubBilat.txt

# check the outputs here in the OUTPUT folder
OUTPUT=/mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/${SUBJID} 
echo $OUTPUT
mkdir -p ${OUTPUT}

# CHANGES - DWI2MASK USED INSTEAD OF BET AFTER PREPROC AND BEFORE TENSOR. BET OF B0 BEFORE REGISTRATION ADJUSTED TO 0.3

# code as 1 to turn ON section, code as 0 to turn OFF
# choose if you wanna run each function or not
# these are preprocessing steps that you can set to 1 if you need them
# you're most likely going to run this one function at a time. Even better, copy and paste into the command window,
# look at the outputs, and QA
# it's good to explore varying parameters such as fiber counts
### (1) these are all preprocessing, so run all 
MOVE=0
DENOISE=0
DEGIBBS=0
SNR=0
PREPROC=0
MEASURES=0
ROIS=0
FTTGEN=0

### (2) pick one
# set only SD_STREAM or iFOD2 but not both
# SD_STREAM is deterministic and iFOD is probabilistic

# pick one with ACT seeding or not
SD_STREAM_ACTSEEDING=0
SD_STREAM_SEEDING=0

# ok to run any or all of these
SD_STREAM_ACTCONNECTOME=0
SD_STREAM_SIFTACTCONNECTOME=0
SD_STREAM_CONNECTOME=0

# pick one with ACT seeding or not
iFOD2_ACTSEEDING=1
iFOD2_SEEDING=0

# ok to run any or all of these
iFOD2_ACTCONNECTOME=1
iFOD2_SIFTACTCONNECTOME=1
iFOD2_CONNECTOME=0

# these are not necessary, but use these if you want to look at the streamlines in mrtrix
CONNECTOME2TCK=1
TCK2TRK=1

# deletes intermediate files. 
CLEANUP=0

# based on DTI471 atlas. You can see it when you open the atlas in FSL and go to the stim coordinates
# schemrep is using brainetome
# NetTMS has a stimulation ROI, which is why this is here
STIMROI=22;


# prefix key:

# b = skull-stripped via bet
# d = denoised via dwidenoise 
# g = degibbs via mrdegibbs
# e = eddy-corrected via dwifslpreprocess
# k = add initial mask via bet 
# c = bias-corrected via dwibiascorrect

# n = noise output from dwidenoise
# f = first step in calculating mean bvalues
# mbv = mean bvalue calculated from fsl

# c = bias-corrected via dwibiascorrect
# out_sfwm = Output single-fibre WM response text file
# out_gm = Output GM response text file
# out_csf = Output CSF response text file
# 5TT1 = 1st img in 5TT file

# 3 pieces of data for any diffusion dataset
	# 1. the scans, 2. the bvecs file (x y z) 3. bvals file
	# bvecs file has basically T2 scan for first, b0. 
	# first vector after b0 in bvecs is a unit vector, b1.
	# unit vectors after that are also unit vectors, just not entirely on one axis. These are the directions of diffusion we're looking at.
	# bvals is amount of diffusion weighting in particular orientation

#just type command into terminal to figure out what it does
# type them in one by one to figure stuff out (for example type in extractdiffdirs)


#first two pics aren't DWI, everything else is different orientation of the diffusion vector
if [ $MOVE = 1 ]; then
	# extract the bvecs/bvals, must pull from original .bxh, reconstructed .bxh has identical bvecs and vals, but this command won't recognize them
	extractdiffdirs --fsl ${EXPERIMENT}/Data/Anat/${SUBJ}/bia5_${SUBJ2}_${RUN}.bxh ${OUTPUT}/${SUBJ2}_bvecs ${OUTPUT}/${SUBJ2}_bvals 
	
	echo "path is "
	# generate .mif with pe dir & revpe dir b0s for preproc so full revpe can be removed 
	fslroi ${EXPERIMENT}/Data/Anat/${SUBJ}/bia5_${SUBJ2}_${RUN}.nii.gz ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz 0 1 
	fslroi ${EXPERIMENT}/Data/Anat/${SUBJ}/bia5_${SUBJ2}_${RUN}_revphase.nii.gz ${OUTPUT}/${SUBJ2}_dwi_b0_revphase.nii.gz 0 1
	mrconvert ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz ${OUTPUT}/${SUBJ2}_dwi_b0.mif #just convert file type to make mrtrix like it more
	mrconvert ${OUTPUT}/${SUBJ2}_dwi_b0_revphase.nii.gz ${OUTPUT}/${SUBJ2}_dwi_b0_revphase.mif
	mrcat ${OUTPUT}/${SUBJ2}_dwi_b0.mif ${OUTPUT}/${SUBJ2}_dwi_b0_revphase.mif ${OUTPUT}/b0s.mif  #concat these two things together
else
	echo "Skipped 1MOVE"
fi

# _brain tag means its been skullstripped
#bet command needs fractional threshold about how much skull stripping you want to do. 0.5 is good threshold.
#look at data at each stage.
if [ $DENOISE = 1 ]; then
	# slight skullstrip prior to denoising for speed
	bet ${EXPERIMENT}/Data/Anat/${SUBJ}/bia5_${SUBJ2}_${RUN}.nii.gz ${OUTPUT}/b${SUBJ2}_dwi.nii.gz -f 0.1 -F #first output of diffusion data and pull into your directory

#fsl and mrtrix documentation
	#dwi denoise options same as Chris
	dwidenoise ${OUTPUT}/b${SUBJ2}_dwi.nii.gz ${OUTPUT}/db${SUBJ2}_dwi.nii.gz -noise ${OUTPUT}/n${SUBJ2}_dwi.nii.gz -nthread 8 -force
else
	echo "Skipped 2DENOISE"
fi

if [ $DEGIBBS = 1 ]; then
	# mrdegibbs added from Chris, should take place after denoise, not before
	mrdegibbs ${OUTPUT}/db${SUBJ2}_dwi.nii.gz ${OUTPUT}/gdb${SUBJ2}_dwi.nii.gz  
else
	echo "Skipped 2DEGIBBS"
fi

if [ $SNR = 1 ]; then
	# first step in calculating mean b values to get SNR (indexing starts at 0, don't include b0s)
	fslroi ${EXPERIMENT}/Data/Anat/${SUBJ}/bia5_${SUBJ2}_${RUN}.nii.gz ${OUTPUT}/fdb${SUBJ2}_dwi.nii.gz 2 23

	# calculate mean b values to get SNR
	fslmaths -dt input ${OUTPUT}/fdb${SUBJ2}_dwi.nii.gz -Tmean ${OUTPUT}/mbv${SUBJ2}_dwi.nii.gz -odt input 

	# calculate SNR
	fslmaths -dt input ${OUTPUT}/mbv${SUBJ2}_dwi.nii.gz -div ${OUTPUT}/n${SUBJ2}_dwi.nii.gz ${OUTPUT}/SNR${SUBJ2} 

	#rm -f ${OUTPUT}/fdb${SUBJ2}_dwi.nii.gz
	#rm -f ${OUTPUT}/mbv${SUBJ2}_dwi.nii.gz
else 
	echo "Skipped 3SNR"
fi


if [ $PREPROC = 1 ]; then
	# create a mask with bet for preproc so that it doesn't use dwi2mask
	bet ${OUTPUT}/gdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/bgdb${SUBJ2}_dwi.nii.gz -f 0.1 -F -m

	# dwifslpreprocess -- eddy field correction, added a mask made with bet to avoid holes in dwi2mask automatically included in preproc command, added --repol to match chris, added -align_seepi because using b0s on -se_epi, added readout time to match Chris
	dwifslpreproc -nthreads 16 ${OUTPUT}/gdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/egdb${SUBJ2}_dwi.nii.gz -rpe_pair -se_epi ${OUTPUT}/b0s.mif -pe_dir PA -fslgrad ${OUTPUT}/${SUBJ2}_bvecs ${OUTPUT}/${SUBJ2}_bvals  -export_grad_fsl ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals -eddy_mask ${OUTPUT}/bgdb${SUBJ2}_dwi_mask.nii.gz -eddy_options " --slm=linear --repol" -readout_time 0.075 -align_seepi 

	# bias-field correction, add flag "-bias" to get the image of bias. REMOVED MASK TO MATCH CHRIS "-mask ${OUTPUT}/begdb${SUBJ2}_dwi_mask.nii.gz"
	dwibiascorrect ants ${OUTPUT}/egdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals -bias ${OUTPUT}/cegdb${SUBJ2}_dwi_bias.nii.gz

	# create a better mask with the bias-corrected info using bet (not dwi2mask) to avoid holes. 0.3 works best for this. 
	bet ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/bcegdb${SUBJ2}_dwi.nii.gz -f 0.3 -F -m 
	dwi2mask ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/bcegdb${SUBJ2}_dwi_mask.nii.gz -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals
else
	echo "Skipped 4PREPROC"
fi
			

if [ $MEASURES = 1 ]; then
	# create tensor, create FA/RD/AD as well as vectors and ADC
	dwi2tensor -mask ${OUTPUT}/bcegdb${SUBJ2}_dwi_mask.nii.gz ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/cegdb${SUBJ2}_dwi_tensor.nii.gz -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals  
	tensor2metric ${OUTPUT}/cegdb${SUBJ2}_dwi_tensor.nii.gz -fa ${OUTPUT}/cegdb${SUBJ2}_dwi_FA.nii.gz -rd ${OUTPUT}/cegdb${SUBJ2}_dwi_RD.nii.gz -ad ${OUTPUT}/cegdb${SUBJ2}_dwi_AD.nii.gz -adc ${OUTPUT}/cegdb${SUBJ2}_dwi_ADC.nii.gz -vector ${OUTPUT}/cegdb${SUBJ2}_dwi_vecs.nii.gz

	# get the response function
	dwi2response tournier ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/${SUBJ2}_dwi_out.txt -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals 
	# response function for wm/gm/csf
	dwi2response dhollander ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/${SUBJ2}_dwi_sfwm.txt ${OUTPUT}/${SUBJ2}_dwi_gm.txt ${OUTPUT}/${SUBJ2}_dwi_csf.txt -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals 

	# acquiring FOD
	dwi2fod csd ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/${SUBJ2}_dwi_out.txt ${OUTPUT}/${SUBJ2}_dwi_FOD.nii.gz -mask ${OUTPUT}/bcegdb${SUBJ2}_dwi_mask.nii.gz -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals 
else
	echo "Skipped 5MEASURES"
fi

if [ $ROIS = 1 ]; then
	# generate the b0 (may need more stringent bet, 00373 0.3 worked well)
	fslroi ${OUTPUT}/cegdb${SUBJ2}_dwi.nii.gz ${OUTPUT}/cegdb${SUBJ2}_dwi_b0.nii.gz 0 1 
	bet ${OUTPUT}/cegdb${SUBJ2}_dwi_b0.nii.gz ${OUTPUT}/bcegdb${SUBJ2}_dwi_b0.nii.gz -f 0.3 

	# registration: MNI to native space
	flirt -in /usr/local/packages/fsl-5.0.6/data/standard/MNI152_T1_2mm_brain -ref ${OUTPUT}/bcegdb${SUBJ2}_dwi_b0.nii.gz -out ${OUTPUT}/${SUBJ2}_dwi_MNI_to_native -omat ${OUTPUT}/${SUBJ2}_dwi_MNI_to_native.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp nearestneighbour 
	flirt -in /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/hoa471_sp.nii -ref ${OUTPUT}/bcegdb${SUBJ2}_dwi_b0.nii.gz -out ${OUTPUT}/${SUBJ2}_dwi_HOAsp -applyxfm -init ${OUTPUT}/${SUBJ2}_dwi_MNI_to_native.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp nearestneighbour 
	# flirt -in ${EXPERIMENT}/Scripts/HOA100_LR.nii.gz -ref ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz -out ${OUTPUT}/${SUBJ2}_b0_HOA100_LR -applyxfm -init ${OUTPUT}/${SUBJ2}_dwi_MNI_to_native.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp nearestneighbour
else
	echo "Skipped 6ROIS"
fi 


if [ $FTTGEN = 1 ]; then
	# CREATING 5TT FOR USE OF ACT IN tckgen & SIFT
	# run 5ttgen fsl on the raw T1 (NOT SKULLSTRIPPED) using the -nocrop option to keep the dimensions from the input raw T1 on the output 5ttgen image.

	# adding fslroi command to generate b0 from original b=1000, to then use that "pristine" altered b0 for 5ttgen
	#replace the next two commands with ANTs
	# fslroi ${EXPERIMENT}/Data/Anat/${SUBJ}/bia5_${SUBJ2}_${RUN}.nii.gz ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz 0 1
	 
	# flirt -in ${EXPERIMENT}/Data/Anat/${SUBJ}/bia5_${SUBJ2}_${T1RUN}.nii.gz -ref ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz -out ${OUTPUT}/${SUBJ2}_anat.nii.gz -omat ${OUTPUT}/${SUBJ2}_anat.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6  -interp trilinear
	python /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/antsRegistration.py ${SUBJ2} ${SUBJID}
	5ttgen fsl ${OUTPUT}/${SUBJ2}_T1wTob0.nii.gz ${OUTPUT}/tt_${SUBJ2}.mif -nocrop 
	5tt2gmwmi ${OUTPUT}/tt_${SUBJ2}.mif ${OUTPUT}/tt_${SUBJ2}_GMWMI.mif 
else
	echo "Skipped 7FTTGEN"
fi
			

# make a different directory for each configuration
# 2x2 of SD_STREAM, iFOD2 vs. SIFT_ACT, no SIFT_ACT

# sd stream with act
if [ $SD_STREAM_ACTSEEDING = 1 ]; then
	mkdir -p ${OUTPUT}/SD_STREAM_ACT
	cd ${OUTPUT}/SD_STREAM_ACT

	# seeding done at random within a mask image

	tckgen ${OUTPUT}/${SUBJ2}_dwi_FOD.nii.gz -seed_image ${OUTPUT}/bcegdb${SUBJ2}_dwi_mask.nii.gz  ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_seed_image_SD_STREAM_ACT.tck -algorithm SD_stream -select 10M -maxlength 250 -minlength 25 -angle 35 -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals -act ${OUTPUT}/tt_${SUBJ2}.mif -seed_gmwmi ${OUTPUT}/tt_${SUBJ2}_GMWMI.mif -force
	tcksift ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_seed_image_SD_STREAM_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_FOD.nii.gz ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_SD_STREAM_SIFT_ACT.tck -fd_scale_gm -act ${OUTPUT}/tt_${SUBJ2}.mif -term_number 1M -force 
else
	echo "Skipped 8ACTSEEDING"
fi

# sd stream no act
if [ $SD_STREAM_SEEDING = 1 ]; then
	mkdir -p ${OUTPUT}/SD_STREAM
	cd ${OUTPUT}/SD_STREAM

	# seeding done at random within a mask image

	# i don't think that tcksift actually produces an output if it uses -nofilter
	tckgen ${OUTPUT}/${SUBJ2}_dwi_FOD.nii.gz -seed_image ${OUTPUT}/bcegdb${SUBJ2}_dwi_mask.nii.gz  ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_seed_image_SD_STREAM.tck -algorithm SD_stream -select 10M -maxlength 250 -minlength 25 -angle 35 -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals -force
else
	echo "Skipped 8ACTSEEDING"
fi

# ifod2 with act
if [ $iFOD2_ACTSEEDING = 1 ]; then
	mkdir -p ${OUTPUT}/iFOD2_ACT
	cd ${OUTPUT}/iFOD2_ACT

	# seeding done at random within a mask image

	#delete algorithm - SD_stream to use iFOD2 instead (the default option)
	tckgen ${OUTPUT}/${SUBJ2}_dwi_FOD.nii.gz -seed_image ${OUTPUT}/bcegdb${SUBJ2}_dwi_mask.nii.gz  ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_seed_image_iFOD2_ACT.tck -select 10M -maxlength 250 -minlength 25 -angle 35 -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals -act ${OUTPUT}/tt_${SUBJ2}.mif -seed_gmwmi ${OUTPUT}/tt_${SUBJ2}_GMWMI.mif -force
	tcksift ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_seed_image_iFOD2_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_FOD.nii.gz ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_iFOD2_SIFT_ACT.tck -fd_scale_gm -act ${OUTPUT}/tt_${SUBJ2}.mif -term_number 1M -force 
else
	echo "Skipped 8ACTSEEDING"
fi

# ifod2 no act
if [ $iFOD2_SEEDING = 1 ]; then
	mkdir -p ${OUTPUT}/iFOD2
	cd ${OUTPUT}/iFOD2
	# seeding done at random within a mask image

	tckgen ${OUTPUT}/${SUBJ2}_dwi_FOD.nii.gz -seed_image ${OUTPUT}/bcegdb${SUBJ2}_dwi_mask.nii.gz  ${OUTPUT}/iFOD2/${SUBJ2}_dwi_seed_image_iFOD2.tck -select 10M -maxlength 250 -minlength 25 -angle 35 -fslgrad ${OUTPUT}/e${SUBJ2}_bvecs ${OUTPUT}/e${SUBJ2}_bvals -force
else
	echo "Skipped 8ACTSEEDING"
fi


if [ $SD_STREAM_ACTCONNECTOME =  1 ]; then 
	# tcksample used to get values of associated image (in this case, FA) along tracks
	tcksample ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_seed_image_SD_STREAM_ACT.tck ${OUTPUT}/cegdb${SUBJ2}_dwi_FA.nii.gz ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_mean_tracks_SD_STREAM_ACT_FA.csv -stat_tck mean -force
	tck2connectome ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_seed_image_SD_STREAM_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_STRconnectome_SD_STREAM_ACT.csv -out_assignments ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_STR_out_assignments_SD_STREAM_ACT.txt -force 
	tck2connectome ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_seed_image_SD_STREAM_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_FAconnectome_SD_STREAM_ACT.csv -scale_file ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_FA_mean_tracks_SD_STREAM_ACT.csv -stat_edge mean ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_FA_out_assignments_SD_STREAM_ACT.txt -force

	# not sure what the input tck would be when using connectome2tck for just act without sift, since tcksift produces the tck file.

else
	echo "Skipped 9ACTCONNECTOME"
fi

if [ $iFOD2_ACTCONNECTOME =  1 ]; then 
	# tcksample used to get values of associated image (in this case, FA) along tracks
	tcksample ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_seed_image_iFOD2_ACT.tck ${OUTPUT}/cegdb${SUBJ2}_dwi_FA.nii.gz ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_iFOD2_ACT_FA_mean_tracks.csv -stat_tck mean -force
	tck2connectome ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_seed_image_iFOD2_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/iFOD2_ACT/${SUBJ2}_STRconnectome_iFOD2_ACT.csv -out_assignments ${OUTPUT}/iFOD2_ACT/${SUBJ2}_STR_out_assignments_iFOD2_ACT.txt -force 
	tck2connectome ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_seed_image_iFOD2_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/iFOD2_ACT/${SUBJ2}_FAconnectome_iFOD2_ACT.csv -scale_file ${OUTPUT}/${SUBJ2}_dwi_FA_mean_tracks_iFOD2_ACT.csv -stat_edge mean ${OUTPUT}/${SUBJ2}_FA_out_assignments_iFOD2_ACT.txt -force

	# not sure what the input tck would be when using connectome2tck for just act without sift, since tcksift produces the tck file.

else
	echo "Skipped 9ACTCONNECTOME"
fi

if [ $SD_STREAM_CONNECTOME = 1 ]; then 
	# tcksample used to get values of associated image (in this case, FA) along tracks
	tcksample ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_seed_image_SD_STREAM.tck ${OUTPUT}/cegdb${SUBJ2}_dwi_FA.nii.gz ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_mean_tracks_SD_STREAM_FA.csv -stat_tck mean -force
	tck2connectome ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_seed_image_SD_STREAM.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/SD_STREAM/${SUBJ2}_STRconnectome_SD_STREAM.csv -out_assignments ${OUTPUT}/SD_STREAM/${SUBJ2}_STR_out_assignments_SD_STREAM.txt -force 
	#test the fa code
	tck2connectome ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_seed_image_SD_STREAM.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/SD_STREAM/${SUBJ2}_FAconnectome_SD_STREAM.csv -scale_file ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_mean_tracks_SD_STREAM_FA.csv -stat_edge mean -out_assignments ${OUTPUT}/SD_STREAM/${SUBJ2}_FA_out_assignments_SD_STREAM.txt -force
	
	# use connectome to get a tck file for each node that has all of the streamlines going through it
	if [ $CONNECTOME2TCK = 1 ]; then

		mkdir -p ${OUTPUT}/SD_STREAM/nodeStreamlines_SD_STREAM #this can be renamed, but make a folder to keep all 471 node-streamline assignments

		cd ${OUTPUT}/SD_STREAM/nodeStreamlines_SD_STREAM

		# maybe we should do this for both FA and STR connectomes??? I'm not sure what the difference would be..

		connectome2tck ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_seed_image_SD_STREAM.tck ${OUTPUT}/SD_STREAM/${SUBJ2}_STR_out_assignments_SD_STREAM.txt node -nodes ${STIMROI} -files per_node #this makes a .tck file for each node, that contains all the streamlines connected to that node (except for self-connections)

		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	fi

	if [ $TCK2TRK = 1 ]; then
		cd ${OUTPUT}  # I think you need to cd into the output directory for this?

		# if this already exists, it gets stuck...
		/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py ${OUTPUT}/SD_STREAM/${SUBJ2}_dwi_seed_image_SD_STREAM.tck ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz

		folder_path="${OUTPUT}/SD_STREAM/nodeStreamlines_SD_STREAM"
		b0_file="${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz"

		# this goes through each node.tck file generated from connectome2tck and converts them to trk files
		for file_path in "${folder_path}/node"*.tck; do
			if [ -f "$file_path" ]; then
				echo "Processing file: $file_path"
				/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py "$file_path" "$b0_file"
			fi
		done

		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	fi
else
	echo "Skipped 9ACTCONNECTOME"
fi


if [ $iFOD2_CONNECTOME =  1 ]; then 
	# tcksample used to get values of associated image (in this case, FA) along tracks
	tcksample ${OUTPUT}/iFOD2/${SUBJ2}_dwi_seed_image_iFOD2.tck ${OUTPUT}/cegdb${SUBJ2}_dwi_FA.nii.gz ${OUTPUT}/iFOD2/${SUBJ2}_dwi_mean_tracks_iFOD2_FA.csv -stat_tck mean -force
	tck2connectome ${OUTPUT}/iFOD2/${SUBJ2}_dwi_seed_image_iFOD2.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/iFOD2/${SUBJ2}_STRconnectome_iFOD2.csv -out_assignments ${OUTPUT}/iFOD2/${SUBJ2}_STR_out_assignments_iFOD2.txt -force 
	#test the fa code
	tck2connectome ${OUTPUT}/iFOD2/${SUBJ2}_dwi_seed_image_iFOD2.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/iFOD2/${SUBJ2}_FAconnectome_iFOD2.csv -scale_file ${OUTPUT}/iFOD2/${SUBJ2}_dwi_mean_tracks_iFOD2_FA.csv -stat_edge mean -out_assignments ${OUTPUT}/iFOD2/${SUBJ2}_FA_out_assignments_iFOD2.txt -force
	
	# use connectome to get a tck file for each node that has all of the streamlines going through it
	if [ $CONNECTOME2TCK = 1 ]; then

		mkdir -p ${OUTPUT}/iFOD2/nodeStreamlines_iFOD2 #this can be renamed, but make a folder to keep all 471 node-streamline assignments

		cd ${OUTPUT}/iFOD2/nodeStreamlines_iFOD2

		# maybe we should do this for both FA and STR connectomes??? I'm not sure what the difference would be..

        connectome2tck ${OUTPUT}/iFOD2/${SUBJ2}_dwi_seed_image_iFOD2.tck ${OUTPUT}/iFOD2/${SUBJ2}_STR_out_assignments_iFOD2.txt node -nodes ${STIMROI} -files per_node

		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	fi

	if [ $TCK2TRK = 1 ]; then
		cd ${OUTPUT}  # I think you need to cd into the output directory for this?

		# if this already exists, it gets stuck...
		/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py ${OUTPUT}/iFOD2/${SUBJ2}_dwi_seed_image_iFOD2.tck ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz

		folder_path="${OUTPUT}/iFOD2/nodeStreamlines_iFOD2"
		b0_file="${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz"

		# this goes through each node.tck file generated from connectome2tck and converts them to trk files
		for file_path in "${folder_path}/node"*.tck; do
			if [ -f "$file_path" ]; then
				echo "Processing file: $file_path"
				/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py "$file_path" "$b0_file"
			fi
		done

		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	fi
else
	echo "Skipped 9ACTCONNECTOME"
fi


if [ $SD_STREAM_SIFTACTCONNECTOME =  1 ]; then 
	tcksample ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_SD_STREAM_SIFT_ACT.tck ${OUTPUT}/cegdb${SUBJ2}_dwi_FA.nii.gz ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_mean_tracks_SD_STREAM_ACT_FA.csv -stat_tck mean -force
	tck2connectome ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_SD_STREAM_SIFT_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/${SUBJ2}_STRconnectome_SIFTACT.csv -out_assignments ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_STR_out_assignments_SD_STREAM_SIFT_ACT.txt -force 
	
	#scale file should be mean tracks.csv, change this and the others after sd_stream works.
	tck2connectome ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_SD_STREAM_SIFT_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/${SUBJ2}_FAconnectome_SIFTACT.csv -scale_file ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_FAconnectome_SD_STREAM_ACT.csv -stat_edge mean -out_assignments ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_FA_out_assignments_SD_STREAM_SIFT_ACT.txt -force

	if [ $CONNECTOME2TCK = 1 ]; then
		mkdir -p ${OUTPUT}/SD_STREAM_ACT/nodeStreamlines_SD_STREAM_SIFT_ACT #this can be renamed, but make a folder to keep all 471 node-streamline assignments

		cd ${OUTPUT}/SD_STREAM_ACT/nodeStreamlines_SD_STREAM_SIFT_ACT

		# maybe we should do this for both FA and STR connectomes??? I'm not sure what the difference would be..
		
		connectome2tck ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_SD_STREAM_SIFT_ACT.tck ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_STR_out_assignments_SD_STREAM_SIFT_ACT.txt node -nodes ${STIMROI} -files per_node #this makes a .tck file for each node, that contains all the streamlines connected to that node (except for self-connections)
		
		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	else
		echo "Skipped 11TCK2CONNECTOME"
	fi

	if [ $TCK2TRK = 1 ]; then
		cd ${OUTPUT}  # I think you need to cd into the output directory for this?
		/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py ${OUTPUT}/SD_STREAM_ACT/${SUBJ2}_dwi_SD_STREAM_SIFT_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz

		folder_path="${OUTPUT}/SD_STREAM_ACT/nodeStreamlines_SD_STREAM_SIFT_ACT"
		b0_file="${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz"

		# this goes through each node.tck file generated from connectome2tck and converts them to trk files
		for file_path in "${folder_path}/node"*.tck; do
			if [ -f "$file_path" ]; then
				echo "Processing file: $file_path"
				/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py "$file_path" "$b0_file"
			fi
		done

		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	else
		echo "Skipped 12TCK2TRK"
	fi

else
	echo "Skipped 10SIFTACTCONNECTOME"
fi

if [ $iFOD2_SIFTACTCONNECTOME =  1 ]; then 
	tcksample ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_iFOD2_SIFT_ACT.tck ${OUTPUT}/cegdb${SUBJ2}_dwi_FA.nii.gz ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_mean_tracks_iFOD2_ACT_FA.csv -stat_tck mean -force
	tck2connectome ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_iFOD2_SIFT_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/${SUBJ2}_STRconnectome_SIFTACT.csv -out_assignments ${OUTPUT}/iFOD2_ACT/${SUBJ2}_STR_out_assignments_iFOD2_SIFT_ACT.txt -force 
	tck2connectome ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_iFOD2_SIFT_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/${SUBJ2}_FAconnectome_SIFTACT.csv -scale_file ${OUTPUT}/iFOD2_ACT/${SUBJ2}_FAconnectome_iFOD2_SIFT_ACT.csv -stat_edge mean -out_assignments ${OUTPUT}/iFOD2_ACT/${SUBJ2}_FA_out_assignments_iFOD2_SIFT_ACT.txt -force

	if [ $CONNECTOME2TCK = 1 ]; then
		mkdir -p ${OUTPUT}/iFOD2_ACT/nodeStreamlines_iFOD2_SIFT_ACT #this can be renamed, but make a folder to keep all 471 node-streamline assignments

		cd ${OUTPUT}/iFOD2_ACT/nodeStreamlines_iFOD2_SIFT_ACT

		# maybe we should do this for both FA and STR connectomes??? I'm not sure what the difference would be..
		
		connectome2tck ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_iFOD2_SIFT_ACT.tck ${OUTPUT}/iFOD2_ACT/${SUBJ2}_STR_out_assignments_iFOD2_SIFT_ACT.txt node -nodes ${STIMROI} -files per_node #this makes a .tck file for each node, that contains all the streamlines connected to that node (except for self-connections)
		
		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	else
		echo "Skipped 11TCK2CONNECTOME"
	fi


	if [ $TCK2TRK = 1 ]; then
		cd ${OUTPUT}  # I think you need to cd into the output directory for this?
		/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py ${OUTPUT}/iFOD2_ACT/${SUBJ2}_dwi_iFOD2_SIFT_ACT.tck ${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz

		folder_path="${OUTPUT}/iFOD2_ACT/nodeStreamlines_iFOD2_SIFT_ACT"
		b0_file="${OUTPUT}/${SUBJ2}_dwi_b0.nii.gz"

		# this goes through each node.tck file generated from connectome2tck and converts them to trk files
		for file_path in "${folder_path}/node"*.tck; do
			if [ -f "$file_path" ]; then
				echo "Processing file: $file_path"
				/usr/local/packages/python3.9/bin/python3 /mnt/munin2/Simon/NetTMS.01/Scripts/DWI/convert_mrt2trk.py "$file_path" "$b0_file"
			fi
		done

		cd /mnt/munin2/Simon/NetTMS.01/Data/Preprocessing_DWI/Tmp
	else
		echo "Skipped 12TCK2TRK"
	fi


else
	echo "Skipped 10SIFTACTCONNECTOME"
fi


# misc commands to use for QA
#tckedit -include rightROI.nii.gz -include leftROI.nii.gz 23272_dwi_seed_image_ACT.tck 23272_bihemconnectome_ACT.tck
#tckedit -number 1M ${OUTPUT}/${SUBJ2}_dwi_seed_image_ACT.tck ${OUTPUT}/${SUBJ2}_reduced_act_test.tck 
#tcksample ${OUTPUT}/${OUTPUT}/${SUBJ2}_reduced_act_test.tck ${OUTPUT}/ckedbm${SUBJ2}_dwi_FA.nii.gz ${OUTPUT}/${SUBJ2}_dwi_ACT_FA_mean_tracks_reduced.csv -stat_tck mean -force
#tck2connectome ${OUTPUT}/${OUTPUT}/${SUBJ2}_reduced_act_test.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/${SUBJ2}_STRconnectome_ACT_reduced.csv  -force
#tck2connectome ${OUTPUT}/${SUBJ2}_reduced_act_test.tck ${OUTPUT}/${SUBJ2}_dwi_HOAsp.nii.gz ${OUTPUT}/${SUBJ2}_FAconnectome_ACT_reduced.csv -scale_file ${OUTPUT}/${SUBJ2}_dwi_ACT_FA_mean_tracks_reduced.csv -stat_edge mean -force


if [ $CLEANUP = 1 ]; then
	rm -f ${OUTPUT}/b${SUBJ2}_dwi.nii.gz
	rm -f ${OUTPUT}/db${SUBJ2}_dwi.nii.gz
	rm -f ${OUTPUT}/gdb${SUBJ2}_dwi.nii.gz
	rm -f ${OUTPUT}/bgdb${SUBJ2}_dwi.nii.gz
	rm -f ${OUTPUT}/egdb${SUBJ2}_dwi.nii.gz
	rm -f ${OUTPUT}/begdb${SUBJ2}_dwi.nii.gz
	rm -f ${OUTPUT}/egdb${SUBJ2}_dwi.nii.gz
	rm -f bia5_{SUBJ2}_{RUN}_bvals
	rm -f bia5_{SUBJ2}_{RUN2}_bvals
	rm -f bia5_{SUBJ2}_{RUN}_bvecs
	rm -f bia5_{SUBJ2}_{RUN2}_bvecs
	rm -f bia5_{SUBJ2}_bvecs
	rm -f bia5_{SUBJ2}_bvecs
	rm -f resampled_{SUBJ}_{RUN}.nii.gz
	rm -f resampled_{SUBJ}_{RUN2}.nii.gz
	rm -f ${OUTPUT}/${RUN}_${SUBJ2}_dwi_b0.nii.gz

else 
	echo "Skipped 12CLEANUP"
fi

 
OUTDIR=${EXPERIMENT}/Data/Preprocessing_DWI/Logs
mkdir -p $OUTDIR

# -- END USER SCRIPT -- #

# **********************************************************hands-on
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
