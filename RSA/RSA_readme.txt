This is a reminder of what the RSA scripts do. It took a while to read through and figure out what's going on, so this is a good idea.


Step 5 make ROI mats
	- this makes the neural RDMs. How?
	- Loop through each subject
	- Get the single-trial betas
	- Get the stimIDs and stimulus names for each trial
	- loop through each of the 246 brainnetome ROIs
	- Get the mask and unzip it.
	- Get the beta (which remember is whole-brain) and get just the ROI part
	- Do corrcoef and get the brain RDM
	- Save that output

Step 6 make RDMs
	- there's a default one that's for semantic, but I'll probably remove that
	- One for semantic and one for visual
	- Load the RDMs. For semantic, I do this weird thing where I load them, but then I re-do them
	- That's because I need 120 items per day, not the 995 total, so I get those rows from the feature matrix and re-do corrcoef
	- Remember, you want the stimIDs from all three runs for that day, and then you sorte them in order. The runs are important for IRAF which comes in another script
	- Then I save the info to separate folders, one per day. 
	- Then the big thing comes. I find the corr values between the model RDM and the neural RDM. This has a few steps
		-First, change the diagonal of 1s to NaNs and the bottom triangle to 0s. That way you have the upper triangular part of the matrix
		-Then load the neural RDM and do the same thing
		-Find corrcoef and save. (It's per day)

Step 7 colour atlas
	- This makes a brain map with the corr values per ROI.
	- It's a function that I can't seem to get running, but you can just load the inputs yourself and run the lines manually. It's fine

Step 8 RSA corr t-test
	- Now we want to compare the RSA results for each subject and day
	- The steps are pretty clear in the file
	- Make a table for the data, split into day-specific matrices, noralize with atanh() and do t-test
	- The script has lots of extra stuff where I did additional analyses (such as comparing relative change rather than absolute values per day) and looking at specific ROIs. In particular, we're interested in the stimulation site ROI

Step 9 will probably be IRAF





Here's some notes about how this all works
 % the mat outputs have data for one ROI.
    % R is the neural pattern similarity and has dimensions num betas x num betas. 
    % tmp is num voxels x num betas (I don't have tmp yet). Beta value for each
    % voxel in the ROI, one for each item/beta. Simon grabbed these to make the
    % Rs. Just didn't save it like Cortney does. tmp lets you make Rs as well
    % as beta series which lets you do functional connectivity
    
    % ROIvals has voxel x num betas. There's one value per voxel per trial.
    % Then you get R, which is the neural RDM. How well is activity correlated
    % between each voxel for each trial? 120 trials, which is why we get
    % 120x120. So, you get trial 1 to trial 1, trial 1 to trial 2, etc.
    
    % The single trial beta is an image. Each pixel has a number and that's the
    % beta for each voxel. Really it's a single trial 'betas' because each
    % voxel has their own beta. Take all the per-voxel betas for trial 1 and
    % correlate with all the per-voxel betas for trial 2, and that goes into
    % the 1x2 cell and 2x1 cell in R. 
    
    % a neural RDM says during trial 1, the voxels had a given activity, what
    % is the correlation between the voxel activity in trial 2. The answer goes
    % into R. Correlation of all the voxels for each trial. It's multivariate
    % considers more than one voxel at a time. In univariate, our analysis in
    % one voxel. 
    
    %%% y = cope1 * x + ...
    % y is activity, cope is beta coefficient, and x is 'average of the other
    % trials.' The question is what is the activity associated with this trial
    % holding all the others constant. So 'multiplying by 0' doesn't remove
    % them. You're not really multiplying by 0. It's like a logical 0. Not
    % actual multiplication. It's the average of all the trials, variance, etc.
    % 0 means "variables of non-interest" vs variable of interest. 
    % Could also do repeated measures ANOVA where you treat day like a
    % categorical variable. a linear relationship is interesting, but a V-shape
    % might be good too. 