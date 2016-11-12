# neurosparse

## Folders map

* Two main folders, one for each dataset
	* `IMAGES_BLOCK_MASK`: Block-design experiment, with voxels filtering according to probability of belonging to gray matter. This is the dataset used in the paper.
	* `IMAGES_EVENT_MASK`: Event-design experiment, with voxels filtering according to probability of belonging to gray matter.
	* `SOLVERS`: contains the optimization solvers.
	* `UTILITIES`: containes auxiliary functions, such as for thresholding solutions and the `NIFTI` toolbox for Matlab.
* Each dataset folder contains subfolders for data and for each of the models, e.g., `LASSO`, `ENET`, `SLAP`.
* Each of the models' folders contain the Matlab function to run the numerical experiment:
	* `MODEL_val.m` runs the folds of the internal LOSO loop.
	* `MODEL_train.m` runs the folds of the external LOSO loop, using the results obtained via `MODEL_val.m`.
	* Both functions require as input argument the number of the fold to execute, to allow na&iuml;ve parallel processing.